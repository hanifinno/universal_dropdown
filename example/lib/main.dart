import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:super_search_delegate/universal_dropdown.dart';

// Import your UniversalDropdown widget here
// import 'path_to/universal_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniversalDropdown Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final Dio dio = Dio();
  // Simple list of fruits
  final List<String> fruits = [
    'Apple',
    'Banana',
    'Orange',
    'Mango',
    'Grapes',
    'Pineapple',
    'Strawberry',
  ];

  // Selected items for various dropdowns
  List<String> selectedSingle = [];
  List<String> selectedMulti = [];
  List<String> selectedSearchable = [];
  List<String> selectedCustomChip = [];
  List<String> selectedApiUsers = [];

  // API fetcher for users (paginated)
  Future<List<String>> fetchUsers(int page, int pageSize) async {
    try {
      final response =
          await dio.get('https://jsonplaceholder.typicode.com/users');
      if (response.statusCode == 200) {
        final List data = response.data;
        final allNames = data.map<String>((u) => u['name'].toString()).toList();
        final start = page * pageSize;
        if (start >= allNames.length) return [];
        final end = (start + pageSize).clamp(0, allNames.length);
        return allNames.sublist(start, end);
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UniversalDropdown All Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1️⃣ Basic Single Select',
                style: TextStyle(fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              items: fruits,
              initialSelectedItems: selectedSingle,
              itemLabel: (item) => item,
              onSelectionChanged: (selected) =>
                  setState(() => selectedSingle = selected),
              dropdownWidth: 300,
            ),
            _buildSelectedText(selectedSingle),
            const Divider(),
            const Text('2️⃣ Multi Select with Checkboxes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              items: fruits,
              initialSelectedItems: selectedMulti,
              itemLabel: (item) => item,
              isMultiSelect: true,
              onSelectionChanged: (selected) =>
                  setState(() => selectedMulti = selected),
              dropdownWidth: 300,
            ),
            _buildSelectedText(selectedMulti),
            const Divider(),
            const Text('3️⃣ Searchable Multi Select',
                style: TextStyle(fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              items: fruits,
              initialSelectedItems: selectedSearchable,
              itemLabel: (item) => item,
              isMultiSelect: true,
              // Assuming your UniversalDropdown supports searchable internally;
              // if not, you can extend it with a search bar
              onSelectionChanged: (selected) =>
                  setState(() => selectedSearchable = selected),
              dropdownWidth: 300,
            ),
            _buildSelectedText(selectedSearchable),
            const Divider(),
            const Text('4️⃣ Custom Chip Builder',
                style: TextStyle(fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              items: fruits,
              initialSelectedItems: selectedCustomChip,
              itemLabel: (item) => item,
              isMultiSelect: true,
              onSelectionChanged: (selected) =>
                  setState(() => selectedCustomChip = selected),
              chipBuilder: (item, onDeleted) => Chip(
                label: Text(item),
                avatar: const Icon(Icons.local_florist,
                    size: 20, color: Colors.green),
                backgroundColor: Colors.green.shade100,
                onDeleted: onDeleted,
              ),
              dropdownWidth: 300,
            ),
            _buildSelectedText(selectedCustomChip),
            const Divider(),
            const Text('5️⃣ API-driven Paginated Multi Select',
                style: TextStyle(fontWeight: FontWeight.bold)),
            UniversalDropdown<String>(
              itemFetcher: fetchUsers,
              pageSize: 5,
              initialSelectedItems: selectedApiUsers,
              itemLabel: (item) => item,
              isMultiSelect: true,
              onSelectionChanged: (selected) =>
                  setState(() => selectedApiUsers = selected),
              chipBuilder: (item, onDeleted) => Chip(
                label: Text(item),
                backgroundColor: Colors.blue.shade100,
                onDeleted: onDeleted,
              ),
              dropdownWidth: 350,
              showAsBottomSheet:
                  true, // Try toggling between overlay and bottom sheet
            ),
            _buildSelectedText(selectedApiUsers),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedText(List<String> selected) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          selected.isEmpty
              ? 'Selected: None'
              : 'Selected: ${selected.join(', ')}',
          style:
              const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
}
