import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/app_state.dart';
import '../services/gemini_service.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';

class AIOrderBar extends StatefulWidget {
  final List<FoodItem> menu;
  final Function(List<CartItem> items, String? slot)? onOrderParsed;

  const AIOrderBar({
    super.key,
    required this.menu,
    this.onOrderParsed,
  });

  @override
  State<AIOrderBar> createState() => _AIOrderBarState();
}

class _AIOrderBarState extends State<AIOrderBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _examplePrompts = [
    '2 Samosas and 1 Masala Chai for 1:15 PM',
    '1 Paneer Tikka Kathi Roll and Cold Coffee for 1:30 PM',
    '2 Pav Bhaji and 1 Mango Lassi for 12:45 PM',
    'Chole Bhature for 2:00 PM slot',
  ];

  Future<void> _handleParse([String? customPrompt]) async {
    final query = customPrompt ?? _controller.text;
    if (query.trim().isEmpty) return;

    if (customPrompt != null) {
      _controller.text = customPrompt;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await GeminiService.instance.parseNaturalOrder(query, widget.menu);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result.isSuccessful && result.items.isNotEmpty) {
        _showParsedResultDialog(result);
      } else {
        setState(() {
          _errorMessage = result.errorMessage ?? 'Could not parse items. Please check food name.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Parser error: $e';
      });
    }
  }

  void _showParsedResultDialog(ParsedOrderResult result) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final total = result.items.fold(0.0, (sum, i) => sum + i.totalPrice);

            return AlertDialog(
              backgroundColor: AppTheme.surfaceWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentOrange, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gemini AI Parsed Order',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'Pickup Slot: ${result.pickupSlot ?? '1:15 PM'}',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matched Items from Menu:',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: result.items.length,
                        separatorBuilder: (context, index) => const Divider(height: 16, color: AppTheme.surfaceContainer),
                        itemBuilder: (context, idx) {
                          final cartItem = result.items[idx];
                          return Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${cartItem.quantity}x',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.item.name,
                                      style: GoogleFonts.beVietnamPro(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '₹${cartItem.item.price.toStringAsFixed(0)} each',
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: 12,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Subtotal:',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final appState = Provider.of<AppState>(context, listen: false);
                    appState.autofillCartFromAI(
                      result.items,
                      slot: result.pickupSlot,
                      instructions: result.specialInstructions,
                    );
                    widget.onOrderParsed?.call(result.items, result.pickupSlot);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.primary,
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppTheme.accentOrange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Auto-filled cart with ${result.items.length} items for ${result.pickupSlot ?? '1:15 PM'} slot!',
                                style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        action: SnackBarAction(
                          label: 'Checkout',
                          textColor: AppTheme.accentOrange,
                          onPressed: () {
                            Navigator.pushNamed(context, '/checkout_slots');
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                  label: const Text('Add to Cart & Checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryContainer.withValues(alpha: 0.5), width: 1.5),
        boxShadow: AppTheme.shadowLevel2,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.accentOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Gemini AI Express Order',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrangeLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Natural Language',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Type your order in plain English & let AI auto-fill your cart and pickup slot.',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Input Bar & Action
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _handleParse(),
                  decoration: InputDecoration(
                    hintText: 'e.g. "Order 2 Samosas and 1 Masala Chai for 1:15 PM"',
                    hintStyle: GoogleFonts.beVietnamPro(fontSize: 14, color: AppTheme.outline),
                    prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primary, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: AppTheme.surfaceLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.surfaceContainer),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.surfaceContainer),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _handleParse(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome, size: 18, color: AppTheme.accentOrange),
                label: Text(
                  _isLoading ? 'Parsing...' : 'Parse Order',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: AppTheme.capReachedRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Quick Suggestion Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Try asking:',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.outline,
                ),
              ),
              ..._examplePrompts.map((prompt) {
                return InkWell(
                  onTap: () => _handleParse(prompt),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppTheme.surfaceContainer),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.north_east_rounded, size: 11, color: AppTheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          prompt,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
