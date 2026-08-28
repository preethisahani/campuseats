import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../services/app_state.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String activeRoute;

  const AppNavbar({super.key, required this.activeRoute});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isStaff = appState.isStaff;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: const Border(
          bottom: BorderSide(color: AppTheme.surfaceContainer, width: 1.5),
        ),
        boxShadow: AppTheme.shadowLevel1,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              // Brand Logo
              InkWell(
                onTap: () {
                  if (isStaff) {
                    Navigator.pushReplacementNamed(context, '/staff_portal');
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: AppTheme.accentOrange,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Campus',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: 'Eats',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextSpanWidget(
                          text: isStaff ? 'KITCHEN & STAFF PORTAL' : 'SMART CAMPUS DINING',
                          fontSize: 9,
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Navigation Links (Desktop/Tablet)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: isStaff
                        ? [
                            _buildNavLink(
                              context,
                              title: 'Crowd Dashboard',
                              route: '/staff_portal',
                              icon: Icons.dashboard_customize_rounded,
                            ),
                            _buildNavLink(
                              context,
                              title: 'Live KDS Orders',
                              route: '/live_orders',
                              icon: Icons.kitchen_rounded,
                            ),
                            _buildNavLink(
                              context,
                              title: 'Analytics',
                              route: '/analytics',
                              icon: Icons.bar_chart_rounded,
                            ),
                          ]
                        : [
                            _buildNavLink(
                              context,
                              title: 'Home',
                              route: '/home',
                              icon: Icons.home_rounded,
                            ),
                            _buildNavLink(
                              context,
                              title: 'Explore Canteens',
                              route: '/explore_canteens',
                              icon: Icons.explore_rounded,
                            ),
                            _buildNavLink(
                              context,
                              title: 'Canteen Menu',
                              route: '/canteen_menu',
                              icon: Icons.menu_book_rounded,
                            ),
                            _buildNavLink(
                              context,
                              title: 'Order Status',
                              route: '/order_status',
                              icon: Icons.receipt_long_rounded,
                            ),
                          ],
                  ),
                ),
              ),

              // Right Action Bar (Role Switcher, Cart, Profile)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Role Toggle Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isStaff ? AppTheme.primaryContainer.withValues(alpha: 0.1) : AppTheme.accentOrangeLight,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isStaff ? AppTheme.primary : AppTheme.accentOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        final newRole = isStaff ? UserRole.student : UserRole.staff;
                        appState.switchRole(newRole);
                        if (newRole == UserRole.staff) {
                          Navigator.pushReplacementNamed(context, '/staff_portal');
                        } else {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isStaff ? Icons.admin_panel_settings_rounded : Icons.school_rounded,
                            size: 15,
                            color: isStaff ? AppTheme.primary : AppTheme.accentOrange,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isStaff ? 'Staff Mode' : 'Student Mode',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isStaff ? AppTheme.primary : AppTheme.accentOrange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: isStaff ? AppTheme.primary : AppTheme.accentOrange,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Cart Button (Student Mode)
                  if (!isStaff)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/checkout_slots');
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.surfaceLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primary, size: 22),
                          tooltip: 'Checkout & Time Slots',
                        ),
                        if (appState.totalCartItems > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppTheme.accentOrange,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  '${appState.totalCartItems}',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(width: 8),

                  // User Profile or Login
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.person_outline_rounded, color: AppTheme.primary, size: 22),
                    tooltip: 'Account Login',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context, {
    required String title,
    required String route,
    required IconData icon,
  }) {
    final isSelected = activeRoute == route;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextSpanWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double letterSpacing;

  const TextSpanWidget({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
    required this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.beVietnamPro(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
