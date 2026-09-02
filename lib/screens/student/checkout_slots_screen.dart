import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../models/order_model.dart';
import '../../models/slot_capacity.dart';
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/slot_badge.dart';

class CheckoutSlotsScreen extends StatefulWidget {
  const CheckoutSlotsScreen({super.key});

  @override
  State<CheckoutSlotsScreen> createState() => _CheckoutSlotsScreenState();
}

class _CheckoutSlotsScreenState extends State<CheckoutSlotsScreen> {
  bool _isPlacingOrder = false;
  final TextEditingController _notesController = TextEditingController();
  bool _isSplitEnabled = false;
  int _splitPeopleCount = 2;

  Future<void> _handlePlaceOrder(AppState appState, {bool isDemoScanPay = false}) async {
    if (appState.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.capReachedRed,
          content: Text(
            'Your cart is empty. Please add items from the menu first.',
            style: GoogleFonts.beVietnamPro(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final paymentMethod = isDemoScanPay
          ? 'Online Payment (UPI/QR)'
          : appState.selectedPaymentMethod;

      final isInstantPaid = paymentMethod == 'Online Payment (UPI/QR)' ||
          paymentMethod == 'Campus UPI Pay' ||
          isDemoScanPay;

      // Simulated 2-second payment process delay that reliably completes
      await Future.delayed(const Duration(seconds: 2));

      final newOrder = OrderModel(
        id: '',
        orderNumber: '',
        studentId: appState.userId,
        studentName: appState.userName,
        canteenId: appState.selectedCanteenId,
        canteenName: appState.selectedCanteenName,
        items: List.from(appState.cart),
        totalPrice: appState.finalTotal,
        pickupSlot: appState.selectedSlot,
        status: isInstantPaid ? 'Paid & Processing' : 'Pending',
        timestamp: DateTime.now(),
        paymentMethod: paymentMethod,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        splitCount: _isSplitEnabled ? _splitPeopleCount : null,
        perPersonShare: _isSplitEnabled ? (appState.finalTotal / _splitPeopleCount) : null,
      );

      final orderId = await FirestoreService.instance.placeOrder(newOrder);

      // Reset strike counter back to 0 if 3-strike penalty was applied and paid
      final wasPenalized = appState.hasStrikePenalty;
      if (wasPenalized) {
        appState.resetStrikesAfterPayment();
      }

      if (!mounted) return;
      
      final placedOrder = FirestoreService.instance.getOrderById(orderId);
      final token = placedOrder?.tokenNumber ?? '#EATS-1042';

      AppToast.showOrderConfirmation(
        context,
        token: token,
        amount: appState.finalTotal,
        paymentMethod: paymentMethod,
      );

      appState.clearCart();

      Navigator.pushReplacementNamed(
        context,
        '/order_status',
        arguments: {'orderId': orderId},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.capReachedRed,
          content: Text('Failed to place order: $e', style: GoogleFonts.beVietnamPro()),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: const AppNavbar(activeRoute: '/checkout_slots'),
      body: StreamBuilder<Map<String, SlotCapacity>>(
        stream: FirestoreService.instance.streamSlotCapacities(),
        builder: (context, snapshot) {
          final slotCapacities = snapshot.data ?? {};

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 880;

                      final leftColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3-Strike Penalty Alert Banner
                          if (appState.hasStrikePenalty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.capReachedRedBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.capReachedRed.withValues(alpha: 0.5), width: 1.5),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.capReachedRed,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '3-Strike Unclaimed Order Penalty Active',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.capReachedRed,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.capReachedRed,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '3/3 STRIKES',
                                                style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'A 5% Surcharge Fee (₹${appState.strikePenaltyFee.toStringAsFixed(0)}) has been added to your order because 3 previous orders were left unclaimed. Completing this order will reset your strike count back to 0.',
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 13,
                                            color: AppTheme.onSurface,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          Text(
                            'Choose Your Pickup Time Slot',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select an express pickup window. Dynamic crowd control limits slots to a maximum of 20 orders to eliminate wait times.',
                            style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.onSurfaceVariant),
                          ),

                          const SizedBox(height: 20),

                          // Legend Info & Strike Simulation Tool
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.surfaceContainer),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '⚡ Fast Pick: <8 orders | 🔥 Busy: 8-19 orders | ⛔ Cap Reached: 20 orders (Locked)',
                                    style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Dynamic Slots Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              mainAxisExtent: 140,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: AppConstants.pickupSlots.length,
                            itemBuilder: (context, index) {
                              final slotTime = AppConstants.pickupSlots[index];
                              final capacity = slotCapacities[slotTime] ??
                                  SlotCapacity(
                                    slotTime: slotTime,
                                    activeOrdersCount: 0,
                                  );

                              final isSelected = appState.selectedSlot == slotTime;
                              final isAvailable = capacity.isAvailable;

                              return _buildSlotCard(
                                slotTime: slotTime,
                                capacity: capacity,
                                isSelected: isSelected,
                                isAvailable: isAvailable,
                                onSelect: () {
                                  if (isAvailable) {
                                    appState.setSelectedSlot(slotTime);
                                  }
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Payment Method Selector
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.surfaceContainer),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.payments_rounded, size: 20, color: AppTheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Select Payment Method',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    // Option 1: Online Payment (UPI/QR)
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => appState.setPaymentMethod('Online Payment (UPI/QR)'),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: (appState.selectedPaymentMethod == 'Online Payment (UPI/QR)' || appState.selectedPaymentMethod == 'Campus UPI Pay')
                                                ? AppTheme.softPeach
                                                : AppTheme.surfaceLow,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: (appState.selectedPaymentMethod == 'Online Payment (UPI/QR)' || appState.selectedPaymentMethod == 'Campus UPI Pay')
                                                  ? AppTheme.accentOrange
                                                  : AppTheme.surfaceContainer,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary, size: 22),
                                                  Icon(
                                                    (appState.selectedPaymentMethod == 'Online Payment (UPI/QR)' || appState.selectedPaymentMethod == 'Campus UPI Pay')
                                                        ? Icons.radio_button_checked
                                                        : Icons.radio_button_unchecked,
                                                    color: (appState.selectedPaymentMethod == 'Online Payment (UPI/QR)' || appState.selectedPaymentMethod == 'Campus UPI Pay')
                                                        ? AppTheme.accentOrange
                                                        : AppTheme.outline,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Online Payment (UPI/QR)',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                  color: AppTheme.primary,
                                                ),
                                              ),
                                              Text(
                                                'Live Dynamic QR & Instant Pay',
                                                style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.onSurfaceVariant),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // Option 2: Cash at Counter (30-min window)
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => appState.setPaymentMethod('Cash at Counter'),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: appState.selectedPaymentMethod == 'Cash at Counter'
                                                ? AppTheme.softPeach
                                                : AppTheme.surfaceLow,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: appState.selectedPaymentMethod == 'Cash at Counter'
                                                  ? AppTheme.accentOrange
                                                  : AppTheme.surfaceContainer,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Icon(Icons.point_of_sale_rounded, color: AppTheme.accentOrange, size: 22),
                                                  Icon(
                                                    appState.selectedPaymentMethod == 'Cash at Counter'
                                                        ? Icons.radio_button_checked
                                                        : Icons.radio_button_unchecked,
                                                    color: appState.selectedPaymentMethod == 'Cash at Counter'
                                                        ? AppTheme.accentOrange
                                                        : AppTheme.outline,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Cash at Counter',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                  color: AppTheme.primary,
                                                ),
                                              ),
                                              Text(
                                                '⏱️ 30-min pay window at Counter 1',
                                                style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.accentOrange, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Requirement 2 & 3: Dynamic Demo QR Payment Card & Simulation Trigger
                                if (appState.selectedPaymentMethod == 'Online Payment (UPI/QR)' || appState.selectedPaymentMethod == 'Campus UPI Pay')
                                  _buildDemoQrPaymentCard(appState),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Special Instructions input
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.surfaceContainer),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.notes_rounded, size: 18, color: AppTheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kitchen Special Notes (Optional)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Extra mint chutney, no ice in cold coffee, spicy...',
                                    hintStyle: GoogleFonts.beVietnamPro(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Split Bill with Friends Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.surfaceContainer),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_alt_rounded, size: 20, color: AppTheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Split Bill with Friends 👥',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _isSplitEnabled,
                                      activeColor: AppTheme.accentOrange,
                                      onChanged: (val) {
                                        setState(() {
                                          _isSplitEnabled = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                if (_isSplitEnabled) ...[
                                  const SizedBox(height: 16),
                                  const Divider(height: 1, color: AppTheme.surfaceContainer),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Number of People:',
                                        style: GoogleFonts.beVietnamPro(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: _splitPeopleCount > 2
                                                ? () => setState(() => _splitPeopleCount--)
                                                : null,
                                            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.accentOrange),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              '$_splitPeopleCount',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: _splitPeopleCount < 6
                                                ? () => setState(() => _splitPeopleCount++)
                                                : null,
                                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentOrange),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Per Person Share:',
                                        style: GoogleFonts.beVietnamPro(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '₹${(appState.finalTotal / _splitPeopleCount).toStringAsFixed(2)} / person',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.accentOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        final shareAmount = appState.finalTotal / _splitPeopleCount;
                                        final mockOrderId = 'CE-${(1000 + (DateTime.now().millisecond % 9000))}';
                                        final summaryText = 'Pay ₹${shareAmount.toStringAsFixed(2)} for Order #$mockOrderId via GPay/PhonePe';
                                        
                                        Clipboard.setData(ClipboardData(text: summaryText));
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppTheme.fastPickGreen,
                                            content: Text(
                                              'Copied split payment info: "$summaryText"',
                                              style: GoogleFonts.beVietnamPro(),
                                            ),
                                            duration: const Duration(seconds: 5),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.primary,
                                        side: const BorderSide(color: AppTheme.surfaceContainer, width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      icon: const Icon(Icons.share_rounded, size: 16),
                                      label: Text(
                                        'Share Split UPI Link / QR',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );

                      final rightColumn = Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.surfaceContainer, width: 1.5),
                          boxShadow: AppTheme.shadowLevel2,
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Summary',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrangeLight,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '${appState.totalCartItems} Items',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.accentOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            if (appState.cart.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(32),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const Icon(Icons.shopping_cart_outlined, size: 40, color: AppTheme.outline),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Your cart is empty',
                                      style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () => Navigator.pushNamed(context, '/canteen_menu'),
                                      child: const Text('Explore Menu'),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: appState.cart.length,
                                separatorBuilder: (context, index) => const Divider(height: 16, color: AppTheme.surfaceContainer),
                                itemBuilder: (context, idx) {
                                  final cartItem = appState.cart[idx];
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartItem.item.name,
                                              style: GoogleFonts.beVietnamPro(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppTheme.onSurface,
                                              ),
                                            ),
                                            Text(
                                              '₹${cartItem.item.price.toStringAsFixed(0)} × ${cartItem.quantity}',
                                              style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => appState.updateQuantity(cartItem.item, cartItem.quantity - 1),
                                            icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppTheme.outline),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${cartItem.quantity}',
                                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => appState.addToCart(cartItem.item),
                                            icon: const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.accentOrange),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 14),
                                          Text(
                                            '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),

                            const Divider(height: 24, color: AppTheme.surfaceContainer),

                            // Selected Slot & Payment Method Summary
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, color: AppTheme.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pickup Window:',
                                        style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                      ),
                                      const Spacer(),
                                      Text(
                                        appState.selectedSlot,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.payment_rounded, color: AppTheme.accentOrange, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Payment:',
                                        style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                      ),
                                      const Spacer(),
                                      Text(
                                        appState.selectedPaymentMethod,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Cost Breakdown
                            _buildCostRow('Subtotal', '₹${appState.subtotal.toStringAsFixed(0)}'),
                            const SizedBox(height: 6),
                            _buildCostRow('Platform Convenience Fee', '₹${appState.platformFee.toStringAsFixed(0)}'),
                            const SizedBox(height: 6),
                            if (appState.studentDiscount > 0)
                              _buildCostRow('Student Saver 10% Discount', '-₹${appState.studentDiscount.toStringAsFixed(0)}', isDiscount: true),
                            if (appState.hasStrikePenalty) ...[
                              const SizedBox(height: 6),
                              _buildCostRow(
                                '⚠️ 3-Strike Penalty (5% Surcharge)',
                                '+₹${appState.strikePenaltyFee.toStringAsFixed(0)}',
                                isPenalty: true,
                              ),
                            ],

                            const Divider(height: 24, color: AppTheme.surfaceContainer),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Grand Total',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                Text(
                                  '₹${appState.finalTotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentOrange,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Place Order Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isPlacingOrder || appState.cart.isEmpty ? null : () => _handlePlaceOrder(appState),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: _isPlacingOrder
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.check_circle_rounded, size: 20),
                                label: Text(
                                  _isPlacingOrder
                                      ? 'Processing...'
                                      : 'Proceed to Payment (₹${appState.finalTotal.toStringAsFixed(0)})',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          children: [
                            leftColumn,
                            const SizedBox(height: 32),
                            rightColumn,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: leftColumn),
                          const SizedBox(width: 32),
                          Expanded(flex: 5, child: rightColumn),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotCard({
    required String slotTime,
    required SlotCapacity capacity,
    required bool isSelected,
    required bool isAvailable,
    required VoidCallback onSelect,
  }) {
    Color borderColor;
    Color bgColor;

    if (!isAvailable) {
      borderColor = AppTheme.capReachedRed.withValues(alpha: 0.3);
      bgColor = AppTheme.capReachedRedBg.withValues(alpha: 0.5);
    } else if (isSelected) {
      borderColor = AppTheme.accentOrange;
      bgColor = AppTheme.softPeach;
    } else {
      borderColor = AppTheme.surfaceContainer;
      bgColor = AppTheme.surfaceWhite;
    }

    return InkWell(
      onTap: isAvailable ? onSelect : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.shadowLevel2 : AppTheme.shadowLevel1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: isAvailable ? (isSelected ? AppTheme.accentOrange : AppTheme.primary) : AppTheme.capReachedRed,
                ),
                SlotBadge(
                  status: capacity.crowdStatus,
                  activeCount: capacity.activeOrdersCount,
                  maxCap: capacity.maxCap,
                  compact: true,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slotTime,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isAvailable ? AppTheme.primary : AppTheme.outline,
                  ),
                ),
                Text(
                  isAvailable
                      ? '${capacity.activeOrdersCount}/${capacity.maxCap} active orders'
                      : 'Slot Full (Cap Reached)',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? AppTheme.onSurfaceVariant : AppTheme.capReachedRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isPenalty = false,
  }) {
    Color color = AppTheme.onSurfaceVariant;
    if (isDiscount) color = AppTheme.fastPickGreen;
    if (isPenalty) color = AppTheme.capReachedRed;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.beVietnamPro(
            fontSize: 13,
            color: color,
            fontWeight: (isDiscount || isPenalty) ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.beVietnamPro(
            fontSize: 13,
            fontWeight: (isDiscount || isPenalty) ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoQrPaymentCard(AppState appState) {
    final upiPayload = appState.getUpiPaymentPayload(appState.finalTotal);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, color: AppTheme.accentOrange, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Canteen Dynamic Payment QR',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        'Scan via UPI or simulate payment below',
                        style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.fastPickGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '🟢 LIVE UPI',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.fastPickGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Dynamic QR Code View
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.surfaceContainer),
                boxShadow: AppTheme.shadowLevel1,
              ),
              child: QrImageView(
                data: upiPayload,
                version: QrVersions.auto,
                size: 150,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dynamic Payment Details below QR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceContainer),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.outline),
                    ),
                    Text(
                      '₹${appState.finalTotal.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Merchant:',
                      style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.outline),
                    ),
                    Text(
                      appState.canteenMerchantName,
                      style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'UPI ID:',
                      style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.outline),
                    ),
                    Text(
                      appState.canteenUpiId,
                      style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accentOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Demo Payment Trigger Button
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(appState, isDemoScanPay: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.fastPickGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              icon: _isPlacingOrder
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt_rounded, size: 18),
              label: Text(
                _isPlacingOrder
                    ? 'Processing...'
                    : 'Scan & Pay (Simulate Payment) • ₹${appState.finalTotal.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
