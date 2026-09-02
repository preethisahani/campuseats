import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/order_model.dart';
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_navbar.dart';

class OrderStatusScreen extends StatelessWidget {
  final String? orderId;

  const OrderStatusScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: const AppNavbar(activeRoute: '/order_status'),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService.instance.streamOrders(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          OrderModel? activeOrder;

          if (orderId != null && orderId!.isNotEmpty) {
            activeOrder = orders.cast<OrderModel?>().firstWhere(
                  (o) => o?.id == orderId,
                  orElse: () => null,
                );
          }

          // Fallback to latest student order if not specified
          activeOrder ??= orders.cast<OrderModel?>().firstWhere(
                (o) => o?.studentId == appState.userId && o?.status != 'Completed' && !o!.status.startsWith('Cancelled'),
                orElse: () => orders.isNotEmpty ? orders.first : null,
              );

          if (activeOrder == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 64, color: AppTheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Orders Found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You do not have any orders currently in queue.',
                      style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/canteen_menu'),
                      icon: const Icon(Icons.restaurant_menu_rounded),
                      label: const Text('Order Now'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🎉 Order Placed Successfully!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                'Real-time status synced with kitchen display system',
                                style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Order ID: ${activeOrder.orderNumber}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Feature 1: Cash at Counter 30-Min Countdown Timer Banner
                      if (activeOrder.isCashAtCounter && activeOrder.status == 'Pending')
                        _CashPaymentCountdownBanner(order: activeOrder),

                      // Cancelled or Unclaimed Status Banner
                      if (activeOrder.isCancelledTimeout)
                        _buildTimeoutCancelledBanner(context, activeOrder)
                      else if (activeOrder.isUnclaimed)
                        _buildUnclaimedBanner(activeOrder),

                      const SizedBox(height: 20),

                      // Status Progress Stepper Card
                      _buildStatusProgressCard(activeOrder),

                      const SizedBox(height: 24),

                      // Estimated Waiting Time Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.softPeach,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.5), width: 1.5),
                          boxShadow: AppTheme.shadowLevel1,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Waiting Time',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '15–20 minutes. Please collect your order from the canteen counter.',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 13,
                                      color: AppTheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // QR Pickup Token Card
                      _buildPickupTokenCard(activeOrder),

                      const SizedBox(height: 24),

                      // Itemized Receipt Card
                      _buildReceiptCard(activeOrder),

                      const SizedBox(height: 32),

                      // Bottom actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/home'),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Return to Home'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/canteen_menu'),
                            icon: const Icon(Icons.add_shopping_cart_rounded),
                            label: const Text('Order More Items'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeoutCancelledBanner(BuildContext context, OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.capReachedRedBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.capReachedRed, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.capReachedRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timer_off_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Cancelled — Payment Timeout',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.capReachedRed,
                      ),
                    ),
                    Text(
                      '30-minute cash payment window at Counter 1 expired',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The reserved food items for this order have been automatically re-released back into the live canteen inventory and slot capacity has been freed.',
            style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurface, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/canteen_menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.capReachedRed,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Place New Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnclaimedBanner(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.capReachedRedBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.capReachedRed, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.capReachedRed, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Marked Unclaimed / Abandoned',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.capReachedRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This order was prepared but was not collected within the designated pickup window. 1 Strike has been added to your student account under the 3-Strike Unclaimed Order Policy.',
                  style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurface, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgressCard(OrderModel order) {
    int currentStep = 1;
    if (order.status == 'Preparing') currentStep = 2;
    if (order.status == 'Ready' || order.status == 'Completed') currentStep = 3;

    final isCancelled = order.status.startsWith('Cancelled') || order.status == 'Unclaimed';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: order.status == 'Ready'
              ? AppTheme.fastPickGreen
              : isCancelled
                  ? AppTheme.capReachedRed
                  : AppTheme.surfaceContainer,
          width: (order.status == 'Ready' || isCancelled) ? 2 : 1,
        ),
        boxShadow: AppTheme.shadowLevel2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: order.status == 'Ready'
                      ? AppTheme.fastPickGreenBg
                      : isCancelled
                          ? AppTheme.capReachedRedBg
                          : AppTheme.accentOrangeLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order.status == 'Ready'
                      ? Icons.check_circle_rounded
                      : isCancelled
                          ? Icons.cancel_rounded
                          : Icons.soup_kitchen_rounded,
                  color: order.status == 'Ready'
                      ? AppTheme.fastPickGreen
                      : isCancelled
                          ? AppTheme.capReachedRed
                          : AppTheme.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.status == 'Ready'
                          ? '🎉 Order is Ready for Pickup!'
                          : order.status == 'Preparing'
                              ? '🍳 Kitchen is Preparing Your Meal'
                              : isCancelled
                                  ? '❌ ${order.status}'
                                  : '⏳ Order Placed Successfully',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: order.status == 'Ready'
                            ? AppTheme.fastPickGreen
                            : isCancelled
                                ? AppTheme.capReachedRed
                                : AppTheme.primary,
                      ),
                    ),
                    Text(
                      order.status == 'Ready'
                          ? 'Please head to Counter #2 at ${order.canteenName}'
                          : isCancelled
                              ? 'This order is no longer in the active queue'
                              : 'Target pickup window is ${order.pickupSlot}',
                      style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Stepper bar
          Row(
            children: [
              _buildStepNode(
                stepNum: 1,
                title: 'Order Placed',
                isActive: currentStep >= 1,
                isCurrent: currentStep == 1,
                isCancelled: isCancelled,
              ),
              _buildStepConnector(isActive: currentStep >= 2),
              _buildStepNode(
                stepNum: 2,
                title: 'Preparing',
                isActive: currentStep >= 2,
                isCurrent: currentStep == 2,
                isCancelled: isCancelled,
              ),
              _buildStepConnector(isActive: currentStep >= 3),
              _buildStepNode(
                stepNum: 3,
                title: 'Ready for Pickup',
                isActive: currentStep >= 3,
                isCurrent: currentStep == 3,
                isCancelled: isCancelled,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required int stepNum,
    required String title,
    required bool isActive,
    required bool isCurrent,
    bool isCancelled = false,
  }) {
    Color circleColor = AppTheme.surfaceContainer;
    Color iconColor = AppTheme.outline;

    if (isCancelled && isCurrent) {
      circleColor = AppTheme.capReachedRed;
      iconColor = Colors.white;
    } else if (isActive) {
      circleColor = isCurrent ? AppTheme.accentOrange : AppTheme.primary;
      iconColor = Colors.white;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent ? [BoxShadow(color: circleColor.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)] : null,
          ),
          alignment: Alignment.center,
          child: isActive
              ? (isCurrent
                  ? Text('$stepNum', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: iconColor))
                  : const Icon(Icons.check, color: Colors.white, size: 18))
              : Text('$stepNum', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: iconColor)),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
            color: isCurrent ? AppTheme.primary : AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
        color: isActive ? AppTheme.primary : AppTheme.surfaceContainer,
      ),
    );
  }

  Widget _buildPickupTokenCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainer),
        boxShadow: AppTheme.shadowLevel1,
      ),
      child: Row(
        children: [
          // QR Code representation
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceContainer),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 84, color: AppTheme.primary),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TOKEN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EXPRESS COUNTER PICKUP',
                        style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.paymentStatusBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: order.paymentStatusBadgeColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'Token: ${order.tokenNumber} | Status: ${order.paymentStatusBadgeText}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: order.paymentStatusBadgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Pickup Window: ${order.pickupSlot}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Show this QR token to the staff at Counter 2 (${order.canteenName}) to collect your order instantly.',
                  style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.payment_rounded, size: 14, color: AppTheme.accentOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Payment: ${order.paymentMethod ?? 'Campus UPI Pay'} (${order.paymentStatusBadgeText})',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(OrderModel order) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                dateFormat.format(order.timestamp),
                style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.surfaceContainer),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}x',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.item.name,
                          style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.onSurface),
                        ),
                        if (item.specialInstructions != null && item.specialInstructions!.isNotEmpty)
                          Text(
                            'Note: ${item.specialInstructions}',
                            style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primary),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.surfaceContainer),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Text(
                '₹${order.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stateful Countdown Timer Banner for Cash at Counter Orders (30-Minute Timeout)
class _CashPaymentCountdownBanner extends StatefulWidget {
  final OrderModel order;

  const _CashPaymentCountdownBanner({required this.order});

  @override
  State<_CashPaymentCountdownBanner> createState() => _CashPaymentCountdownBannerState();
}

class _CashPaymentCountdownBannerState extends State<_CashPaymentCountdownBanner> {
  Timer? _timer;
  late Duration _remaining;
  bool _hasTriggeredTimeout = false;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _startTimer();
  }

  void _calculateRemaining() {
    final deadline = widget.order.timestamp.add(const Duration(minutes: 30));
    final now = DateTime.now();
    _remaining = deadline.difference(now);

    if (_remaining.isNegative) {
      _remaining = Duration.zero;
      _onTimeout();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        final deadline = widget.order.timestamp.add(const Duration(minutes: 30));
        _remaining = deadline.difference(DateTime.now());

        if (_remaining.isNegative || _remaining == Duration.zero) {
          _remaining = Duration.zero;
          timer.cancel();
          _onTimeout();
        }
      });
    });
  }

  void _onTimeout() {
    if (!_hasTriggeredTimeout && widget.order.status == 'Pending') {
      _hasTriggeredTimeout = true;
      FirestoreService.instance.cancelOrderPaymentTimeout(widget.order.id);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final totalSeconds = _remaining.inSeconds.clamp(0, 1800);
    final progress = totalSeconds / 1800.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.softPeach,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentOrange, width: 1.5),
        boxShadow: AppTheme.shadowLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Cash Payment Pending',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '30-MIN LIMIT',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Please pay ₹${widget.order.totalPrice.toStringAsFixed(0)} at Counter 1 within $minutes:$seconds mins to confirm your order.',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$minutes:$seconds',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              color: progress < 0.2 ? AppTheme.capReachedRed : AppTheme.accentOrange,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'If unpaid, items are released back to live inventory automatically.',
                style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.onSurfaceVariant),
              ),
              // Cashier Confirmation simulation button
              InkWell(
                onTap: () {
                  FirestoreService.instance.updateOrderStatus(widget.order.id, 'Preparing');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.fastPickGreen,
                      content: Text('Cash payment verified! Order moved to Preparing.', style: GoogleFonts.beVietnamPro()),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Mark Paid (Cashier Demo)',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
