import 'package:flutter/material.dart';
import 'package:universal_dropdown/universal_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DropdownDemo());
  }
}

class DropdownDemo extends StatefulWidget {
  const DropdownDemo({super.key});

  @override
  State<DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<DropdownDemo> {
  final List<String> items = ["Apple", "Banana", "Orange", "Mango", "Grapes"];

  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Universal Dropdown Demo")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: UniversalDropdown<String>(
          items: items,
          selectedItems: selectedItems,
          itemLabel: (item) => item,
          isMultiSelect: true,
          showCheckbox: true,
          searchable: true,
          onSelectionChanged: (selected) {
            setState(() {
              selectedItems = selected;
            });
          },
        ),
      ),
    );
  }
}
