import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';
import '../../services/app_state.dart';
import '../../widgets/app_navbar.dart';

class ExploreCanteensScreen extends StatefulWidget {
  const ExploreCanteensScreen({super.key});

  @override
  State<ExploreCanteensScreen> createState() => _ExploreCanteensScreenState();
}

class _ExploreCanteensScreenState extends State<ExploreCanteensScreen> {
  String _searchQuery = '';
  String _selectedTag = 'All';

  final List<String> _tags = [
    'All',
    'North Indian',
    'South Indian',
    'Snacks',
    'Beverages',
    'Salads',
    'Quick Bites',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filteredCanteens = AppConstants.canteens.where((c) {
      final matchesQuery = c['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesQuery) return false;

      if (_selectedTag == 'All') return true;
      final tags = c['tags'] as List<String>;
      return tags.contains(_selectedTag);
    }).toList();

    return Scaffold(
      appBar: const AppNavbar(activeRoute: '/explore_canteens'),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Text(
                    'Campus Dining Venues',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find live kitchen statuses, estimated wait times, and order ahead to skip queues.',
                    style: GoogleFonts.beVietnamPro(fontSize: 15, color: AppTheme.onSurfaceVariant),
                  ),

                  const SizedBox(height: 24),

                  // Search & Filter Bar
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search canteen by name or campus location...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                            filled: true,
                            fillColor: AppTheme.surfaceWhite,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tags.map((tag) {
                        final isSel = _selectedTag == tag;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tag),
                            selected: isSel,
                            onSelected: (val) {
                              if (val) setState(() => _selectedTag = tag);
                            },
                            selectedColor: AppTheme.primary,
                            labelStyle: GoogleFonts.beVietnamPro(
                              color: isSel ? Colors.white : AppTheme.onSurfaceVariant,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                            backgroundColor: AppTheme.surfaceWhite,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Canteens List
                  if (filteredCanteens.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(48),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.outline),
                          const SizedBox(height: 12),
                          Text(
                            'No canteens found matching "$_searchQuery"',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredCanteens.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final canteen = filteredCanteens[index];
                        final occupancy = canteen['occupancy'] as int;
                        final isBusy = occupancy >= 70;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.surfaceContainer),
                            boxShadow: AppTheme.shadowLevel1,
                          ),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: Image.network(
                                  canteen['image'],
                                  width: 220,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 220,
                                    height: 180,
                                    color: AppTheme.surfaceLow,
                                    child: const Icon(Icons.restaurant, size: 48, color: AppTheme.outline),
                                  ),
                                ),
                              ),

                              // Content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            canteen['name'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isBusy ? AppTheme.busyOrangeBg : AppTheme.fastPickGreenBg,
                                              borderRadius: BorderRadius.circular(99),
                                            ),
                                            child: Text(
                                              isBusy ? '🔥 Busy Queue' : '⚡ Quick Service',
                                              style: GoogleFonts.beVietnamPro(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isBusy ? AppTheme.busyOrange : AppTheme.fastPickGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.outline),
                                          const SizedBox(width: 4),
                                          Text(
                                            canteen['location'],
                                            style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Tags
                                      Wrap(
                                        spacing: 6,
                                        children: (canteen['tags'] as List<String>).map((t) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceLow,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              t,
                                              style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppTheme.onSurfaceVariant),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.timer_outlined, size: 16, color: AppTheme.secondary),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Estimated Wait: ${canteen['waitTime']}',
                                                style: GoogleFonts.beVietnamPro(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              appState.selectCanteen(canteen['id'], canteen['name']);
                                              Navigator.pushNamed(context, '/canteen_menu');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.accentOrange,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: const Icon(Icons.restaurant_menu_rounded, size: 16),
                                            label: Text(
                                              'Order from Menu',
                                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
