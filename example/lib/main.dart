import 'dart:async';
import 'package:flutter/material.dart';
import 'package:super_search_delegate/universal_dropdown.dart';

void main() {
  runApp(const MaterialApp(
    home: DropdownDemoPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class DropdownDemoPage extends StatefulWidget {
  const DropdownDemoPage({Key? key}) : super(key: key);

  @override
  State<DropdownDemoPage> createState() => _DropdownDemoPageState();
}

class _DropdownDemoPageState extends State<DropdownDemoPage> {
  List<String> staticItems = [
    "Apple",
    "Banana",
    "Cherry",
    "Dragonfruit",
    "Elderberry",
    "Fig",
    "Grapes",
    "Honeydew",
  ];

  List<String> selectedFruits = [];
  List<String> selectedPaginatedItems = [];
  List<String> selectedCustomChipItems = [];

  /// Simulated API for pagination
  Future<List<String>> fetchItems(int page, int pageSize) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate delay
    int start = page * pageSize;
    int end = start + pageSize;
    List<String> allItems = List.generate(
        50, (index) => "Item ${(index + 1).toString().padLeft(2, '0')}");
    if (start >= allItems.length) return [];
    return allItems.sublist(
        start, end > allItems.length ? allItems.length : end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UniversalDropdown Demo"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 1️⃣ Simple Single Select (Overlay Mode)
            const Text("Single Select (Overlay)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              items: staticItems,
              selectedItems:
                  selectedFruits.isNotEmpty ? [selectedFruits.first] : [],
              itemLabel: (item) => item,
              onChanged: (selected) {
                setState(() => selectedFruits = selected);
              },
              multiSelect: false,
              searchable: true,
              searchPlaceholder: "Search fruits...",
              mode: DropdownMode.overlay,
            ),
            const SizedBox(height: 20),
            Text(
                "Selected: ${selectedFruits.isEmpty ? 'None' : selectedFruits.first}"),

            const Divider(height: 40),

            /// 2️⃣ Multi Select with Chips (BottomSheet Mode)
            const Text("Multi Select with Chips",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              items: staticItems,
              selectedItems: selectedCustomChipItems,
              itemLabel: (item) => item,
              onChanged: (selected) {
                setState(() => selectedCustomChipItems = selected);
              },
              multiSelect: true,
              searchable: true,
              chipBuilder: (item, onRemove) => Chip(
                label: Text(item, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.blue,
                deleteIcon: const Icon(Icons.close, color: Colors.white),
                onDeleted: onRemove,
              ),
              chipSpacing: 8,
              chipWrapAlignment: WrapAlignment.start,
              mode: DropdownMode.bottomSheet,
            ),
            const SizedBox(height: 20),
            Text("Selected: ${selectedCustomChipItems.join(', ')}"),

            const Divider(height: 40),

            /// 3️⃣ Paginated Dropdown (Overlay Mode)
            const Text("Paginated Dropdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              fetchItems: fetchItems,
              selectedItems: selectedPaginatedItems,
              itemLabel: (item) => item,
              onChanged: (selected) {
                setState(() => selectedPaginatedItems = selected);
              },
              multiSelect: true,
              paginate: true,
              pageSize: 8,
              searchable: true,
              searchPlaceholder: "Search items...",
              mode: DropdownMode.overlay,
            ),
            const SizedBox(height: 20),
            Text("Selected: ${selectedPaginatedItems.join(', ')}"),
          ],
        ),
      ),
    );
  }
}
