import 'package:flutter/material.dart';

class UniversalDropdown<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final Widget Function(T)? customItemWidget;
  final bool isMultiSelect;
  final bool showCheckbox;
  final bool searchable;
  final bool showAsBottomSheet;
  final void Function(List<T>) onSelectionChanged;
  final Chip Function(T)? customChipBuilder;

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
