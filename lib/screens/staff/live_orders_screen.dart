import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_navbar.dart';
import '../../widgets/order_card.dart';

class LiveOrdersScreen extends StatefulWidget {
  const LiveOrdersScreen({super.key});

  @override
  State<LiveOrdersScreen> createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends State<LiveOrdersScreen> {
  String _slotFilter = 'All Slots';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(activeRoute: '/live_orders'),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService.instance.streamOrders(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];

          final filteredOrders = _slotFilter == 'All Slots'
              ? orders
              : orders.where((o) => o.pickupSlot == _slotFilter).toList();

          final pendingOrders = filteredOrders.where((o) => o.status == 'Pending').toList();
          final preparingOrders = filteredOrders.where((o) => o.status == 'Preparing').toList();
          final readyOrders = filteredOrders.where((o) => o.status == 'Ready').toList();
          final completedOrders = filteredOrders.where((o) => o.status == 'Completed').take(6).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KDS Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.kitchen_rounded, color: AppTheme.accentOrange, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Kitchen Display System (KDS)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            Text(
                              'Kanban pipeline for kitchen prep lines & counter dispatch',
                              style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Slot Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.surfaceContainer),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _slotFilter,
                          icon: const Icon(Icons.filter_list_rounded, color: AppTheme.primary, size: 18),
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primary),
                          onChanged: (val) {
                            if (val != null) setState(() => _slotFilter = val);
                          },
                          items: ['All Slots', ...AppConstants.pickupSlots].map((slot) {
                            return DropdownMenuItem<String>(
                              value: slot,
                              child: Text(slot == 'All Slots' ? '🕒 All Slots' : '🕒 $slot Slot'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Kanban 3-Column Pipeline
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: Pending (New)
                      Expanded(
                        child: _buildKDSColumn(
                          title: 'New Orders (Pending)',
                          count: pendingOrders.length,
                          color: AppTheme.busyOrange,
                          bgColor: AppTheme.busyOrangeBg,
                          orders: pendingOrders,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Column 2: Preparing (Cooking)
                      Expanded(
                        child: _buildKDSColumn(
                          title: 'In Preparation',
                          count: preparingOrders.length,
                          color: AppTheme.preparingBlue,
                          bgColor: AppTheme.preparingBlueBg,
                          orders: preparingOrders,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Column 3: Ready (Counter Pickup)
                      Expanded(
                        child: _buildKDSColumn(
                          title: 'Ready for Pickup',
                          count: readyOrders.length,
                          color: AppTheme.fastPickGreen,
                          bgColor: AppTheme.fastPickGreenBg,
                          orders: readyOrders,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Column 4: Completed
                      Expanded(
                        child: _buildKDSColumn(
                          title: 'Recently Handed Over',
                          count: completedOrders.length,
                          color: AppTheme.outline,
                          bgColor: AppTheme.surfaceLow,
                          orders: completedOrders,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKDSColumn({
    required String title,
    required int count,
    required Color color,
    required Color bgColor,
    required List<OrderModel> orders,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainer),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      'No orders in this stage',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.outline),
                    ),
                  )
                : ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      return OrderCard(order: orders[idx], isCompact: true);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
