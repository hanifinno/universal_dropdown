import 'package:flutter/material.dart';

/// A universal dropdown widget that supports:
/// - Single or multiple selection
/// - Optional checkboxes
/// - Searchable list
/// - Custom item widgets
/// - Custom chips for selected items
///
/// This widget can be displayed inline or inside a bottom sheet.
class UniversalDropdown<T> extends StatefulWidget {
  /// The list of all available items to display.
  final List<T> items;

  /// The list of initially selected items.
  final List<T> selectedItems;

  /// Function that maps an item of type [T] to its display label.
  final String Function(T) itemLabel;

  /// Optional custom widget builder for each item.
  /// If provided, it overrides the default text-based display.
  final Widget Function(T)? customItemWidget;

  /// Enables multi-selection when set to `true`.
  /// Defaults to `false` (single selection).
  final bool isMultiSelect;

  /// Shows a checkbox for each item if `true`.
  /// Defaults to `false`.
  final bool showCheckbox;

  /// Enables a search bar to filter items if `true`.
  /// Defaults to `false`.
  final bool searchable;

  /// Displays the dropdown inside a bottom sheet if `true`.
  /// Defaults to `false`.
  final bool showAsBottomSheet;

  /// Callback that is triggered whenever the selected items change.
  final void Function(List<T>) onSelectionChanged;

  /// Optional custom chip builder for selected items.
  /// If not provided, the default [Chip] widget is used.
  final Chip Function(T)? customChipBuilder;

  /// Creates a [UniversalDropdown] widget.
  const UniversalDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    this.customItemWidget,
    this.isMultiSelect = false,
    this.showCheckbox = false,
    this.searchable = false,
    this.showAsBottomSheet = false,
    required this.onSelectionChanged,
    this.customChipBuilder,
  });

  @override
  State<UniversalDropdown<T>> createState() => _UniversalDropdownState<T>();
}

class _UniversalDropdownState<T> extends State<UniversalDropdown<T>> {
  late List<T> filteredItems;
  late List<T> selectedItems;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    selectedItems = List.from(widget.selectedItems);
  }

  /// Handles tapping an item:
  /// - Toggles selection in multi-select mode
  /// - Replaces selection in single-select mode
  void _onItemTap(T item) {
    setState(() {
      if (widget.isMultiSelect) {
        if (selectedItems.contains(item)) {
          selectedItems.remove(item);
        } else {
          selectedItems.add(item);
        }
      } else {
        selectedItems = [item];
      }
    });
    widget.onSelectionChanged(selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Search bar (only if enabled)
        if (widget.searchable)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  filteredItems = widget.items
                      .where(
                        (item) => widget
                            .itemLabel(item)
                            .toLowerCase()
                            .contains(query.toLowerCase()),
                      )
                      .toList();
                });
              },
            ),
          ),

        /// Chips for selected items
        Wrap(
          spacing: 6,
          children: selectedItems.map((item) {
            return widget.customChipBuilder?.call(item) ??
                Chip(
                  label: Text(widget.itemLabel(item)),
                  onDeleted: () {
                    _onItemTap(item);
                  },
                );
          }).toList(),
        ),

        /// Items list
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final isSelected = selectedItems.contains(item);
              return ListTile(
                leading: widget.showCheckbox
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => _onItemTap(item),
                      )
                    : null,
                title:
                    widget.customItemWidget?.call(item) ??
                    Text(widget.itemLabel(item)),
                onTap: () => _onItemTap(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
