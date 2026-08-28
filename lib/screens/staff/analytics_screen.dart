import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../widgets/app_navbar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(activeRoute: '/analytics'),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Dining Analytics & Crowd Insights',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Operational performance, slot crowd distribution, and kitchen throughput metrics.',
                    style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.onSurfaceVariant),
                  ),

                  const SizedBox(height: 28),

                  // Key Performance Indicators (KPIs)
                  Row(
                    children: [
                      Expanded(
                        child: _buildKPICard('Today Revenue', '₹24,850', '+18% vs last week', Icons.currency_rupee_rounded, AppTheme.fastPickGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard('Orders Handled', '312', '98.2% on-time pickup', Icons.receipt_long_rounded, AppTheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard('Queue Time Saved', '14.2 mins', 'Avg student wait: 2.1m', Icons.timer_rounded, AppTheme.secondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKPICard('Slots at Capacity', '4 slots', 'Capped at 20 orders', Icons.lock_clock_rounded, AppTheme.accentOrange),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Peak Hour & Slot Crowd Distribution
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceContainer),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Slot Demand Distribution (Lunch Rush)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSlotBar('12:30 PM', 12, 20, AppTheme.fastPickGreen),
                        const SizedBox(height: 12),
                        _buildSlotBar('12:45 PM', 16, 20, AppTheme.busyOrange),
                        const SizedBox(height: 12),
                        _buildSlotBar('1:00 PM', 18, 20, AppTheme.busyOrange),
                        const SizedBox(height: 12),
                        _buildSlotBar('1:15 PM (Peak)', 20, 20, AppTheme.capReachedRed),
                        const SizedBox(height: 12),
                        _buildSlotBar('1:30 PM', 17, 20, AppTheme.busyOrange),
                        const SizedBox(height: 12),
                        _buildSlotBar('1:45 PM', 10, 20, AppTheme.fastPickGreen),
                        const SizedBox(height: 12),
                        _buildSlotBar('2:00 PM', 6, 20, AppTheme.fastPickGreen),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Top Ordered Dishes
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.surfaceContainer),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Most Ordered Items Today',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPopularItemRow('1', 'Crispy Aloo Samosa (2 pcs)', 142, '₹3,550'),
                        const Divider(height: 16, color: AppTheme.surfaceContainer),
                        _buildPopularItemRow('2', 'Special Masala Chai', 118, '₹1,770'),
                        const Divider(height: 16, color: AppTheme.surfaceContainer),
                        _buildPopularItemRow('3', 'Paneer Tikka Kathi Roll', 68, '₹6,120'),
                        const Divider(height: 16, color: AppTheme.surfaceContainer),
                        _buildPopularItemRow('4', 'Classic Butter Pav Bhaji', 54, '₹4,320'),
                        const Divider(height: 16, color: AppTheme.surfaceContainer),
                        _buildPopularItemRow('5', 'Iced Cold Coffee', 48, '₹2,160'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, String sub, IconData icon, Color color) {
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
              Text(
                title,
                style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.beVietnamPro(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotBar(String slot, int count, int max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(slot, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 13)),
            Text('$count / $max Orders (${(count / max * 100).toInt()}%)', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: count / max,
            backgroundColor: AppTheme.surfaceLow,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularItemRow(String rank, String name, int orders, String revenue) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: rank == '1' ? AppTheme.accentOrange : AppTheme.surfaceLow,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: rank == '1' ? Colors.white : AppTheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(name, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        Text('$orders orders', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant)),
        const SizedBox(width: 24),
        Text(revenue, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primary)),
      ],
    );
  }
}
