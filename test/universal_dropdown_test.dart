import 'package:flutter/material.dart';
import 'package:universal_dropdown/universal_dropdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('UniversalDropdown single select opens and selects item', (
    tester,
  ) async {
    final items = ['Apple', 'Banana', 'Orange'];
    List<String> selectedItems = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UniversalDropdown<String>(
            items: items,
            itemLabel: (item) => item,
            onSelectionChanged: (selected) => selectedItems = selected,
          ),
        ),
      ),
    );

    // Verify hint text is shown initially
    expect(find.text('Select item'), findsOneWidget);

    // Tap to open dropdown
    await tester.tap(find.byType(UniversalDropdown<String>));
    await tester.pumpAndSettle();

    // Dropdown list should show items
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);

    // Tap an item
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    // Dropdown should close after selection (single select)
    expect(find.text('Banana'), findsOneWidget);
    expect(selectedItems, ['Banana']);
  });

  testWidgets('UniversalDropdown multi select allows multiple selections', (
    tester,
  ) async {
    final items = ['Red', 'Green', 'Blue'];
    List<String> selectedItems = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UniversalDropdown<String>(
            items: items,
            itemLabel: (item) => item,
            isMultiSelect: true,
            onSelectionChanged: (selected) => selectedItems = selected,
          ),
        ),
      ),
    );

    // Open dropdown
    await tester.tap(find.byType(UniversalDropdown<String>));
    await tester.pumpAndSettle();

    // Select first item
    await tester.tap(find.text('Red'));
    await tester.pump();

    // Select second item
    await tester.tap(find.text('Blue'));
    await tester.pump();

    expect(selectedItems.contains('Red'), true);
    expect(selectedItems.contains('Blue'), true);
    expect(selectedItems.length, 2);
  });

  testWidgets('UniversalDropdown pagination loads more items', (tester) async {
    // Simulated paginated fetcher
    Future<List<String>> fetcher(int page, int pageSize) async {
      await Future.delayed(Duration(milliseconds: 10));
      if (page > 1) return [];
      return List.generate(
        pageSize,
        (index) => 'Item ${page * pageSize + index}',
      );
    }

    List<String> selectedItems = [];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UniversalDropdown<String>(
            itemFetcher: fetcher,
            pageSize: 10,
            itemLabel: (item) => item,
            onSelectionChanged: (selected) => selectedItems = selected,
          ),
        ),
      ),
    );

    // Open dropdown
    await tester.tap(find.byType(UniversalDropdown<String>));
    await tester.pumpAndSettle();

    // Initial 10 items
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 9'), findsOneWidget);

    // Scroll to bottom to trigger pagination
    final listFinder = find.byType(ListView);
    await tester.drag(listFinder, const Offset(0, -500));
    await tester.pumpAndSettle();

    // After loading more items, "Item 10" should appear
    expect(find.text('Item 10'), findsOneWidget);

    // Select an item
    await tester.tap(find.text('Item 5'));
    await tester.pumpAndSettle();

    expect(selectedItems, ['Item 5']);
  });
}
