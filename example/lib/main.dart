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
  // Single select
  List<String> selectedSingle = [];

  // Multi select
  List<String> selectedMulti = [];

  // Searchable multi-select
  List<String> selectedSearchable = [];

  // Pagination / API simulation
  List<String> selectedApi = [];

  // Bottom sheet multi-select
  List<String> selectedBottomSheet = [];

  final List<String> fruits = [
    'Apple',
    'Banana',
    'Mango',
    'Orange',
    'Pineapple',
    'Strawberry',
    'Watermelon',
    'Papaya',
    'Kiwi'
  ];

  // Simulate API fetch with pagination
  Future<List<String>> fetchItems(int page, int pageSize, String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    List<String> all =
        List.generate(50, (index) => 'Item ${index + 1}'); // 50 simulated items
    if (query.isNotEmpty) {
      all = all
          .where((e) => e.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    return all.sublist(start, end > all.length ? all.length : end);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1️⃣ Single Select',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            UniversalDropdown<String>(
              items: fruits,
              selectedItems: selectedSingle,
              onChanged: (val) => setState(() => selectedSingle = val),
              itemBuilder: (context, item, selected, index) => Text(item),
              multiSelect: false,
            ),
            const SizedBox(height: 24),
            const Text('2️⃣ Multi Select with Checkbox',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            UniversalDropdown<String>(
              items: fruits,
              selectedItems: selectedMulti,
              onChanged: (val) => setState(() => selectedMulti = val),
              itemBuilder: (context, item, selected, index) => Text(item),
              multiSelect: true,
              checkboxPosition: CheckboxPosition.leading,
              chipPlacement: ChipPlacement.belowField,
            ),
            const SizedBox(height: 24),
            const Text('3️⃣ Searchable Multi Select',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            UniversalDropdown<String>(
              items: fruits,
              selectedItems: selectedSearchable,
              onChanged: (val) => setState(() => selectedSearchable = val),
              itemBuilder: (context, item, selected, index) => Text(item),
              multiSelect: true,
              searchable: true,
              chipPlacement: ChipPlacement.belowField,
            ),
            const SizedBox(height: 24),
            const Text('4️⃣ Pagination / API Multi Select',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            UniversalDropdown<String>(
              fetchItems: fetchItems,
              selectedItems: selectedApi,
              onChanged: (val) => setState(() => selectedApi = val),
              itemBuilder: (context, item, selected, index) => Text(item),
              multiSelect: true,
              searchable: true,
              paginate: true,
              pageSize: 10,
              chipPlacement: ChipPlacement.belowField,
              checkboxPosition: CheckboxPosition.leading,
            ),
            const SizedBox(height: 24),
            const Text('5️⃣ Bottom Sheet Multi Select',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            UniversalDropdown<String>(
              items: fruits,
              selectedItems: selectedBottomSheet,
              onChanged: (val) => setState(() => selectedBottomSheet = val),
              itemBuilder: (context, item, selected, index) => Text(item),
              multiSelect: true,
              mode: DropdownMode.bottomSheet,
              chipPlacement: ChipPlacement.belowField,
              checkboxPosition: CheckboxPosition.leading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
