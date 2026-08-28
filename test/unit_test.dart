import 'package:flutter_test/flutter_test.dart';
import 'package:campuseats/config/constants.dart';
import 'package:campuseats/models/cart_item.dart';
import 'package:campuseats/models/order_model.dart';
import 'package:campuseats/models/slot_capacity.dart';
import 'package:campuseats/services/app_state.dart';
import 'package:campuseats/services/firestore_service.dart';
import 'package:campuseats/services/gemini_service.dart';

void main() {
  group('AppState & Cart Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('Initial state is student role and empty cart', () {
      expect(appState.isStudent, true);
      expect(appState.cart.isEmpty, true);
      expect(appState.totalCartItems, 0);
      expect(appState.subtotal, 0.0);
    });

    test('Adding food item updates quantity and subtotal correctly', () {
      final food = AppConstants.defaultMenu[0]; // Samosa, ₹25
      appState.addToCart(food, quantity: 2);

      expect(appState.totalCartItems, 2);
      expect(appState.subtotal, 50.0);
      expect(appState.finalTotal, 55.0); // 50 + 5 platform fee
    });

    test('Student discount is applied when subtotal >= 100', () {
      final food = AppConstants.defaultMenu[2]; // Paneer Roll, ₹90
      appState.addToCart(food, quantity: 2); // 180

      expect(appState.subtotal, 180.0);
      expect(appState.studentDiscount, 18.0); // 10% of 180
      expect(appState.finalTotal, 180.0 + 5.0 - 18.0); // 167.0
    });

    test('Role switching updates user identity and permissions', () {
      appState.switchRole(UserRole.staff);
      expect(appState.isStaff, true);
      expect(appState.userId, 'STAFF-CHEF-01');

      appState.switchRole(UserRole.student);
      expect(appState.isStudent, true);
      expect(appState.userId, 'STU-2024-88');
    });
  });

  group('Dynamic Demo QR Payment Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('Generates valid standard Indian UPI payment payload URI', () {
      final food = AppConstants.defaultMenu[0]; // Samosa, ₹25
      appState.addToCart(food, quantity: 2); // finalTotal = 55.0

      final payload = appState.getUpiPaymentPayload(appState.finalTotal);
      expect(payload.startsWith('upi://pay?'), true);
      expect(payload.contains('pa=campuseats.canteen1%40upi') || payload.contains('pa=campuseats.canteen1@upi'), true);
      expect(payload.contains('am=55.00'), true);
      expect(payload.contains('cu=INR'), true);
    });

    test('Staff portal updates Canteen UPI ID and merchant name in real-time', () {
      appState.updatePaymentSettings(
        upiId: 'south.canteen@okhdfcbank',
        merchantName: 'Campus South Food Court',
      );

      expect(appState.canteenUpiId, 'south.canteen@okhdfcbank');
      expect(appState.canteenMerchantName, 'Campus South Food Court');

      final payload = appState.getUpiPaymentPayload(120.0);
      expect(payload.contains('pa=south.canteen%40okhdfcbank') || payload.contains('pa=south.canteen@okhdfcbank'), true);
      expect(payload.contains('am=120.00'), true);
    });

    test('Online Payment (UPI/QR) Simulation generates #EATS-XXXX token and marks status Paid & Processing', () async {
      final service = FirestoreService.instance;
      final onlineOrder = OrderModel(
        id: 'ord_demo_qr_test',
        orderNumber: '',
        studentId: 'STU-2024-88',
        studentName: 'Aarav Sharma',
        canteenId: 'canteen_a',
        canteenName: 'Campus Canteen 1',
        items: [CartItem(item: AppConstants.defaultMenu[0], quantity: 2)],
        totalPrice: 55.0,
        pickupSlot: '1:15 PM',
        status: 'Paid & Processing',
        timestamp: DateTime.now(),
        paymentMethod: 'Online Payment (UPI/QR)',
      );

      final orderId = await service.placeOrder(onlineOrder);
      final placedOrders = await service.streamOrders().first;
      final savedOrder = placedOrders.firstWhere((o) => o.id == orderId);

      expect(savedOrder.status, 'Paid & Processing');
      expect(savedOrder.isPaid, true);
      expect(savedOrder.paymentStatusBadgeText, 'Paid');
      expect(savedOrder.tokenNumber.startsWith('#EATS-'), true);
    });
  });

  group('Bi-Directional Token & Payment Verification Tests', () {
    test('4-Digit Token generation and formatting', () {
      final order = OrderModel(
        id: 'ord_tok_1',
        orderNumber: '#1042',
        studentId: 'STU-101',
        studentName: 'Aarav Sharma',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A',
        items: [
          CartItem(item: AppConstants.defaultMenu[0], quantity: 2), // Samosa
          CartItem(item: AppConstants.defaultMenu[1], quantity: 1), // Chai
        ],
        totalPrice: 65.0,
        pickupSlot: '1:15 PM',
        status: 'Pending',
        timestamp: DateTime.now(),
        paymentMethod: 'Cash at Counter',
      );

      expect(order.tokenNumber, '#EATS-1042');
      expect(order.isPaid, false);
      expect(order.paymentStatusBadgeText, 'Cash Yet to Pay');
      expect(
        order.itemsSummary,
        '2x ${AppConstants.defaultMenu[0].name}, 1x ${AppConstants.defaultMenu[1].name}',
      );
    });

    test('UPI orders are marked Paid immediately', () {
      final upiOrder = OrderModel(
        id: 'ord_tok_2',
        orderNumber: '#2055',
        studentId: 'STU-102',
        studentName: 'Riya Sen',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A',
        items: [CartItem(item: AppConstants.defaultMenu[0], quantity: 1)],
        totalPrice: 25.0,
        pickupSlot: '1:15 PM',
        status: 'Paid & Processing',
        timestamp: DateTime.now(),
        paymentMethod: 'Campus UPI Pay',
      );

      expect(upiOrder.tokenNumber, '#EATS-2055');
      expect(upiOrder.isPaid, true);
      expect(upiOrder.paymentStatusBadgeText, 'Paid');
    });

    test('Staff Confirm & Mark Done updates cash order to Paid & Processing in real time', () async {
      final service = FirestoreService.instance;
      final cashOrder = OrderModel(
        id: 'ord_cash_verify',
        orderNumber: '#3099',
        studentId: 'STU-CASH',
        studentName: 'Cash Student',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A',
        items: [CartItem(item: AppConstants.defaultMenu[0], quantity: 2)],
        totalPrice: 55.0,
        pickupSlot: '1:30 PM',
        status: 'Pending',
        timestamp: DateTime.now(),
        paymentMethod: 'Cash at Counter',
      );

      final orderId = await service.placeOrder(cashOrder);
      await service.confirmCashPayment(orderId);

      final updatedOrders = await service.streamOrders().first;
      final confirmedOrder = updatedOrders.firstWhere((o) => o.id == orderId);

      expect(confirmedOrder.status, 'Paid & Processing');
      expect(confirmedOrder.isPaid, true);
      expect(confirmedOrder.paymentStatusBadgeText, 'Paid');
    });
  });

  group('Operational Feature 1: Cash at Counter 30-Min Timeout Tests', () {
    test('Cash at Counter order model detects 30-min window correctly', () {
      final orderTime = DateTime.now().subtract(const Duration(minutes: 10));
      final cashOrder = OrderModel(
        id: 'ord_test_cash',
        orderNumber: '#9999',
        studentId: 'STU-TEST',
        studentName: 'Test Student',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A',
        items: [CartItem(item: AppConstants.defaultMenu[0], quantity: 2)],
        totalPrice: 55.0,
        pickupSlot: '1:15 PM',
        status: 'Pending',
        timestamp: orderTime,
        paymentMethod: 'Cash at Counter',
      );

      expect(cashOrder.isCashAtCounter, true);
      expect(cashOrder.cashTimeoutDeadline, orderTime.add(const Duration(minutes: 30)));
      expect(cashOrder.remainingCashTime.inMinutes, closeTo(20, 1));
      expect(cashOrder.isCashTimeoutExpired, false);
    });

    test('Expired cash order triggers Cancellation and frees inventory / capacity', () async {
      final service = FirestoreService.instance;
      final testOrder = OrderModel(
        id: 'ord_timeout_1',
        orderNumber: '#8888',
        studentId: 'STU-TIMEOUT',
        studentName: 'Timeout Student',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A',
        items: [CartItem(item: AppConstants.defaultMenu[0], quantity: 2)],
        totalPrice: 55.0,
        pickupSlot: '2:00 PM',
        status: 'Pending',
        timestamp: DateTime.now().subtract(const Duration(minutes: 31)),
        paymentMethod: 'Cash at Counter',
      );

      final orderId = await service.placeOrder(testOrder);
      await service.cancelOrderPaymentTimeout(orderId);

      final updatedOrders = await service.streamOrders().first;
      final cancelledOrder = updatedOrders.firstWhere((o) => o.id == orderId);

      expect(cancelledOrder.status, 'Cancelled - Payment Timeout');
      expect(cancelledOrder.isCancelledTimeout, true);

      // Verify active queue excludes cancelled timeout orders
      final activeOrders = await service.streamActiveOrders().first;
      expect(activeOrders.any((o) => o.id == orderId), false);
    });
  });

  group('Operational Feature 2: 3-Strike Unclaimed Order Penalty Tests', () {
    test('Marking order Unclaimed increments student strikes', () async {
      final service = FirestoreService.instance;
      const testStudentId = 'STU-STRIKE-TEST';
      service.setUserStrikes(testStudentId, 0);

      expect(service.getUserStrikes(testStudentId), 0);

      final order = OrderModel(
        id: 'ord_abandoned_1',
        orderNumber: '#7771',
        studentId: testStudentId,
        studentName: 'Unclaimed Student',
        canteenId: 'canteen_a',
        canteenName: 'Canteen A',
        items: [CartItem(item: AppConstants.defaultMenu[0], quantity: 2)],
        totalPrice: 55.0,
        pickupSlot: '1:15 PM',
        status: 'Ready',
        timestamp: DateTime.now(),
      );

      final orderId = await service.placeOrder(order);
      await service.markOrderUnclaimed(orderId, testStudentId);

      expect(service.getUserStrikes(testStudentId), 1);
    });

    test('3-Strikes automatically applies 5% surcharge fee on checkout', () {
      final appState = AppState();
      final food = AppConstants.defaultMenu[2]; // Paneer Roll, ₹90
      appState.addToCart(food, quantity: 2); // subtotal = 180

      // Case 1: 0 strikes -> No penalty
      appState.setStrikes(0);
      expect(appState.hasStrikePenalty, false);
      expect(appState.strikePenaltyFee, 0.0);

      // Case 2: 2 strikes -> No penalty yet
      appState.setStrikes(2);
      expect(appState.hasStrikePenalty, false);
      expect(appState.strikePenaltyFee, 0.0);

      // Case 3: 3 strikes -> 5% surcharge fee applied (5% of 180 = 9.0)
      appState.setStrikes(3);
      expect(appState.hasStrikePenalty, true);
      expect(appState.strikePenaltyFee, 9.0);
      // finalTotal = 180 (subtotal) + 5 (platform) + 9 (strike penalty) - 18 (10% student discount) = 176.0
      expect(appState.finalTotal, 176.0);
    });

    test('Strike count resets to 0 after paying penalized order', () {
      final appState = AppState();
      appState.setStrikes(3);
      expect(appState.hasStrikePenalty, true);

      appState.resetStrikesAfterPayment();
      expect(appState.unclaimedStrikes, 0);
      expect(appState.hasStrikePenalty, false);
      expect(appState.strikePenaltyFee, 0.0);
    });
  });

  group('Gemini AI Parser Tests', () {
    test('Parses natural language order: 2 Samosas for 1:15 PM', () async {
      final menu = AppConstants.defaultMenu;
      final result = await GeminiService.instance.parseNaturalOrder(
        'Order 2 Samosas and 1 Masala Chai for 1:15 PM',
        menu,
      );

      expect(result.isSuccessful, true);
      expect(result.items.isNotEmpty, true);
      expect(result.pickupSlot, '1:15 PM');

      final samosaItem = result.items.firstWhere((i) => i.item.name.contains('Samosa'));
      expect(samosaItem.quantity, 2);
    });

    test('Parses roll and coffee for 1:30 PM', () async {
      final menu = AppConstants.defaultMenu;
      final result = await GeminiService.instance.parseNaturalOrder(
        '1 Paneer Tikka Kathi Roll and Cold Coffee for 1:30 PM',
        menu,
      );

      expect(result.isSuccessful, true);
      expect(result.pickupSlot, '1:30 PM');
    });
  });

  group('Firestore Batching & Dynamic Crowd Control Tests', () {
    test('Slot crowd status accurately reflects order count and cap', () {
      const fastPick = SlotCapacity(slotTime: '12:30 PM', activeOrdersCount: 5);
      expect(fastPick.crowdStatus, SlotCrowdStatus.fastPick);
      expect(fastPick.isAvailable, true);

      const busySlot = SlotCapacity(slotTime: '1:15 PM', activeOrdersCount: 14);
      expect(busySlot.crowdStatus, SlotCrowdStatus.busy);
      expect(busySlot.isAvailable, true);

      const cappedSlot = SlotCapacity(slotTime: '1:15 PM', activeOrdersCount: 20);
      expect(cappedSlot.crowdStatus, SlotCrowdStatus.capReached);
      expect(cappedSlot.isAvailable, false);
    });

    test('Kitchen Batch Summary aggregates item quantities per slot', () {
      final testOrders = [
        OrderModel(
          id: '1',
          orderNumber: '#1001',
          studentId: 'S1',
          studentName: 'Student 1',
          canteenId: 'canteen_a',
          canteenName: 'Canteen A',
          items: [
            CartItem(item: AppConstants.defaultMenu[0], quantity: 3), // Samosa
            CartItem(item: AppConstants.defaultMenu[1], quantity: 2), // Chai
          ],
          totalPrice: 105.0,
          pickupSlot: '1:15 PM',
          status: 'Pending',
          timestamp: DateTime.now(),
        ),
        OrderModel(
          id: '2',
          orderNumber: '#1002',
          studentId: 'S2',
          studentName: 'Student 2',
          canteenId: 'canteen_a',
          canteenName: 'Canteen A',
          items: [
            CartItem(item: AppConstants.defaultMenu[0], quantity: 5), // Samosa
          ],
          totalPrice: 125.0,
          pickupSlot: '1:15 PM',
          status: 'Preparing',
          timestamp: DateTime.now(),
        ),
      ];

      final batch = FirestoreService.aggregateItemQuantities(testOrders, slotFilter: '1:15 PM');
      expect(batch[AppConstants.defaultMenu[0].name], 8); // 3 + 5 Samosas
      expect(batch[AppConstants.defaultMenu[1].name], 2); // 2 Chais
    });
  });
}
