import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/constants.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class ParsedOrderResult {
  final List<CartItem> items;
  final String? pickupSlot;
  final String? specialInstructions;
  final String rawResponse;
  final bool isSuccessful;
  final String? errorMessage;

  ParsedOrderResult({
    required this.items,
    this.pickupSlot,
    this.specialInstructions,
    required this.rawResponse,
    this.isSuccessful = true,
    this.errorMessage,
  });
}

class GeminiService {
  static final GeminiService instance = GeminiService._internal();
  GeminiService._internal();

  String _apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  GenerativeModel? _model;

  void setApiKey(String key) {
    _apiKey = key;
    if (key.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: key,
      );
    }
  }

  String get currentApiKey => _apiKey;

  Future<ParsedOrderResult> parseNaturalOrder(String userInput, List<FoodItem> menu) async {
    final cleanInput = userInput.trim();
    if (cleanInput.isEmpty) {
      return ParsedOrderResult(
        items: [],
        rawResponse: '',
        isSuccessful: false,
        errorMessage: 'Please type an order request.',
      );
    }

    // Try Gemini API if key is available
    if (_apiKey.isNotEmpty) {
      try {
        _model ??= GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

        final menuDescriptions = menu.map((i) => '- "${i.name}" (price: ₹${i.price}, category: ${i.category})').join('\n');
        final slotsList = AppConstants.pickupSlots.join(', ');

        final prompt = '''
You are the AI Order Parser for CampusEats smart campus dining.
Parse the following student natural language order request into structured JSON.

MENU ITEMS AVAILABLE:
$menuDescriptions

AVAILABLE PICKUP TIME SLOTS:
$slotsList

STUDENT REQUEST:
"$cleanInput"

Respond ONLY with a valid JSON object in this exact schema without any markdown wrapping or commentary:
{
  "items": [
    {
      "name": "exact or closest matching food item name from menu",
      "quantity": integer number,
      "specialInstructions": "optional special request if any"
    }
  ],
  "pickupSlot": "exact matching time slot string from available list, or closest match",
  "specialInstructions": "optional general order instructions"
}
''';

        final response = await _model!.generateContent([Content.text(prompt)]);
        final responseText = response.text?.trim() ?? '';

        // Extract JSON substring if wrapped in markdown code blocks
        String jsonString = responseText;
        if (jsonString.contains('```json')) {
          jsonString = jsonString.split('```json')[1].split('```')[0].trim();
        } else if (jsonString.contains('```')) {
          jsonString = jsonString.split('```')[1].split('```')[0].trim();
        }

        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final parsedItems = <CartItem>[];

        if (decoded['items'] is List) {
          for (final rawItem in decoded['items']) {
            final name = rawItem['name']?.toString() ?? '';
            final qty = (rawItem['quantity'] as num?)?.toInt() ?? 1;
            final itemNotes = rawItem['specialInstructions']?.toString();

            final matchedFood = _matchFoodItem(name, menu);
            if (matchedFood != null) {
              parsedItems.add(
                CartItem(
                  item: matchedFood,
                  quantity: qty.clamp(1, 20),
                  specialInstructions: itemNotes,
                ),
              );
            }
          }
        }

        String? slot = decoded['pickupSlot']?.toString();
        slot = _matchSlot(slot);

        return ParsedOrderResult(
          items: parsedItems,
          pickupSlot: slot,
          specialInstructions: decoded['specialInstructions']?.toString(),
          rawResponse: responseText,
          isSuccessful: parsedItems.isNotEmpty,
          errorMessage: parsedItems.isEmpty ? 'Could not match any menu items.' : null,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Gemini API call error (falling back to smart local heuristic parser): $e');
        }
      }
    }

    // Smart Local Heuristic Parser Fallback
    return _parseWithLocalHeuristic(cleanInput, menu);
  }

  FoodItem? _matchFoodItem(String nameQuery, List<FoodItem> menu) {
    final query = nameQuery.toLowerCase().trim();
    if (query.isEmpty) return null;

    // Exact name match
    for (final item in menu) {
      if (item.name.toLowerCase() == query) return item;
    }

    // Keyword match
    for (final item in menu) {
      final itemName = item.name.toLowerCase();
      if (query.contains('samosa') && itemName.contains('samosa')) return item;
      if ((query.contains('chai') || query.contains('tea')) && itemName.contains('chai')) return item;
      if ((query.contains('roll') || query.contains('kathi') || query.contains('paneer roll')) && itemName.contains('roll')) return item;
      if ((query.contains('pav') || query.contains('bhaji')) && itemName.contains('bhaji')) return item;
      if (query.contains('burger') && itemName.contains('burger')) return item;
      if ((query.contains('coffee') || query.contains('cold coffee')) && itemName.contains('coffee')) return item;
      if ((query.contains('chole') || query.contains('bhature')) && itemName.contains('chole')) return item;
      if ((query.contains('lassi') || query.contains('mango')) && itemName.contains('lassi')) return item;
    }

    // Partial contains
    for (final item in menu) {
      if (item.name.toLowerCase().contains(query) || query.contains(item.name.toLowerCase())) {
        return item;
      }
    }

    return null;
  }

  String? _matchSlot(String? rawSlot) {
    if (rawSlot == null) return null;
    final slotQuery = rawSlot.toLowerCase().replaceAll(' ', '').replaceAll('.', '');

    for (final slot in AppConstants.pickupSlots) {
      final normalized = slot.toLowerCase().replaceAll(' ', '').replaceAll('.', '');
      if (slotQuery.contains(normalized) || normalized.contains(slotQuery)) {
        return slot;
      }
    }

    // Approximate time numbers
    if (slotQuery.contains('1:15') || slotQuery.contains('115')) return '1:15 PM';
    if (slotQuery.contains('1:30') || slotQuery.contains('130')) return '1:30 PM';
    if (slotQuery.contains('1:00') || slotQuery.contains('100') || slotQuery.contains('1pm')) return '1:00 PM';
    if (slotQuery.contains('12:45') || slotQuery.contains('1245')) return '12:45 PM';
    if (slotQuery.contains('12:30') || slotQuery.contains('1230')) return '12:30 PM';
    if (slotQuery.contains('1:45') || slotQuery.contains('145')) return '1:45 PM';
    if (slotQuery.contains('2:00') || slotQuery.contains('200') || slotQuery.contains('2pm')) return '2:00 PM';
    if (slotQuery.contains('2:15') || slotQuery.contains('215')) return '2:15 PM';
    if (slotQuery.contains('2:30') || slotQuery.contains('230')) return '2:30 PM';

    return null;
  }

  ParsedOrderResult _parseWithLocalHeuristic(String input, List<FoodItem> menu) {
    final lower = input.toLowerCase();
    final parsedItems = <CartItem>[];

    // Check food items
    final keywords = {
      'samosa': 'Crispy Aloo Samosa (2 pcs)',
      'chai': 'Special Masala Chai',
      'tea': 'Special Masala Chai',
      'roll': 'Paneer Tikka Kathi Roll',
      'kathi': 'Paneer Tikka Kathi Roll',
      'paneer': 'Paneer Tikka Kathi Roll',
      'pav': 'Classic Butter Pav Bhaji',
      'bhaji': 'Classic Butter Pav Bhaji',
      'burger': 'Campus Veggie Burger Deluxe',
      'coffee': 'Iced Cold Coffee',
      'chole': 'Chole Bhature Platter',
      'bhature': 'Chole Bhature Platter',
      'lassi': 'Alphonso Mango Lassi',
    };

    final numberWords = {
      'one': 1, '1': 1, 'a ': 1, 'an ': 1,
      'two': 2, '2': 2,
      'three': 3, '3': 3,
      'four': 4, '4': 4,
      'five': 5, '5': 5,
      'six': 6, '6': 6,
    };

    final matchedItemNames = <String>{};

    for (final entry in keywords.entries) {
      if (lower.contains(entry.key)) {
        final targetName = entry.value;
        if (matchedItemNames.contains(targetName)) continue;

        int qty = 1;
        // Search preceding numbers around keyword
        for (final numEntry in numberWords.entries) {
          final pattern1 = '${numEntry.key} ${entry.key}';
          final pattern2 = '${numEntry.key}x ${entry.key}';
          final pattern3 = '${numEntry.key} pcs ${entry.key}';
          if (lower.contains(pattern1) || lower.contains(pattern2) || lower.contains(pattern3)) {
            qty = numEntry.value;
            break;
          }
        }

        final food = menu.firstWhere(
          (m) => m.name == targetName,
          orElse: () => menu.first,
        );

        parsedItems.add(CartItem(item: food, quantity: qty));
        matchedItemNames.add(targetName);
      }
    }

    // Parse Slot
    final slot = _matchSlot(lower);

    if (parsedItems.isEmpty) {
      return ParsedOrderResult(
        items: [],
        rawResponse: 'No recognizable menu items found in query: "$input"',
        isSuccessful: false,
        errorMessage: 'Could not match food items. Try: "Order 2 Samosas and 1 Chai for 1:15 PM"',
      );
    }

    return ParsedOrderResult(
      items: parsedItems,
      pickupSlot: slot ?? '1:15 PM',
      rawResponse: 'Local Parser matched ${parsedItems.length} items for slot ${slot ?? '1:15 PM'}',
      isSuccessful: true,
    );
  }
}
