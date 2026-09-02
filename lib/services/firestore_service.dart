import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/order_model.dart';
import '../models/slot_capacity.dart';
import '../models/cart_item.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal() {
    _initializeSeedData();
  }

  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  // Local in-memory reactive store
  final _ordersController = StreamController<List<OrderModel>>.broadcast();
  final _slotCapacitiesController = StreamController<Map<String, SlotCapacity>>.broadcast();
  final _userStrikesController = StreamController<Map<String, int>>.broadcast();

  final List<OrderModel> _inMemoryOrders = [];
  final Map<String, bool> _manuallyLockedSlots = {};
  final Map<String, int> _userUnclaimedStrikes = {
    'STU-2024-88': 0, // Default demo student
  };

  void init({FirebaseFirestore? firestore}) {
    try {
      _firestore = firestore ?? FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
      _listenToFirestore();
    } catch (e) {
      if (kDebugMode) {
        print('Using reactive local store for FirestoreService: $e');
      }
      _isFirebaseAvailable = false;
      _emitState();
    }
  }

  void _initializeSeedData() {
    final now = DateTime.now();
    // Seed initial realistic active orders for realistic batching & slot capacities demonstration
    _inMemoryOrders.addAll([
      OrderModel(
        id: 'ord_101',
        orderNumber: '#CE-1048',
        studentId: 'STU-2024-88',
        studentName: 'Aarav Sharma',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A (North Campus Hub)',
        items: [
          CartItem(
            item: AppConstants.defaultMenu[0], // Samosa
            quantity: 3,
          ),
          CartItem(
            item: AppConstants.defaultMenu[1], // Chai
            quantity: 2,
          ),
        ],
        totalPrice: 105.0,
        pickupSlot: '1:15 PM',
        status: 'Pending',
        timestamp: now.subtract(const Duration(minutes: 6)),
        paymentMethod: 'Campus UPI Pay',
      ),
      OrderModel(
        id: 'ord_102',
        orderNumber: '#CE-1049',
        studentId: 'STU-2024-12',
        studentName: 'Riya Sen',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A (North Campus Hub)',
        items: [
          CartItem(
            item: AppConstants.defaultMenu[0], // Samosa
            quantity: 4,
          ),
          CartItem(
            item: AppConstants.defaultMenu[2], // Paneer Roll
            quantity: 2,
          ),
          CartItem(
            item: AppConstants.defaultMenu[5], // Cold Coffee
            quantity: 2,
          ),
        ],
        totalPrice: 370.0,
        pickupSlot: '1:15 PM',
        status: 'Preparing',
        timestamp: now.subtract(const Duration(minutes: 12)),
        paymentMethod: 'Cash at Counter',
      ),
      OrderModel(
        id: 'ord_103',
        orderNumber: '#CE-1050',
        studentId: 'STU-2024-55',
        studentName: 'Karan Patel',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A (North Campus Hub)',
        items: [
          CartItem(
            item: AppConstants.defaultMenu[0], // Samosa
            quantity: 5,
          ),
          CartItem(
            item: AppConstants.defaultMenu[1], // Chai
            quantity: 4,
          ),
        ],
        totalPrice: 185.0,
        pickupSlot: '1:15 PM',
        status: 'Pending',
        timestamp: now.subtract(const Duration(minutes: 4)),
        paymentMethod: 'Campus UPI Pay',
      ),
      OrderModel(
        id: 'ord_104',
        orderNumber: '#CE-1051',
        studentId: 'STU-2024-91',
        studentName: 'Tanvi Verma',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A (North Campus Hub)',
        items: [
          CartItem(
            item: AppConstants.defaultMenu[3], // Pav Bhaji
            quantity: 2,
          ),
          CartItem(
            item: AppConstants.defaultMenu[5], // Cold Coffee
            quantity: 1,
          ),
        ],
        totalPrice: 205.0,
        pickupSlot: '1:00 PM',
        status: 'Ready',
        timestamp: now.subtract(const Duration(minutes: 18)),
        paymentMethod: 'Campus UPI Pay',
      ),
      OrderModel(
        id: 'ord_105',
        orderNumber: '#CE-1052',
        studentId: 'STU-2024-43',
        studentName: 'Devansh Roy',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A (North Campus Hub)',
        items: [
          CartItem(
            item: AppConstants.defaultMenu[4], // Burger Deluxe
            quantity: 2,
          ),
          CartItem(
            item: AppConstants.defaultMenu[1], // Chai
            quantity: 2,
          ),
        ],
        totalPrice: 160.0,
        pickupSlot: '12:45 PM',
        status: 'Ready',
        timestamp: now.subtract(const Duration(minutes: 25)),
        paymentMethod: 'Cash at Counter',
      ),
      OrderModel(
        id: 'ord_106',
        orderNumber: '#CE-1053',
        studentId: 'STU-2024-77',
        studentName: 'Meera Nair',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A (North Campus Hub)',
        items: [
          CartItem(
            item: AppConstants.defaultMenu[6], // Chole Bhature
            quantity: 2,
          ),
          CartItem(
            item: AppConstants.defaultMenu[7], // Mango Lassi
            quantity: 2,
          ),
        ],
        totalPrice: 290.0,
        pickupSlot: '1:30 PM',
        status: 'Pending',
        timestamp: now.subtract(const Duration(minutes: 3)),
        paymentMethod: 'Campus UPI Pay',
      ),
    ]);

    // Populate extra dummy counts for 1:15 PM slot to simulate 14 active orders
    for (int i = 0; i < 6; i++) {
      _inMemoryOrders.add(
        OrderModel(
          id: 'ord_dummy_$i',
          orderNumber: '#CE-105${4 + i}',
          studentId: 'STU-2024-${10 + i}',
          studentName: 'Student ${10 + i}',
          canteenId: 'canteen_a',
          canteenName: 'Canteen A (North Campus Hub)',
          items: [
            CartItem(
              item: AppConstants.defaultMenu[0],
              quantity: 2,
            ),
          ],
          totalPrice: 50.0,
          pickupSlot: '1:15 PM',
          status: 'Pending',
          timestamp: now.subtract(Duration(minutes: 2 + i)),
          paymentMethod: 'Campus UPI Pay',
        ),
      );
    }

    _emitState();
  }

  void _listenToFirestore() {
    if (_firestore == null) return;
    try {
      _firestore!
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          final orders = snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.data(), doc.id);
          }).toList();
          _inMemoryOrders.clear();
          _inMemoryOrders.addAll(orders);
          _emitState();
        },
        onError: (err) {
          if (kDebugMode) {
            print('Firestore stream error (fallback active): $err');
          }
          _isFirebaseAvailable = false;
          _emitState();
        },
      );

      // Listen to users collection for strikes
      _firestore!.collection('users').snapshots().listen(
        (snapshot) {
          for (final doc in snapshot.docs) {
            final strikes = (doc.data()['unclaimedStrikes'] as num?)?.toInt() ?? 0;
            _userUnclaimedStrikes[doc.id] = strikes;
          }
          _userStrikesController.add(Map.unmodifiable(_userUnclaimedStrikes));
        },
        onError: (_) {},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to attach Firestore stream: $e');
      }
      _isFirebaseAvailable = false;
      _emitState();
    }
  }

  void _emitState() {
    // Active orders excluding Completed, Cancelled / Cancelled - Payment Timeout, and Unclaimed
    final activeOrders = _inMemoryOrders.where((o) {
      return o.status != 'Completed' &&
          !o.status.startsWith('Cancelled') &&
          o.status != 'Unclaimed';
    }).toList();

    _ordersController.add(List.unmodifiable(_inMemoryOrders));

    // Calculate slot capacities dynamically (releasing cancelled/timed out orders immediately)
    final Map<String, SlotCapacity> capacities = {};
    for (final slot in AppConstants.pickupSlots) {
      final activeCount = activeOrders.where((o) => o.pickupSlot == slot).length;
      final isLocked = _manuallyLockedSlots[slot] ?? false;

      capacities[slot] = SlotCapacity(
        slotTime: slot,
        activeOrdersCount: activeCount,
        maxCap: AppConstants.maxSlotCapacity,
        isManuallyLocked: isLocked,
      );
    }
    _slotCapacitiesController.add(Map.unmodifiable(capacities));
    _userStrikesController.add(Map.unmodifiable(_userUnclaimedStrikes));
  }

  // Stream of all orders in real-time
  Stream<List<OrderModel>> streamOrders() {
    Future.microtask(() => _emitState());
    return _ordersController.stream;
  }

  // Stream of active orders (Pending, Preparing, Ready)
  Stream<List<OrderModel>> streamActiveOrders() {
    Future.microtask(() => _emitState());
    return _ordersController.stream.map(
      (orders) => orders.where((o) {
        return o.status != 'Completed' &&
            !o.status.startsWith('Cancelled') &&
            o.status != 'Unclaimed';
      }).toList(),
    );
  }

  // Stream of single order by ID
  Stream<OrderModel?> streamOrderById(String orderId) {
    Future.microtask(() => _emitState());
    return _ordersController.stream.map(
      (orders) {
        try {
          return orders.firstWhere((o) => o.id == orderId);
        } catch (_) {
          return null;
        }
      },
    );
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return _inMemoryOrders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  // Stream of slot crowd capacities
  Stream<Map<String, SlotCapacity>> streamSlotCapacities() {
    Future.microtask(() => _emitState());
    return _slotCapacitiesController.stream;
  }

  // Stream unclaimed strikes for a student ID
  Stream<int> streamUserStrikes(String studentId) {
    Future.microtask(() => _emitState());
    return _userStrikesController.stream.map(
      (strikesMap) => strikesMap[studentId] ?? 0,
    );
  }

  int getUserStrikes(String studentId) {
    return _userUnclaimedStrikes[studentId] ?? 0;
  }

  void setUserStrikes(String studentId, int count) {
    _userUnclaimedStrikes[studentId] = count.clamp(0, 99);
    _emitState();

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        _firestore!.collection('users').doc(studentId).set({
          'unclaimedStrikes': count.clamp(0, 99),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  // Reset student unclaimed strikes back to 0 (after payment on 4th order)
  Future<void> resetUserStrikes(String studentId) async {
    _userUnclaimedStrikes[studentId] = 0;
    _emitState();

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('users').doc(studentId).set({
          'unclaimedStrikes': 0,
          'lastResetAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        if (kDebugMode) {
          print('Reset strikes error: $e');
        }
      }
    }
  }

  // Mark an order Unclaimed/Abandoned by staff -> increments unclaimedStrikes by 1
  Future<void> markOrderUnclaimed(String orderId, String studentId) async {
    final index = _inMemoryOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _inMemoryOrders[index] = _inMemoryOrders[index].copyWith(status: 'Unclaimed');
    }

    final currentStrikes = _userUnclaimedStrikes[studentId] ?? 0;
    _userUnclaimedStrikes[studentId] = currentStrikes + 1;
    _emitState();

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('orders').doc(orderId).update({
          'status': 'Unclaimed',
          'unclaimedAt': FieldValue.serverTimestamp(),
        });

        await _firestore!.collection('users').doc(studentId).set({
          'unclaimedStrikes': FieldValue.increment(1),
          'lastStrikeAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        if (kDebugMode) {
          print('markOrderUnclaimed error: $e');
        }
      }
    }
  }

  // Cancel order due to 30-min cash payment timeout -> re-releases reserved items back to inventory
  Future<void> cancelOrderPaymentTimeout(String orderId) async {
    final index = _inMemoryOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _inMemoryOrders[index] = _inMemoryOrders[index].copyWith(status: 'Cancelled - Payment Timeout');
      _emitState();
    }

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('orders').doc(orderId).update({
          'status': 'Cancelled - Payment Timeout',
          'cancelledAt': FieldValue.serverTimestamp(),
          'cancellationReason': 'Cash at Counter 30-minute payment timeout expired',
        });
      } catch (e) {
        if (kDebugMode) {
          print('cancelOrderPaymentTimeout error: $e');
        }
      }
    }
  }

  // Confirm cash payment at counter -> updates status to 'Paid & Processing'
  Future<void> confirmCashPayment(String orderId) async {
    await updateOrderStatus(orderId, 'Paid & Processing');
  }

  // Place order into Firestore and local store
  Future<String> placeOrder(OrderModel order) async {
    final newId = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    final tokenDigits = (1000 + (_inMemoryOrders.length * 17 + (DateTime.now().millisecond % 500)) % 9000).toString();
    final newOrderNumber = '#EATS-$tokenDigits';

    final isInstantPaid = order.paymentMethod == 'Online Payment (UPI/QR)' ||
        order.paymentMethod == 'Campus UPI Pay' ||
        order.status == 'Paid' ||
        order.status == 'Paid & Processing';

    final orderToSave = order.copyWith(
      id: newId,
      orderNumber: newOrderNumber,
      timestamp: DateTime.now(),
      status: isInstantPaid ? 'Paid & Processing' : 'Pending',
    );

    _inMemoryOrders.insert(0, orderToSave);
    _emitState();

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('orders').doc(newId).set(orderToSave.toMap());
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Firestore write failed, order kept in reactive local store: $e');
        }
      }
    }

    return newId;
  }

  // Update order status: Pending -> Preparing -> Ready -> Completed
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _inMemoryOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _inMemoryOrders[index] = _inMemoryOrders[index].copyWith(status: newStatus);
      _emitState();
    }

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('orders').doc(orderId).update({
          'status': newStatus,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (kDebugMode) {
          print('Firestore status update error: $e');
        }
      }
    }
  }

  // Staff manual lock/unlock toggle for a slot
  void toggleSlotLock(String slotTime) {
    final current = _manuallyLockedSlots[slotTime] ?? false;
    _manuallyLockedSlots[slotTime] = !current;
    _emitState();
  }

  // Aggregate item quantities for Batch Summary
  static Map<String, int> aggregateItemQuantities(
    List<OrderModel> orders, {
    String? slotFilter,
    String? statusFilter,
  }) {
    final Map<String, int> summary = {};

    final filtered = orders.where((order) {
      if (slotFilter != null && slotFilter.isNotEmpty && order.pickupSlot != slotFilter) {
        return false;
      }
      if (statusFilter != null && statusFilter.isNotEmpty && order.status != statusFilter) {
        return false;
      }
      return order.status != 'Completed' &&
          !order.status.startsWith('Cancelled') &&
          order.status != 'Unclaimed';
    });

    for (final order in filtered) {
      for (final cartItem in order.items) {
        summary[cartItem.item.name] = (summary[cartItem.item.name] ?? 0) + cartItem.quantity;
      }
    }

    return summary;
  }
}
