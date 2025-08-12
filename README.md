
# 🔽 Universal Dropdown

[![Pub Version](https://img.shields.io/pub/v/universal_dropdown)](https://pub.dev/packages/universal_dropdown)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A **highly customizable**, **easy-to-use**, and **generic dropdown widget** for Flutter.  
Works with any data model, supports both simple and complex lists, and gives you full control over how the dropdown looks and behaves.

---

## ✨ Key Features

- ✅ Works with **any data model** (`String`, `Map`, custom class, etc.)
- 🎯 Dropdown items can be rendered with **custom widgets**
- 🔍 Optional **searchable dropdown** support
- 🖌️ Fully customizable style and layout
- ⚡ Smooth animations and performance optimized
- 📱 Keyboard and accessibility friendly

---

## 🔧 Installation

Add the latest version to your `pubspec.yaml`:

```yaml
dependencies:
  universal_dropdown: ^1.0.0
````

---


## 💻 Basic Usage

```dart

import 'package:flutter/material.dart';
import 'package:universal_dropdown/universal_dropdown.dart';

class MyDropdownExample extends StatelessWidget {
  final List<String> fruits = ["Apple", "Banana", "Mango", "Orange"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Universal Dropdown Example")),
      body: Center(
        child: UniversalDropdown<String>(
          items: fruits,
          itemBuilder: (context, item) => Text(item),
          onChanged: (value) => print("Selected: $value"),
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
  itemBuilder: (context, country) => Row(
    children: [
      Icon(Icons.flag),
      SizedBox(width: 8),
      Text(country.name),
    ],
  ),
  onChanged: (selected) {
    print("Selected country: ${selected.name}");
  },
  selectedItemBuilder: (context, country) => Text(country.name),
);
```

---

## 🔍 Searchable Dropdown Example

```dart
UniversalDropdown<String>(
  items: ["Apple", "Banana", "Mango", "Orange"],
  itemBuilder: (context, item) => Text(item),
  onChanged: (value) => print("Selected: $value"),
  isSearchable: true,
  searchHint: "Search fruits...",
);
```

---

## ⚙️ API Reference

| Property              | Type                                | Description                                                          |
| --------------------- | ----------------------------------- | -------------------------------------------------------------------- |
| `items`               | `List<T>`                           | The full list of items to show in the dropdown.                      |
| `itemBuilder`         | `Widget Function(BuildContext, T)`  | Widget builder for each item in the dropdown list.                   |
| `onChanged`           | `void Function(T)`                  | Callback triggered when an item is selected.                         |
| `selectedItemBuilder` | `Widget Function(BuildContext, T)?` | Optional. Widget builder for showing the selected item in the field. |
| `isSearchable`        | `bool`                              | Whether the dropdown supports searching. Default is `false`.         |
| `searchHint`          | `String?`                           | Hint text for the search bar (if `isSearchable` is true).            |
| `dropdownHeight`      | `double?`                           | Max height of the dropdown menu.                                     |
| `decoration`          | `InputDecoration?`                  | Custom decoration for the dropdown input field.                      |
| `icon`                | `Widget?`                           | Custom icon for the dropdown.                                        |

---

## 📸 Screenshots

| Basic Dropdown                  | Searchable Dropdown                       |
| ------------------------------- | ----------------------------------------- |
| ![Basic](screenshots/basic.png) | ![Searchable](screenshots/searchable.png) |

---

## 🎥 Demo GIF

![Demo](screenshots/demo.gif)

---

## 🙌 Maintained and Powered by

* 📧 **[hanifuddin.dev@gmail.com](mailto:hanifuddin.dev@gmail.com)**

```


