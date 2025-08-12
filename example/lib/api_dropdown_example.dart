import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:super_search_delegate/universal_dropdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApiDropdownExample(),
    );
  }
}

class ApiDropdownExample extends StatefulWidget {
  const ApiDropdownExample({super.key});

  @override
  State<ApiDropdownExample> createState() => _ApiDropdownExampleState();
}

class _ApiDropdownExampleState extends State<ApiDropdownExample> {
  final Dio dio = Dio();
  bool isLoading = true;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  /// Fetch users from API
  Future<void> fetchUsers() async {
    try {
      final response =
          await dio.get("https://jsonplaceholder.typicode.com/users");
      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response.data);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API-based UniversalDropdown")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : UniversalDropdown<Map<String, dynamic>>(
                items: users,
                selectedItems: selectedUsers,
                itemLabel: (user) => user["name"],
                isMultiSelect: true,
                showCheckbox: true,
                searchable: true,
                customItemWidget: (user) => ListTile(
                  leading: CircleAvatar(child: Text(user["name"][0])),
                  title: Text(user["name"]),
                  subtitle: Text(user["email"]),
                ),
                onSelectionChanged: (selected) {
                  setState(() => selectedUsers = selected);
                },
              ),
      ),
    );
  }
}
