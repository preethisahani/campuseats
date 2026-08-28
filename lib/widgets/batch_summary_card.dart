import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../config/constants.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class BatchSummaryCard extends StatefulWidget {
  final List<OrderModel> orders;

  const BatchSummaryCard({
    super.key,
    required this.orders,
  });

  @override
  State<BatchSummaryCard> createState() => _BatchSummaryCardState();
}

class _BatchSummaryCardState extends State<BatchSummaryCard> {
  String _selectedSlot = '1:15 PM';

  @override
  Widget build(BuildContext context) {
    // Aggregate item counts for selected slot
    final summary = FirestoreService.aggregateItemQuantities(
      widget.orders,
      slotFilter: _selectedSlot == 'All Slots' ? null : _selectedSlot,
      statusFilter: null,
    );

    final totalItemsCount = summary.values.fold(0, (sum, count) => sum + count);
    final activeOrdersInSlot = widget.orders.where((o) {
      if (_selectedSlot != 'All Slots' && o.pickupSlot != _selectedSlot) return false;
      return o.status != 'Completed' && o.status != 'Cancelled';
    }).length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainer, width: 1.5),
        boxShadow: AppTheme.shadowLevel2,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with slot selector
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.soup_kitchen_rounded, color: AppTheme.accentOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kitchen Batch Summary',
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
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            'LIVE BATCHING',
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
                      'Aggregated item demand for synchronized high-volume preparation',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Slot Selector Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceContainer),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSlot,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSlot = val);
                      }
                    },
                    items: ['All Slots', ...AppConstants.pickupSlots].map((slot) {
                      return DropdownMenuItem<String>(
                        value: slot,
                        child: Text(slot == 'All Slots' ? '🌐 All Pickup Slots' : '🕒 $slot Slot'),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Overview metrics bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_rounded, size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'Active Orders in $_selectedSlot: ',
                      style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                    ),
                    Text(
                      '$activeOrdersInSlot Orders',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.fastfood_rounded, size: 16, color: AppTheme.accentOrange),
                    const SizedBox(width: 6),
                    Text(
                      'Total Items to Cook: ',
                      style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                    ),
                    Text(
                      '$totalItemsCount Items',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.accentOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Item Demand Grid
          if (summary.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No pending food items for $_selectedSlot.',
                style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.outline),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: summary.entries.map((entry) {
                final isHeavy = entry.value >= 10;
                return Container(
                  width: 260,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isHeavy ? AppTheme.accentOrangeLight : AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHeavy ? AppTheme.accentOrange.withValues(alpha: 0.4) : AppTheme.surfaceContainer,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isHeavy ? AppTheme.accentOrange : AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${entry.value}x',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry.key,
                              style: GoogleFonts.beVietnamPro(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isHeavy ? '🔥 High Demand Batch' : 'Regular Batch',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isHeavy ? AppTheme.accentOrange : AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
