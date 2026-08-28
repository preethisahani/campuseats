import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/slot_capacity.dart';

class SlotBadge extends StatelessWidget {
  final SlotCrowdStatus status;
  final int activeCount;
  final int maxCap;
  final bool compact;

  const SlotBadge({
    super.key,
    required this.status,
    this.activeCount = 0,
    this.maxCap = 20,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData icon;
    String label;

    switch (status) {
      case SlotCrowdStatus.fastPick:
        bg = AppTheme.fastPickGreenBg;
        fg = AppTheme.fastPickGreen;
        border = AppTheme.fastPickGreen.withValues(alpha: 0.3);
        icon = Icons.bolt_rounded;
        label = compact ? 'Fast Pick' : '⚡ Fast Pick (Low Queue)';
        break;
      case SlotCrowdStatus.busy:
        bg = AppTheme.busyOrangeBg;
        fg = AppTheme.busyOrange;
        border = AppTheme.busyOrange.withValues(alpha: 0.4);
        icon = Icons.local_fire_department_rounded;
        label = compact ? 'Busy ($activeCount/$maxCap)' : '🔥 Busy ($activeCount/$maxCap Orders)';
        break;
      case SlotCrowdStatus.capReached:
        bg = AppTheme.capReachedRedBg;
        fg = AppTheme.capReachedRed;
        border = AppTheme.capReachedRed.withValues(alpha: 0.4);
        icon = Icons.lock_clock_rounded;
        label = compact ? 'Cap Reached (20/20)' : '⛔ Cap Reached (Full)';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 16, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
