import 'package:flutter/material.dart';
import 'package:super_search_delegate/universal_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DropdownExamplePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DropdownExamplePage extends StatefulWidget {
  const DropdownExamplePage({super.key});

  @override
  State<DropdownExamplePage> createState() => _DropdownExamplePageState();
}

class _DropdownExamplePageState extends State<DropdownExamplePage> {
  // Sample data
  final List<String> fruits = [
    "Apple",
    "Banana",
    "Orange",
    "Mango",
    "Grapes",
    "Pineapple",
    "Strawberry",
  ];

  final List<Map<String, dynamic>> users = [
    {"name": "Alice", "role": "Admin"},
    {"name": "Bob", "role": "Editor"},
    {"name": "Charlie", "role": "Viewer"},
  ];

  // Selected items for different dropdowns
  List<String> selectedFruits = [];
  List<String> selectedSingleFruit = [];
  List<Map<String, dynamic>> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UniversalDropdown Examples")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1️⃣ Basic Single Select
              _buildSectionTitle("1. Basic Single Select"),
              UniversalDropdown<String>(
                items: fruits,
                selectedItems: selectedSingleFruit,
                itemLabel: (item) => item,
                onSelectionChanged: (selected) {
                  setState(() => selectedSingleFruit = selected);
                },
              ),
              _buildSelectedList(selectedSingleFruit),

              const Divider(),

              // 2️⃣ Multi Select with Checkboxes
              _buildSectionTitle("2. Multi Select with Checkboxes"),
              UniversalDropdown<String>(
                items: fruits,
                selectedItems: selectedFruits,
                itemLabel: (item) => item,
                isMultiSelect: true,
                showCheckbox: true,
                onSelectionChanged: (selected) {
                  setState(() => selectedFruits = selected);
                },
              ),
              _buildSelectedList(selectedFruits),

              const Divider(),

              // 3️⃣ Searchable Dropdown
              _buildSectionTitle("3. Searchable Dropdown"),
              UniversalDropdown<String>(
                items: fruits,
                selectedItems: selectedFruits,
                itemLabel: (item) => item,
                isMultiSelect: true,
                showCheckbox: true,
                searchable: true,
                onSelectionChanged: (selected) {
                  setState(() => selectedFruits = selected);
                },
              ),
              _buildSelectedList(selectedFruits),

              const Divider(),

              // 4️⃣ Custom Chip Builder
              _buildSectionTitle("4. Custom Chip Builder"),
              UniversalDropdown<String>(
                items: fruits,
                selectedItems: selectedFruits,
                itemLabel: (item) => item,
                isMultiSelect: true,
                showCheckbox: true,
                customChipBuilder: (item) => Chip(
                  avatar: const Icon(Icons.local_florist,
                      size: 18, color: Colors.green),
                  label: Text(item),
                  backgroundColor: Colors.green.shade100,
                  onDeleted: () {
                    setState(() => selectedFruits.remove(item));
                  },
                ),
                onSelectionChanged: (selected) {
                  setState(() => selectedFruits = selected);
                },
              ),
              _buildSelectedList(selectedFruits),

              const Divider(),

              // 5️⃣ Custom Item Widget (User List)
              _buildSectionTitle("5. Custom Item Widget"),
              UniversalDropdown<Map<String, dynamic>>(
                items: users,
                selectedItems: selectedUsers,
                itemLabel: (user) => user["name"],
                isMultiSelect: true,
                showCheckbox: true,
                searchable: true,
                customItemWidget: (user) => ListTile(
                  leading: CircleAvatar(child: Text(user["name"][0])),
                  title: Text(user["name"]),
                  subtitle: Text("Role: ${user["role"]}"),
                ),
                onSelectionChanged: (selected) {
                  setState(() => selectedUsers = selected);
                },
              ),
              _buildSelectedList(selectedUsers.map((u) => u["name"]).toList()),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Helper widget to display selected items as text
  Widget _buildSelectedList(List<dynamic> selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "Selected: ${selected.join(", ")}",
        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      ),
    );
  }
}
