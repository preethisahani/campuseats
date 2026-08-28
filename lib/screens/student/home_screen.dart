import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../models/food_item.dart';
import '../../models/order_model.dart';
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_navbar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Snacks',
    'Beverages',
    'Mains',
    'Fast Food',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: const AppNavbar(activeRoute: '/home'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: LayoutBuilder(
                    builder: (context, heroConstraints) {
                      final isMobile = heroConstraints.maxWidth < 768;

                      final leftContent = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentOrange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded, color: AppTheme.accentOrange, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SMART PRE-ORDER & SLOT QUEUING',
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.accentOrange,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Personalized Greeting
  Text(
  'Welcome, ${() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName?.isNotEmpty == true) return user!.displayName!;
    if (user?.email?.contains('@') == true) {
      final prefix = user!.email!.split('@').first;
      return prefix[0].toUpperCase() + prefix.substring(1);
    }
    return 'Student';
  }()}!',
  style: GoogleFonts.plusJakartaSans(
    fontSize: isMobile ? 18 : 22,
    fontWeight: FontWeight.w700,
    color: AppTheme.accentOrange,
  ),
),
                          const SizedBox(height: 8),
                          Text(
                            'Skip the Campus Line.\nSavor Every Break.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isMobile ? 30 : 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Order from your favorite campus canteens in advance, pick guaranteed fast time slots, or let Gemini AI parse your order instantly.',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  appState.selectCanteen('canteen_a', 'Canteen A (North Campus Hub)');
                                  Navigator.pushNamed(context, '/canteen_menu');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.restaurant_menu_rounded, size: 20),
                                label: Text(
                                  'Order Canteen A Menu',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/explore_canteens');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70, width: 1.5),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.explore_outlined, size: 20),
                                label: Text(
                                  'Explore Canteens',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );

                      final rightContent = Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.speed_rounded, color: AppTheme.accentOrange, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Live Rush Status',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildLiveRushBar('Canteen A (SAC)', 45, '8-12m wait', AppTheme.fastPickGreen),
                            const SizedBox(height: 12),
                            _buildLiveRushBar('Engineering Bistro', 78, '18-22m wait', AppTheme.busyOrange),
                            const SizedBox(height: 12),
                            _buildLiveRushBar('Green Leaf Cafe', 25, '5m wait', AppTheme.fastPickGreen),
                          ],
                        ),
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            leftContent,
                            const SizedBox(height: 24),
                            rightContent,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(flex: 6, child: leftContent),
                          const SizedBox(width: 32),
                          Expanded(flex: 4, child: rightContent),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Main Content Area
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Active/Previous Order Card
                      _buildTopActiveOrderCard(appState),

                      // AI Fast Order Banner
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.softPeach,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentOrange, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Try Gemini AI Natural Text Ordering',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  Text(
                                    'Simply type "2 Samosas and Chai for 1:15 PM" on the menu page to auto-fill your cart and time slot in one step.',
                                    style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/canteen_menu'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Try AI Order'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Campus Canteens Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campus Dining Venues',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                'Select a canteen to view live menus and available fast pickup slots',
                                style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/explore_canteens'),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.secondary),
                            label: Text(
                              'View All (3)',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Canteens Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisExtent: 320,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: AppConstants.canteens.length,
                        itemBuilder: (context, index) {
                          final canteen = AppConstants.canteens[index];
                          return _buildCanteenCard(context, canteen, appState);
                        },
                      ),

                      const SizedBox(height: 48),

                      // Popular Bites Section
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 12,
                        spacing: 12,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campus Student Favorites',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                              Text(
                                'Quick add high-demand items to your express checkout',
                                style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          // Category selector pills
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories.map((cat) {
                                final isSel = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: isSel,
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedCategory = cat);
                                    },
                                    selectedColor: AppTheme.primary,
                                    labelStyle: GoogleFonts.beVietnamPro(
                                      color: isSel ? Colors.white : AppTheme.onSurfaceVariant,
                                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    backgroundColor: AppTheme.surfaceLow,
                                    side: BorderSide(
                                      color: isSel ? AppTheme.primary : AppTheme.surfaceContainer,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Food Items Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          mainAxisExtent: 330,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: AppConstants.defaultMenu.where((item) {
                          if (_selectedCategory == 'All') return true;
                          return item.category == _selectedCategory;
                        }).length,
                        itemBuilder: (context, index) {
                          final items = AppConstants.defaultMenu.where((item) {
                            if (_selectedCategory == 'All') return true;
                            return item.category == _selectedCategory;
                          }).toList();
                          final food = items[index];

                          return _buildFoodItemCard(context, food, appState);
                        },
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRushBar(String name, int occupancy, String wait, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                name,
                style: GoogleFonts.beVietnamPro(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$occupancy% • $wait',
              style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: occupancy / 100.0,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCanteenCard(BuildContext context, Map<String, dynamic> canteen, AppState appState) {
    final occupancy = canteen['occupancy'] as int;
    final isBusy = occupancy >= 70;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          appState.selectCanteen(canteen['id'], canteen['name']);
          Navigator.pushNamed(context, '/canteen_menu');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with tags
            Stack(
              children: [
                Image.network(
                  canteen['image'],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: AppTheme.surfaceLow,
                    child: const Icon(Icons.restaurant, color: AppTheme.outline, size: 40),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isBusy ? AppTheme.busyOrange : AppTheme.fastPickGreen,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      isBusy ? '⚡ Moderate Queue' : '🟢 Low Queue',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${canteen['rating']} (${canteen['reviews']})',
                          style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    canteen['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.outline),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          canteen['location'],
                          style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 8,
                    spacing: 8,
                    children: [
                      Text(
                        'Wait: ${canteen['waitTime']}',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondary,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          appState.selectCanteen(canteen['id'], canteen['name']);
                          Navigator.pushNamed(context, '/canteen_menu');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('View Menu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(BuildContext context, FoodItem food, AppState appState) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                food.imageUrl,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 130,
                  color: AppTheme.surfaceLow,
                  child: const Icon(Icons.fastfood, color: AppTheme.outline, size: 36),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 8),
                      const SizedBox(width: 4),
                      Text(
                        'VEG',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (food.isPopular)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '🔥 Bestseller',
                      style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  food.description,
                  style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${food.price.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        appState.addToCart(food);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppTheme.primary,
                            content: Text(
                              'Added ${food.name} to cart!',
                              style: GoogleFonts.beVietnamPro(),
                            ),
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: AppTheme.accentOrange,
                              onPressed: () => Navigator.pushNamed(context, '/checkout_slots'),
                            ),
                          ),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.accentOrangeLight,
                        foregroundColor: AppTheme.accentOrange,
                        padding: const EdgeInsets.all(8),
                      ),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      tooltip: 'Add to Cart',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActiveOrderCard(AppState appState) {
    return StreamBuilder<List<OrderModel>>(
      stream: FirestoreService.instance.streamOrders(),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];
        final activeOrder = orders.cast<OrderModel?>().firstWhere(
          (o) => o?.studentId == appState.userId && o?.status != 'Completed' && !o!.status.startsWith('Cancelled'),
          orElse: () => null,
        );

        if (activeOrder == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: activeOrder.status == 'Ready'
                  ? AppTheme.fastPickGreen
                  : activeOrder.isCashAtCounter && !activeOrder.isPaid
                      ? AppTheme.accentOrange
                      : AppTheme.secondary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: AppTheme.shadowLevel2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: activeOrder.status == 'Ready'
                              ? AppTheme.fastPickGreenBg
                              : AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          activeOrder.status == 'Ready' ? Icons.check_circle_rounded : Icons.restaurant_rounded,
                          color: activeOrder.status == 'Ready' ? AppTheme.fastPickGreen : AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Current Order',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'Token: ${activeOrder.tokenNumber}',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Status Badge & Payment Tag
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: activeOrder.paymentStatusBadgeBg,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: activeOrder.paymentStatusBadgeColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          activeOrder.paymentStatusBadgeText,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: activeOrder.paymentStatusBadgeColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: activeOrder.status == 'Ready' ? AppTheme.fastPickGreenBg : AppTheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: activeOrder.status == 'Ready' ? AppTheme.fastPickGreen : AppTheme.secondary,
                          ),
                        ),
                        child: Text(
                          activeOrder.status == 'Ready' ? 'READY FOR PICKUP' : activeOrder.status.toUpperCase(),
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: activeOrder.status == 'Ready' ? AppTheme.fastPickGreen : AppTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppTheme.surfaceContainer),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, cardConstraints) {
                  final isCardMobile = cardConstraints.maxWidth < 600;

                  final textContent = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeOrder.itemsSummary,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${activeOrder.canteenName} • Window: ${activeOrder.pickupSlot}',
                        style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  );

                  final button = ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/order_status',
                        arguments: {'orderId': activeOrder.id},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.qr_code_rounded, size: 16),
                    label: Text(
                      'Track Live Order',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  );

                  if (isCardMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textContent,
                        const SizedBox(height: 12),
                        button,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: textContent),
                      const SizedBox(width: 12),
                      button,
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
