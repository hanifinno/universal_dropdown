import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_dropdown/universal_dropdown.dart';

void main() {
  group('UniversalDropdown - basic tests', () {
    late List<String> staticItems;
    late List<String> selected;
    late Widget dropdown;

    setUp(() {
      staticItems = ['Apple', 'Banana', 'Cherry'];
      selected = [];

      dropdown = MaterialApp(
        home: Scaffold(
          body: UniversalDropdown<String>(
            items: staticItems,
            selectedItems: const [],
            onChanged: (s) => selected = s,
            itemBuilder: (ctx, item, isSelected, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(item, key: ValueKey(item)),
              );
            },
          ),
        ),
      );
    });

    testWidgets('shows placeholder initially', (tester) async {
      await tester.pumpWidget(dropdown);

      expect(find.text('Select…'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('opens overlay and shows items', (tester) async {
      await tester.pumpWidget(dropdown);

      // Tap the field to open overlay
      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('selects an item in single select mode', (tester) async {
      await tester.pumpWidget(dropdown);

      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      // Should close dropdown and update selection
      expect(selected, ['Banana']);
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('multiSelect allows multiple selections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalDropdown<String>(
              items: staticItems,
              multiSelect: true,
              selectedItems: const [],
              onChanged: (s) => selected = s,
              itemBuilder: (ctx, item, isSelected, index) =>
                  Text(item, key: ValueKey(item)),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(selected, ['Apple', 'Banana']);
    });

    testWidgets('search filters items in static list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalDropdown<String>(
              items: staticItems,
              searchable: true,
              selectedItems: const [],
              onChanged: (s) => selected = s,
              itemBuilder: (ctx, item, isSelected, index) =>
                  Text(item, key: ValueKey(item)),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select…'));
      await tester.pumpAndSettle();

      // Search for "Banana"
      await tester.enterText(find.byType(TextField), 'Banana');
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Cherry'), findsNothing);
    });
  });
}
