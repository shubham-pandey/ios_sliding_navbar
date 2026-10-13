import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_sliding_navbar/ios_sliding_navbar.dart';

void main() {
  testWidgets('SlidingSegmentedNavbar renders with string items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SlidingSegmentedNavbar(
            items: ['Tab A', 'Tab B', 'Tab C'],
          ),
        ),
      ),
    );

    expect(find.text('Tab A'), findsOneWidget);
    expect(find.text('Tab B'), findsOneWidget);
    expect(find.text('Tab C'), findsOneWidget);
  });

  testWidgets('SlidingSegmentedNavbar renders with navItems', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SlidingSegmentedNavbar(
            navItems: [
              SlidingNavItem(label: 'Home', icon: Icons.home),
              SlidingNavItem(label: 'Orders', icon: Icons.receipt_long, showBadge: true),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
  });

  testWidgets('onTabChanged fires on tap', (tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SlidingSegmentedNavbar(
            items: const ['A', 'B'],
            onTabChanged: (i) => tappedIndex = i,
          ),
        ),
      ),
    );

    // Tap the second tab
    await tester.tapAt(tester.getCenter(find.text('B')));
    await tester.pumpAndSettle();

    expect(tappedIndex, 1);
  });
}
