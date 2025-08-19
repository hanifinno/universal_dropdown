Got it ✅
Here’s a **README.md** styled like your example, but adapted for your current `UniversalDropdown<T>` implementation with **all the real parameters** and proper examples.

---

````markdown
# 🔽 Universal Dropdown

[![Pub Version](https://img.shields.io/pub/v/universal_dropdown)](https://pub.dev/packages/universal_dropdown)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A **highly customizable**, **type-safe**, and **feature-rich dropdown widget** for Flutter.  
Works with **any data model**, supports **single/multi-select**, **search**, **pagination**, **custom chips**, and multiple display modes (**overlay** or **bottom sheet**).

---

## ✨ Key Features

- ✅ Works with **any data model** (`String`, `Map`, custom class, etc.)
- 🎯 Supports **single** or **multi-select**
- 🔍 **Searchable** dropdown support
- 📜 **Pagination** with async data fetching
- 🖌️ Fully customizable **style and layout**
- 🏷️ Customizable **selected item chips**
- 📱 Two modes: **Overlay** or **Bottom Sheet**

---

## 🔧 Installation

Add the latest version to your `pubspec.yaml`:

```yaml
dependencies:
  universal_dropdown: ^1.0.7
````

---

## 💻 Basic Usage

```dart
import 'package:flutter/material.dart';
import 'universal_dropdown.dart'; // Import your widget

class MyDropdownExample extends StatefulWidget {
  @override
  State<MyDropdownExample> createState() => _MyDropdownExampleState();
}

class _MyDropdownExampleState extends State<MyDropdownExample> {
  List<String> fruits = ["Apple", "Banana", "Mango", "Orange"];
  List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Universal Dropdown Example")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: UniversalDropdown<String>(
          items: fruits,
          selectedItems: selected,
          itemLabel: (item) => item,
          onChanged: (selectedItems) {
            setState(() => selected = selectedItems);
          },
          searchable: true,
          searchPlaceholder: "Search fruits...",
          multiSelect: false,
        ),
      ),
    );
  }
}
```

---

## 🧩 Usage with Custom Model

```dart
class Country {
  final String code;
  final String name;
  Country(this.code, this.name);
}

final countries = [
  Country('US', 'United States'),
  Country('IN', 'India'),
  Country('JP', 'Japan'),
];

UniversalDropdown<Country>(
  items: countries,
  selectedItems: [],
  itemLabel: (country) => country.name,
  onChanged: (selected) {
    print("Selected country: ${selected.first.name}");
  },
  searchable: true,
);
```

---

## 📜 Paginated Dropdown Example

```dart
Future<List<String>> fetchItems(int page, int pageSize) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return List.generate(pageSize, (index) => "Item ${page * pageSize + index + 1}");
}

UniversalDropdown<String>(
  fetchItems: fetchItems,
  selectedItems: [],
  itemLabel: (item) => item,
  onChanged: (selected) => print(selected),
  paginate: true,
  pageSize: 10,
  searchable: true,
  multiSelect: true,
);
```

---

## 🏷️ Multi-Select with Custom Chips

```dart
UniversalDropdown<String>(
  items: ["Flutter", "Dart", "React", "NodeJS"],
  selectedItems: [],
  itemLabel: (item) => item,
  onChanged: (selected) => print(selected),
  multiSelect: true,
  chipBuilder: (item, onRemove) => Chip(
    label: Text(item, style: const TextStyle(color: Colors.white)),
    backgroundColor: Colors.blue,
    onDeleted: onRemove,
  ),
);
```

---

## ⚙️ API Reference

| Property             | Type                                                | Description                                |
| -------------------- | --------------------------------------------------- | ------------------------------------------ |
| `items`              | `List<T>?`                                          | Static list of items to show.              |
| `fetchItems`         | `Future<List<T>> Function(int page, int pageSize)?` | Async function to load paginated data.     |
| `selectedItems`      | `List<T>`                                           | Currently selected items.                  |
| `multiSelect`        | `bool`                                              | Allows multiple selections if `true`.      |
| `searchable`         | `bool`                                              | Shows search bar if `true`.                |
| `searchPlaceholder`  | `String`                                            | Placeholder text for search bar.           |
| `paginate`           | `bool`                                              | Enables pagination with `fetchItems`.      |
| `pageSize`           | `int`                                               | Items per page when paginating.            |
| `itemLabel`          | `String Function(T)`                                | Returns display label for each item.       |
| `onChanged`          | `Function(List<T>)`                                 | Callback when selection changes.           |
| `mode`               | `DropdownMode`                                      | `overlay` or `bottomSheet`.                |
| `dropdownDecoration` | `BoxDecoration?`                                    | Custom dropdown container styling.         |
| `dropdownMaxHeight`  | `double`                                            | Max height of dropdown list.               |
| `dropdownOffset`     | `Offset`                                            | Position adjustment for dropdown.          |
| `dropdownAlignment`  | `Alignment`                                         | Alignment of dropdown relative to trigger. |
| `chipBuilder`        | `Widget Function(T item, VoidCallback onRemove)?`   | Custom builder for selected item chips.    |
| `chipSpacing`        | `double`                                            | Space between chips.                       |
| `chipWrapAlignment`  | `WrapAlignment`                                     | Alignment of chip container.               |

---

## 📸 Screenshots

| Single Select                     | Multi Select                    | Pagination                                |
| --------------------------------- | ------------------------------- | ----------------------------------------- |
| ![Single](screenshots/single.png) | ![Multi](screenshots/multi.png) | ![Pagination](screenshots/pagination.png) |

---

## 🎥 Demo GIF

![Demo](screenshots/demo.gif)

---

## 🙌 Maintained and Powered by

📧 **[hanifuddin.dev@gmail.com](mailto:hanifuddin.dev@gmail.com)**

```

