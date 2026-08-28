import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import 'app_toast.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isCompact;

  const OrderCard({
    super.key,
    required this.order,
    this.isCompact = false,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppTheme.busyOrange;
      case 'Paid & Processing':
        return AppTheme.preparingBlue;
      case 'Preparing':
        return AppTheme.preparingBlue;
      case 'Ready':
        return AppTheme.fastPickGreen;
      case 'Completed':
        return AppTheme.outline;
      case 'Unclaimed':
      case 'Cancelled - Payment Timeout':
        return AppTheme.capReachedRed;
      default:
        return AppTheme.primary;
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Pending':
        return AppTheme.busyOrangeBg;
      case 'Paid & Processing':
        return AppTheme.preparingBlueBg;
      case 'Preparing':
        return AppTheme.preparingBlueBg;
      case 'Ready':
        return AppTheme.fastPickGreenBg;
      case 'Completed':
        return AppTheme.surfaceLow;
      case 'Unclaimed':
      case 'Cancelled - Payment Timeout':
        return AppTheme.capReachedRedBg;
      default:
        return AppTheme.surfaceLow;
    }
  }

  void _showAdminPaymentModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.fastPickGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.point_of_sale_rounded, color: AppTheme.fastPickGreen, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Counter Payment',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      'Verify student cash hand-off at counter',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Container(
            width: 480,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceContainer),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Received',
                            style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.white70),
                          ),
                          Text(
                            '₹${order.totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Token ${order.tokenNumber}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildModalDetailRow('Order ID', order.id),
                const SizedBox(height: 8),
                _buildModalDetailRow('User', '${order.studentName} (${order.studentId})'),
                const SizedBox(height: 8),
                _buildModalDetailRow('Token', order.tokenNumber),
                const SizedBox(height: 8),
                _buildModalDetailRow('Pickup Window', order.pickupSlot),
                const SizedBox(height: 8),
                _buildModalDetailRow('Items', order.itemsSummary),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.outline),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                FirestoreService.instance.confirmCashPayment(order.id);
                AppToast.showAdminPaymentReceived(
                  context,
                  token: order.tokenNumber,
                  amount: order.totalPrice,
                  studentName: order.studentName,
                  orderId: order.id,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.fastPickGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                'Confirm & Mark Done',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.outline),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusBg = _getStatusBg(order.status);
    final timeStr = DateFormat('hh:mm a').format(order.timestamp);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.status == 'Ready'
              ? AppTheme.fastPickGreen.withValues(alpha: 0.4)
              : order.status == 'Preparing'
                  ? AppTheme.secondary.withValues(alpha: 0.3)
                  : order.status == 'Unclaimed'
                      ? AppTheme.capReachedRed.withValues(alpha: 0.5)
                      : AppTheme.surfaceContainer,
          width: (order.status == 'Ready' || order.status == 'Unclaimed') ? 2 : 1,
        ),
        boxShadow: AppTheme.shadowLevel1,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Token, Slot, Payment Tag, Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Token: ${order.tokenNumber}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceContainer),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 13, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          order.pickupSlot,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Payment Tag: "Paid" vs "Cash Yet to Pay"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.paymentStatusBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order.isPaid ? Icons.check_circle_outline_rounded : Icons.point_of_sale_rounded,
                          size: 13,
                          color: order.paymentStatusBadgeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.paymentStatusBadgeText,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: order.paymentStatusBadgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      order.status.toUpperCase(),
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Student details, strikes & time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_rounded, size: 15, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Text(
                    '${order.studentName} (${order.studentId})',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  StreamBuilder<int>(
                    stream: FirestoreService.instance.streamUserStrikes(order.studentId),
                    builder: (context, strikeSnap) {
                      final strikes = strikeSnap.data ?? 0;
                      if (strikes == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: strikes >= 3 ? AppTheme.capReachedRed : AppTheme.busyOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$strikes Strikes',
                          style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Text(
                'Placed at $timeStr',
                style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.outline),
              ),
            ],
          ),

          const Divider(height: 16, color: AppTheme.surfaceContainer),

          // Items list
          ...order.items.map((cartItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cartItem.quantity}x',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.item.name,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        if (cartItem.specialInstructions != null && cartItem.specialInstructions!.isNotEmpty)
                          Text(
                            'Note: ${cartItem.specialInstructions}',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // Total Price & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.outline),
                  ),
                  Text(
                    '₹${order.totalPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Confirm & Mark Done button for unpaid cash orders
                  if (!order.isPaid && order.status == 'Pending')
                    ElevatedButton.icon(
                      onPressed: () => _showAdminPaymentModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.fastPickGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: Text(
                        'Confirm & Mark Done',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    )
                  else if (order.status == 'Pending' || order.status == 'Paid & Processing')
                    ElevatedButton.icon(
                      onPressed: () => FirestoreService.instance.updateOrderStatus(order.id, 'Preparing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.preparingBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.soup_kitchen_rounded, size: 16),
                      label: Text(
                        'Start Preparing',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    )
                  else if (order.status == 'Preparing')
                    ElevatedButton.icon(
                      onPressed: () => FirestoreService.instance.updateOrderStatus(order.id, 'Ready'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.fastPickGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      label: Text(
                        'Mark Ready',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    )
                  else if (order.status == 'Ready') ...[
                    ElevatedButton.icon(
                      onPressed: () => FirestoreService.instance.updateOrderStatus(order.id, 'Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: Text(
                        'Hand Over',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        FirestoreService.instance.markOrderUnclaimed(order.id, order.studentId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.capReachedRed,
                            content: Text(
                              'Order ${order.tokenNumber} marked Unclaimed! 1 Strike added to ${order.studentName}.',
                              style: GoogleFonts.beVietnamPro(),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.capReachedRed,
                        side: const BorderSide(color: AppTheme.capReachedRed),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.warning_amber_rounded, size: 16),
                      label: Text(
                        'Unclaimed',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ] else if (order.status == 'Unclaimed')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.capReachedRedBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Unclaimed (+1 Strike)',
                        style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.capReachedRed),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.status,
                        style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.outline),
                      ),
                    ),

                  const SizedBox(width: 4),

                  // Menu to pick custom status or mark unclaimed
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.outline),
                    onSelected: (action) {
                      if (action == 'confirm_cash') {
                        _showAdminPaymentModal(context);
                      } else if (action == 'unclaimed') {
                        FirestoreService.instance.markOrderUnclaimed(order.id, order.studentId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.capReachedRed,
                            content: Text(
                              'Order marked Unclaimed! Strike count incremented for ${order.studentId}.',
                              style: GoogleFonts.beVietnamPro(),
                            ),
                          ),
                        );
                      } else if (action == 'cancel_timeout') {
                        FirestoreService.instance.cancelOrderPaymentTimeout(order.id);
                      } else {
                        FirestoreService.instance.updateOrderStatus(order.id, action);
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (!order.isPaid)
                        const PopupMenuItem(value: 'confirm_cash', child: Text('💵 Confirm & Mark Done')),
                      const PopupMenuItem(value: 'Pending', child: Text('Set: Pending')),
                      const PopupMenuItem(value: 'Paid & Processing', child: Text('Set: Paid & Processing')),
                      const PopupMenuItem(value: 'Preparing', child: Text('Set: Preparing')),
                      const PopupMenuItem(value: 'Ready', child: Text('Set: Ready')),
                      const PopupMenuItem(value: 'Completed', child: Text('Set: Completed')),
                      const PopupMenuItem(value: 'unclaimed', child: Text('⚠️ Mark Unclaimed (+1 Strike)')),
                      const PopupMenuItem(value: 'cancel_timeout', child: Text('⏱️ Trigger Payment Timeout')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
