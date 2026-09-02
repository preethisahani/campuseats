import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../models/food_item.dart';
import '../../services/app_state.dart';
import '../../widgets/ai_order_bar.dart';
import '../../widgets/app_navbar.dart';

class CanteenMenuScreen extends StatefulWidget {
  const CanteenMenuScreen({super.key});

  @override
  State<CanteenMenuScreen> createState() => _CanteenMenuScreenState();
}

class _CanteenMenuScreenState extends State<CanteenMenuScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Snacks',
    'Beverages',
    'Mains',
    'Fast Food',
    'Lunch Specials',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final menu = AppConstants.defaultMenu;

    final filteredItems = menu.where((item) {
      if (_selectedCategory == 'Lunch Specials') {
        return ['item_9', 'item_10', 'item_11', 'item_12'].contains(item.id);
      }
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matches = item.name.toLowerCase().contains(query) || item.description.toLowerCase().contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: const AppNavbar(activeRoute: '/canteen_menu'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Canteen Header Info
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.surfaceContainer),
                          boxShadow: AppTheme.shadowLevel1,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.restaurant_rounded, color: AppTheme.accentOrange, size: 36),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        appState.selectedCanteenName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.fastPickGreenBg,
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          'OPEN NOW',
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.fastPickGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Student Activity Center, Level 1 • Standard Prep: 5-10 mins • 4.8 ★ (342 Reviews)',
                                    style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Gemini AI Express Order Bar Widget
                      AIOrderBar(
                        menu: menu,
                        onOrderParsed: (items, slot) {
                          // Handled inside AIOrderBar & AppState
                        },
                      ),

                      const SizedBox(height: 24),

                      // Lunch Specials section
                      _buildLunchSpecialsSection(context, menu, appState),

                      const SizedBox(height: 32),

                      // Menu Filter and Category Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Menu Catalog',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          // Search field
                          SizedBox(
                            width: 240,
                            height: 40,
                            child: TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: GoogleFonts.beVietnamPro(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Search dishes...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.outline),
                                filled: true,
                                fillColor: AppTheme.surfaceWhite,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Category Chips
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
                                backgroundColor: AppTheme.surfaceWhite,
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Food Items Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 380,
                          mainAxisExtent: 380,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final food = filteredItems[index];
                          final cartItem = appState.cart.cast<dynamic>().firstWhere(
                                (c) => c.item.id == food.id,
                                orElse: () => null,
                              );
                          final inCartQty = cartItem?.quantity ?? 0;

                          return _buildMenuItemCard(context, food, inCartQty, appState);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Cart Checkout Bottom Bar
          if (appState.totalCartItems > 0)
            Positioned(
              bottom: 20,
              left: 24,
              right: 24,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.shadowLevel3,
                      border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${appState.totalCartItems} Items',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Cart Subtotal: ₹${appState.subtotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Slot: ${appState.selectedSlot}',
                                  style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/checkout_slots');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.schedule_rounded, size: 18),
                          label: Text(
                            'Choose Pickup Slot & Pay →',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, FoodItem food, int inCartQty, AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inCartQty > 0 ? AppTheme.accentOrange.withValues(alpha: 0.5) : AppTheme.surfaceContainer,
          width: inCartQty > 0 ? 1.5 : 1,
        ),
        boxShadow: AppTheme.shadowLevel1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Veg badge
          Stack(
            children: [
              Image.network(
                food.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: AppTheme.surfaceLow,
                  child: const Icon(Icons.fastfood, color: AppTheme.outline, size: 40),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: food.isVeg ? Colors.green : Colors.red, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: food.isVeg ? Colors.green : Colors.red, size: 8),
                      const SizedBox(width: 4),
                      Text(
                        food.isVeg ? 'VEG' : 'NON-VEG',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: food.isVeg ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (food.isPopular)
                Positioned(
                  top: 10,
                  right: 10,
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${food.isVeg ? "🟢" : "🔴"} ${food.name} — ₹${food.price.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  food.description,
                  style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppTheme.outline),
                    const SizedBox(width: 4),
                    Text('${food.prepTimeMinutes}m prep', style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.outline)),
                    const SizedBox(width: 12),
                    const Icon(Icons.local_fire_department_outlined, size: 13, color: AppTheme.outline),
                    const SizedBox(width: 4),
                    Text('${food.calories} kcal', style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.outline)),
                  ],
                ),
                const SizedBox(height: 14),

                // Add or Quantity Counter
                if (inCartQty == 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => appState.addToCart(food),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: Text(
                        'Add to Order',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrangeLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => appState.updateQuantity(food, inCartQty - 1),
                          icon: const Icon(Icons.remove, size: 18, color: AppTheme.accentOrange),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          '$inCartQty in Cart',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                        IconButton(
                          onPressed: () => appState.addToCart(food),
                          icon: const Icon(Icons.add, size: 18, color: AppTheme.accentOrange),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLunchSpecialsSection(BuildContext context, List<FoodItem> menu, AppState appState) {
    final specials = menu.where((item) => ['item_9', 'item_10', 'item_11', 'item_12'].contains(item.id)).toList();
    if (specials.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentOrange, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
                  const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '☀️ Lunch Specials',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Available during lunch: 12:30 PM – 2:00 PM',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: specials.map((food) {
                final cartItem = appState.cart.cast<dynamic>().firstWhere(
                      (c) => c.item.id == food.id,
                      orElse: () => null,
                    );
                final inCartQty = cartItem?.quantity ?? 0;

                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.shadowLevel1,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          food.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 64,
                            height: 64,
                            color: AppTheme.surfaceLow,
                            child: const Icon(Icons.fastfood, size: 24, color: AppTheme.outline),
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
                              '${food.isVeg ? "🟢" : "🔴"} ${food.name}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${food.price.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (inCartQty == 0)
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () => appState.addToCart(food),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    minimumSize: Size.zero,
                                  ),
                                  child: Text(
                                    '+ Add',
                                    style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => appState.updateQuantity(food, inCartQty - 1),
                                    icon: const Icon(Icons.remove_circle_outline, size: 18, color: AppTheme.accentOrange),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$inCartQty',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => appState.addToCart(food),
                                    icon: const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.accentOrange),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
