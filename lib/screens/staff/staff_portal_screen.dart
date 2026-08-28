import 'package:flutter/material.dart';
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
import '../../widgets/batch_summary_card.dart';
import '../../widgets/order_card.dart';
import '../../widgets/slot_badge.dart';

class StaffPortalScreen extends StatefulWidget {
  const StaffPortalScreen({super.key});

  @override
  State<StaffPortalScreen> createState() => _StaffPortalScreenState();
}

class _StaffPortalScreenState extends State<StaffPortalScreen> {
  String _selectedStatusFilter = 'All Active';
  String _selectedSlotFilter = 'All Slots';

  late TextEditingController _upiController;
  late TextEditingController _merchantController;
  bool _isQrSettingsExpanded = true;
  bool _initializedControllers = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedControllers) {
      final appState = Provider.of<AppState>(context, listen: false);
      _upiController = TextEditingController(text: appState.canteenUpiId);
      _merchantController = TextEditingController(text: appState.canteenMerchantName);
      _initializedControllers = true;
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AppNavbar(activeRoute: '/staff_portal'),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService.instance.streamOrders(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];

          final activeOrders = orders.where((o) {
            return o.status != 'Completed' &&
                !o.status.startsWith('Cancelled') &&
                o.status != 'Unclaimed';
          }).toList();

          final pendingOrders = orders.where((o) => o.status == 'Pending').toList();
          final preparingOrders = orders.where((o) => o.status == 'Preparing').toList();
          final readyOrders = orders.where((o) => o.status == 'Ready').toList();
          final completedOrders = orders.where((o) => o.status == 'Completed').toList();
          final unclaimedOrders = orders.where((o) => o.status == 'Unclaimed').toList();

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Quick Metric Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Kitchen Operations & Crowd Control',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.fastPickGreenBg,
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(color: AppTheme.fastPickGreen.withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.fastPickGreen,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'FIRESTORE LIVE SYNC',
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.fastPickGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Central Canteen A Kitchen Terminal • Active Order Batching & Queue Throttle',
                                style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/live_orders'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.kitchen_rounded, size: 18),
                                label: const Text('Open KDS Board'),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Metrics Cards Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildMetricCard(
                                title: 'Active in Queue',
                                value: '${activeOrders.length}',
                                subtext: '${pendingOrders.length} New, ${preparingOrders.length} Cooking',
                                icon: Icons.receipt_long_rounded,
                                color: AppTheme.primary,
                              ),
                              _buildMetricCard(
                                title: 'Ready for Pickup',
                                value: '${readyOrders.length}',
                                subtext: 'At Counter #2',
                                icon: Icons.check_circle_rounded,
                                color: AppTheme.fastPickGreen,
                              ),
                              _buildMetricCard(
                                title: 'Avg Prep Time',
                                value: '6.4 mins',
                                subtext: 'Within Target (<10 mins)',
                                icon: Icons.timer_outlined,
                                color: AppTheme.secondary,
                              ),
                              _buildMetricCard(
                                title: 'Slot Capacity Alert',
                                value: '1:15 PM Busy',
                                subtext: '14/20 Orders Allocated',
                                icon: Icons.local_fire_department_rounded,
                                color: AppTheme.accentOrange,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Requirement 1: Payment QR Settings Section
                      _buildPaymentQrSettingsCard(appState),

                      const SizedBox(height: 28),

                      // TOP BATCH SUMMARY WIDGET
                      BatchSummaryCard(orders: orders),

                      const SizedBox(height: 28),

                      // Dynamic Crowd Control Capacity Monitor
                      _buildSlotCapacityManager(),

                      const SizedBox(height: 32),

                      // Orders Stream Header & Status Tabs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Incoming Order Feed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceWhite,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.surfaceContainer),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedSlotFilter,
                                    isDense: true,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedSlotFilter = val);
                                    },
                                    items: ['All Slots', ...AppConstants.pickupSlots].map((slot) {
                                      return DropdownMenuItem(
                                        value: slot,
                                        child: Text(slot),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Status Tabs Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All Active', activeOrders.length),
                            const SizedBox(width: 8),
                            _buildFilterChip('Pending', pendingOrders.length),
                            const SizedBox(width: 8),
                            _buildFilterChip('Preparing', preparingOrders.length),
                            const SizedBox(width: 8),
                            _buildFilterChip('Ready', readyOrders.length),
                            const SizedBox(width: 8),
                            _buildFilterChip('Completed', completedOrders.length),
                            const SizedBox(width: 8),
                            _buildFilterChip('Unclaimed', unclaimedOrders.length),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Filtered Orders Grid/List
                      Builder(
                        builder: (context) {
                          List<OrderModel> filteredList;

                          if (_selectedStatusFilter == 'All Active') {
                            filteredList = activeOrders;
                          } else if (_selectedStatusFilter == 'Unclaimed') {
                            filteredList = unclaimedOrders;
                          } else {
                            filteredList = orders.where((o) => o.status == _selectedStatusFilter).toList();
                          }

                          if (_selectedSlotFilter != 'All Slots') {
                            filteredList = filteredList.where((o) => o.pickupSlot == _selectedSlotFilter).toList();
                          }

                          if (filteredList.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(48),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.surfaceContainer),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox_rounded, size: 48, color: AppTheme.outline.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No orders match filter "$_selectedStatusFilter" for "$_selectedSlotFilter"',
                                    style: GoogleFonts.beVietnamPro(fontSize: 15, color: AppTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            );
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 900
                                  ? 2
                                  : 1;

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 310,
                                ),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  return OrderCard(order: filteredList[index]);
                                },
                              );
                            },
                          );
                        },
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

  // Requirement 1: Payment QR Settings Widget
  Widget _buildPaymentQrSettingsCard(AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: AppTheme.shadowLevel1,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Payment QR Settings',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.fastPickGreenBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '🟢 ACTIVE & SYNCED',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.fastPickGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Configure Canteen Business UPI ID & Live Counter Payment QR',
                        style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => setState(() => _isQrSettingsExpanded = !_isQrSettingsExpanded),
                icon: Icon(
                  _isQrSettingsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.primary,
                ),
                tooltip: _isQrSettingsExpanded ? 'Collapse' : 'Expand',
              ),
            ],
          ),

          if (_isQrSettingsExpanded) ...[
            const Divider(height: 24, color: AppTheme.surfaceContainer),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;

                final qrPreview = Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceContainer),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.shadowLevel1,
                        ),
                        child: QrImageView(
                          data: appState.getUpiPaymentPayload(150.0),
                          version: QrVersions.auto,
                          size: 130,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Live Checkout Dynamic QR Preview',
                        style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.outline),
                      ),
                    ],
                  ),
                );

                final formFields = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merchant / Payee Name',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _merchantController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Campus Canteen 1',
                        filled: true,
                        fillColor: AppTheme.surfaceLow,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.surfaceContainer),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.surfaceContainer),
                        ),
                        prefixIcon: const Icon(Icons.storefront_rounded, size: 18, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Business UPI ID',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _upiController,
                      decoration: InputDecoration(
                        hintText: 'e.g., campuseats.canteen1@upi',
                        filled: true,
                        fillColor: AppTheme.surfaceLow,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.surfaceContainer),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.surfaceContainer),
                        ),
                        prefixIcon: const Icon(Icons.alternate_email_rounded, size: 18, color: AppTheme.accentOrange),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        appState.updatePaymentSettings(
                          upiId: _upiController.text,
                          merchantName: _merchantController.text,
                        );
                        AppToast.showSuccess(
                          context,
                          'Payment QR updated: ${_upiController.text} (${_merchantController.text})',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      label: Text(
                        'Save & Sync QR Settings',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ],
                );

                if (isMobile) {
                  return Column(
                    children: [
                      qrPreview,
                      const SizedBox(height: 16),
                      formFields,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    qrPreview,
                    const SizedBox(width: 24),
                    Expanded(child: formFields),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainer),
        boxShadow: AppTheme.shadowLevel1,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
                ),
                Text(
                  subtext,
                  style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCapacityManager() {
    return StreamBuilder<Map<String, SlotCapacity>>(
      stream: FirestoreService.instance.streamSlotCapacities(),
      builder: (context, snapshot) {
        final capacities = snapshot.data ?? {};

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.surfaceContainer),
            boxShadow: AppTheme.shadowLevel1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Live Pickup Slot Crowding & Manual Cap Override',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Auto-throttles at 20 orders/slot',
                    style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppConstants.pickupSlots.map((slot) {
                    final cap = capacities[slot] ?? SlotCapacity(slotTime: slot, activeOrdersCount: 0);

                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cap.isAvailable ? AppTheme.surfaceLow : AppTheme.capReachedRedBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cap.isAvailable ? AppTheme.surfaceContainer : AppTheme.capReachedRed,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                slot,
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primary),
                              ),
                              SlotBadge(status: cap.crowdStatus, compact: true),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${cap.activeOrdersCount}/20 slots',
                                style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
                              ),
                              InkWell(
                                onTap: () => FirestoreService.instance.toggleSlotLock(slot),
                                child: Text(
                                  cap.isManuallyLocked ? 'Unlock' : 'Lock',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: cap.isManuallyLocked ? AppTheme.fastPickGreen : AppTheme.capReachedRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSel = _selectedStatusFilter == label;

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSel,
      onSelected: (val) {
        if (val) setState(() => _selectedStatusFilter = label);
      },
      selectedColor: AppTheme.primary,
      labelStyle: GoogleFonts.beVietnamPro(
        color: isSel ? Colors.white : AppTheme.onSurfaceVariant,
        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      backgroundColor: AppTheme.surfaceWhite,
      side: BorderSide(
        color: isSel ? AppTheme.primary : AppTheme.surfaceContainer,
      ),
    );
  }
}
