import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'services/app_state.dart';
import 'services/firestore_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/home_screen.dart';
import 'screens/student/explore_canteens_screen.dart';
import 'screens/student/canteen_menu_screen.dart';
import 'screens/student/checkout_slots_screen.dart';
import 'screens/student/order_status_screen.dart';
import 'screens/staff/staff_portal_screen.dart';
import 'screens/staff/live_orders_screen.dart';
import 'screens/staff/analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with fallback tolerance
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirestoreService.instance.init();
  } catch (e) {
    // Graceful fallback to resilient reactive store
    FirestoreService.instance.init();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const CampusEatsApp(),
    ),
  );
}

class CampusEatsApp extends StatelessWidget {
  const CampusEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusEats | Smart Campus Dining Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      routes: {
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/explore_canteens': (context) => const ExploreCanteensScreen(),
        '/canteen_menu': (context) => const CanteenMenuScreen(),
        '/checkout_slots': (context) => const CheckoutSlotsScreen(),
        '/login': (context) => const LoginScreen(),
        '/staff_portal': (context) => const StaffPortalScreen(),
        '/live_orders': (context) => const LiveOrdersScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/order_status') {
          final args = settings.arguments as Map<String, dynamic>?;
          final orderId = args?['orderId'] as String?;
          return MaterialPageRoute(
            builder: (context) => OrderStatusScreen(orderId: orderId),
          );
        }
        return null;
      },
    );
  }
}
