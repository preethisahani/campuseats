import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String studentId;
  final String studentName;
  final String canteenId;
  final String canteenName;
  final List<CartItem> items;
  final double totalPrice;
  final String pickupSlot;
  final String status; // 'Pending', 'Paid & Processing', 'Preparing', 'Ready', 'Completed', 'Cancelled - Payment Timeout', 'Unclaimed'
  final DateTime timestamp;
  final String? paymentMethod;
  final String? notes;
  final int? splitCount;
  final double? perPersonShare;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.studentId,
    required this.studentName,
    required this.canteenId,
    required this.canteenName,
    required this.items,
    required this.totalPrice,
    required this.pickupSlot,
    required this.status,
    required this.timestamp,
    this.paymentMethod = 'Campus UPI Pay',
    this.notes,
    this.splitCount,
    this.perPersonShare,
  });

  int get totalItemCount => items.fold(0, (acc, i) => acc + i.quantity);

  bool get isCashAtCounter => paymentMethod == 'Cash at Counter';
  bool get isCancelledTimeout => status == 'Cancelled - Payment Timeout';
  bool get isUnclaimed => status == 'Unclaimed';

  // 4-Digit Bi-Directional Token (e.g. #EATS-1042)
  String get tokenNumber {
    if (orderNumber.startsWith('#EATS-')) {
      return orderNumber;
    }
    final digits = orderNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 4) {
      return '#EATS-${digits.substring(digits.length - 4)}';
    } else if (digits.isNotEmpty) {
      return '#EATS-${digits.padLeft(4, '0')}';
    }
    return '#EATS-1042';
  }

  // Payment Status resolution
  bool get isPaid =>
      paymentMethod != 'Cash at Counter' ||
      status == 'Paid & Processing' ||
      status == 'Preparing' ||
      status == 'Ready' ||
      status == 'Completed';

  String get paymentStatusBadgeText {
    if (isPaid) return 'Paid';
    return 'Cash Yet to Pay';
  }

  Color get paymentStatusBadgeColor {
    if (isPaid) return AppTheme.fastPickGreen;
    return AppTheme.accentOrange;
  }

  Color get paymentStatusBadgeBg {
    if (isPaid) return AppTheme.fastPickGreenBg;
    return AppTheme.accentOrangeLight;
  }

  // Summary string of items (e.g. "2x Samosa, 1x Masala Chai")
  String get itemsSummary {
    if (items.isEmpty) return 'No items';
    return items.map((i) => '${i.quantity}x ${i.item.name}').join(', ');
  }

  Duration get cashTimeoutDuration => const Duration(minutes: 30);
  DateTime get cashTimeoutDeadline => timestamp.add(cashTimeoutDuration);
  Duration get remainingCashTime => cashTimeoutDeadline.difference(DateTime.now());
  bool get isCashTimeoutExpired => remainingCashTime.isNegative;

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'studentId': studentId,
      'studentName': studentName,
      'canteenId': canteenId,
      'canteenName': canteenName,
      'items': items.map((i) => i.toMap()).toList(),
      'totalPrice': totalPrice,
      'pickupSlot': pickupSlot,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'splitCount': splitCount,
      'perPersonShare': perPersonShare,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['timestamp'] is Timestamp) {
      parsedDate = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      parsedDate = DateTime.tryParse(map['timestamp']) ?? DateTime.now();
    } else if (map['timestamp'] is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
    } else {
      parsedDate = DateTime.now();
    }

    List<CartItem> itemsList = [];
    if (map['items'] != null && map['items'] is List) {
      itemsList = (map['items'] as List)
          .map((i) => CartItem.fromMap(Map<String, dynamic>.from(i)))
          .toList();
    }

    return OrderModel(
      id: docId,
      orderNumber: map['orderNumber'] ?? '#${(1000 + (docId.hashCode.abs() % 9000))}',
      studentId: map['studentId'] ?? 'STU-001',
      studentName: map['studentName'] ?? 'Student',
      canteenId: map['canteenId'] ?? 'canteen_a',
      canteenName: map['canteenName'] ?? 'Canteen A (North Campus Hub)',
      items: itemsList,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      pickupSlot: map['pickupSlot'] ?? '12:30 PM',
      status: map['status'] ?? 'Pending',
      timestamp: parsedDate,
      paymentMethod: map['paymentMethod'] ?? 'Campus UPI Pay',
      notes: map['notes'],
      splitCount: (map['splitCount'] as num?)?.toInt(),
      perPersonShare: (map['perPersonShare'] as num?)?.toDouble(),
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? studentId,
    String? studentName,
    String? canteenId,
    String? canteenName,
    List<CartItem>? items,
    double? totalPrice,
    String? pickupSlot,
    String? status,
    DateTime? timestamp,
    String? paymentMethod,
    String? notes,
    int? splitCount,
    double? perPersonShare,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      canteenId: canteenId ?? this.canteenId,
      canteenName: canteenName ?? this.canteenName,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      pickupSlot: pickupSlot ?? this.pickupSlot,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      splitCount: splitCount ?? this.splitCount,
      perPersonShare: perPersonShare ?? this.perPersonShare,
    );
  }
}
