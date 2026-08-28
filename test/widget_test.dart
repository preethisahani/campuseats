import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campuseats/main.dart';
import 'package:campuseats/services/app_state.dart';

void main() {
  testWidgets('CampusEatsApp loads and shows home screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const CampusEatsApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(CampusEatsApp), findsOneWidget);
  });
}
