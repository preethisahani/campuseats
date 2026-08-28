import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import 'firestore_service.dart';

enum UserRole { student, staff }

class AppState extends ChangeNotifier {
  AppState() {
    _initStrikeListener();
  }

  // User Session
  bool _isAuthenticated = true;
  UserRole _role = UserRole.student;
  String _userId = 'STU-2024-88';
  String _userName = 'Aarav Sharma';
  String _userEmail = 'aarav.sharma@campus.edu';

  // Active Canteen Selection
  String _selectedCanteenId = 'canteen_a';
  String _selectedCanteenName = 'Canteen A (North Campus Hub)';

  // Cart & Checkout State
  final List<CartItem> _cart = [];
  String _selectedSlot = '1:15 PM';
  String _selectedPaymentMethod = 'Online Payment (UPI/QR)'; // 'Online Payment (UPI/QR)' or 'Cash at Counter'
  String? _orderNotes;

  // Canteen Business Payment QR Settings
  String _canteenUpiId = 'campuseats.canteen1@upi';
  String _canteenMerchantName = 'Campus Canteen 1';

  // Unclaimed Strikes Penalty State
  int _unclaimedStrikes = 0;
  StreamSubscription<int>? _strikesSubscription;

  void _initStrikeListener() {
    _strikesSubscription?.cancel();
    _unclaimedStrikes = FirestoreService.instance.getUserStrikes(_userId);
    _strikesSubscription = FirestoreService.instance.streamUserStrikes(_userId).listen((strikes) {
      if (_unclaimedStrikes != strikes) {
        _unclaimedStrikes = strikes;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _strikesSubscription?.cancel();
    super.dispose();
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  UserRole get role => _role;
  bool get isStudent => _role == UserRole.student;
  bool get isStaff => _role == UserRole.staff;
  String get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;

  String get selectedCanteenId => _selectedCanteenId;
  String get selectedCanteenName => _selectedCanteenName;

  List<CartItem> get cart => List.unmodifiable(_cart);
  String get selectedSlot => _selectedSlot;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String? get orderNotes => _orderNotes;

  String get canteenUpiId => _canteenUpiId;
  String get canteenMerchantName => _canteenMerchantName;

  String getUpiPaymentPayload(double amount) {
    final amtStr = amount.toStringAsFixed(2);
    final encName = Uri.encodeComponent(_canteenMerchantName);
    return 'upi://pay?pa=$_canteenUpiId&pn=$encName&am=$amtStr&cu=INR&tn=CampusEatsOrder';
  }

  void updatePaymentSettings({required String upiId, required String merchantName}) {
    _canteenUpiId = upiId.trim().isNotEmpty ? upiId.trim() : 'campuseats.canteen1@upi';
    _canteenMerchantName = merchantName.trim().isNotEmpty ? merchantName.trim() : 'Campus Canteen 1';
    notifyListeners();
  }

  int get unclaimedStrikes => _unclaimedStrikes;
  bool get hasStrikePenalty => _unclaimedStrikes >= 3;

  int get totalCartItems => _cart.fold(0, (acc, item) => acc + item.quantity);

  double get subtotal => _cart.fold(0.0, (acc, item) => acc + item.totalPrice);

  double get platformFee => _cart.isEmpty ? 0.0 : 5.0;

  double get studentDiscount => subtotal >= 100 ? (subtotal * 0.10) : 0.0;

  // 5% Surcharge Penalty on 4th order when strikes hit 3
  double get strikePenaltyFee => (hasStrikePenalty && _cart.isNotEmpty) ? (subtotal * 0.05) : 0.0;

  double get finalTotal => (_cart.isEmpty ? 0.0 : (subtotal + platformFee + strikePenaltyFee - studentDiscount)).clamp(0.0, double.infinity);

  // Authentication Methods
  void login({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) {
    _userId = id;
    _userName = name;
    _userEmail = email;
    _role = role;
    _isAuthenticated = true;
    _initStrikeListener();
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    _role = newRole;
    if (newRole == UserRole.staff) {
      _userId = 'STAFF-CHEF-01';
      _userName = 'Chef Vikram (Kitchen Head)';
      _userEmail = 'kitchen.canteenA@campus.edu';
    } else {
      _userId = 'STU-2024-88';
      _userName = 'Aarav Sharma';
      _userEmail = 'aarav.sharma@campus.edu';
    }
    _initStrikeListener();
    notifyListeners();
  }

  // Canteen Selection
  void selectCanteen(String canteenId, String canteenName) {
    _selectedCanteenId = canteenId;
    _selectedCanteenName = canteenName;
    notifyListeners();
  }

  // Payment Method Selection
  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // Strikes Management
  void setStrikes(int count) {
    _unclaimedStrikes = count;
    FirestoreService.instance.setUserStrikes(_userId, count);
    notifyListeners();
  }

  void resetStrikesAfterPayment() {
    if (_unclaimedStrikes >= 3) {
      _unclaimedStrikes = 0;
      FirestoreService.instance.resetUserStrikes(_userId);
      notifyListeners();
    }
  }

  // Cart Operations
  void addToCart(FoodItem item, {int quantity = 1, String? specialInstructions}) {
    final index = _cart.indexWhere((c) => c.item.id == item.id);
    if (index != -1) {
      _cart[index].quantity += quantity;
      if (specialInstructions != null) {
        _cart[index].specialInstructions = specialInstructions;
      }
    } else {
      _cart.add(CartItem(
        item: item,
        quantity: quantity,
        specialInstructions: specialInstructions,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(FoodItem item, int newQuantity) {
    final index = _cart.indexWhere((c) => c.item.id == item.id);
    if (index != -1) {
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(FoodItem item) {
    _cart.removeWhere((c) => c.item.id == item.id);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void setSelectedSlot(String slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void setOrderNotes(String? notes) {
    _orderNotes = notes;
    notifyListeners();
  }

  // AI Autofill
  void autofillCartFromAI(List<CartItem> items, {String? slot, String? instructions}) {
    _cart.clear();
    _cart.addAll(items);
    if (slot != null && AppConstants.pickupSlots.contains(slot)) {
      _selectedSlot = slot;
    }
    if (instructions != null) {
      _orderNotes = instructions;
    }
    notifyListeners();
  }
}
