import 'dart:async';
import 'package:flutter/material.dart';

enum DropdownMode { overlay, bottomSheet }

class UniversalDropdown<T> extends StatefulWidget {
  /// The static list of items to display in the dropdown.
  /// Use this when you already have all items in memory.
  final List<T>? items;

  /// Asynchronous function to fetch items for pagination.
  /// Signature: (page, pageSize) → Future<List<T>>
  /// Called when pagination is enabled and more data needs to be loaded.
  final Future<List<T>> Function(int page, int pageSize)? fetchItems;

  /// The list of currently selected items.
  /// For single-select, it usually contains 0 or 1 item.
  /// For multi-select, it can contain multiple items.
  final List<T> selectedItems;

  /// Whether multiple items can be selected.
  /// If false, selecting one item will replace the previous selection.
  final bool multiSelect;

  /// Whether to show a search bar in the dropdown to filter items.
  final bool searchable;

  /// Placeholder text shown in the search bar when `searchable` is true.
  final String searchPlaceholder;

  /// Whether the dropdown should load items in pages (pagination).
  /// Requires `fetchItems` to be provided.
  final bool paginate;

  /// The number of items to fetch per page when using pagination.
  final int pageSize;

  /// Function that returns the display label for a given item.
  /// Example: (user) => user.name
  final String Function(T) itemLabel;

  /// Callback triggered whenever the selection changes.
  /// Receives the updated list of selected items.
  final Function(List<T>) onChanged;

  /// The display mode of the dropdown:
  /// - `DropdownMode.overlay` → shows floating overlay near the field
  /// - `DropdownMode.bottomSheet` → shows a modal bottom sheet
  final DropdownMode mode;

  // ---------------- Styling ----------------

  /// Custom decoration for the dropdown container.
  /// Example: background color, border radius, shadows, etc.
  final BoxDecoration? dropdownDecoration;

  /// Maximum height of the dropdown list container.
  /// Useful to limit large item lists.
  final double dropdownMaxHeight;

  /// Offset adjustment for the dropdown’s position.
  /// Example: Offset(0, 10) to move it 10px lower than default.
  final Offset dropdownOffset;

  /// Alignment of the dropdown relative to its trigger widget.
  final Alignment dropdownAlignment;

  // ------------- Chip Customization -------------

  /// Custom builder for each selected item chip.
  /// Useful for styling selected tags differently.
  /// Parameters:
  ///   - item: The selected item
  ///   - onRemove: Callback to remove this item from selection
  final Widget Function(T item, VoidCallback onRemove)? chipBuilder;

  /// Horizontal space between chips when in multi-select mode.
  final double chipSpacing;

  /// Alignment of the chip wrap container.
  /// Example: WrapAlignment.start, WrapAlignment.center, etc.
  final WrapAlignment chipWrapAlignment;

  const UniversalDropdown({
    super.key,
    this.items,
    required this.itemLabel,
    required this.onChanged,
    this.selectedItems = const [],
    this.multiSelect = false,
    this.searchable = false,
    this.searchPlaceholder = "Search...",
    this.paginate = false,
    this.pageSize = 10,
    this.fetchItems,
    this.mode = DropdownMode.overlay,
    this.dropdownDecoration,
    this.dropdownMaxHeight = 250,
    this.dropdownOffset = const Offset(0, 0),
    this.dropdownAlignment = Alignment.topLeft,
    this.chipBuilder,
    this.chipSpacing = 6,
    this.chipWrapAlignment = WrapAlignment.start,
  });

  @override
  State<UniversalDropdown<T>> createState() => _UniversalDropdownState<T>();
}

class _UniversalDropdownState<T> extends State<UniversalDropdown<T>> {
  late List<T> _displayedItems;
  late List<T> _selectedItems;
  String _searchText = "";
  int _currentPage = 0;
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;
  Completer? _bottomSheetCompleter;
  StateSetter? _bottomSheetSetState;
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();

  List<T>? _cachedFilteredItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
    _displayedItems = List.from(widget.items ?? []);
    if (widget.paginate && widget.fetchItems != null) {
      _loadPage(0);
    }
    // Add listener to update search text on typing immediately:
    _searchController.addListener(() {
      final val = _searchController.text;
      if (val != _searchText) {
        setState(() {
          _searchText = val;
          _cachedFilteredItems = null;
        });
        _refreshDropdown();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    if (widget.fetchItems == null) return;
    setState(() => _isLoading = true);
    final newItems = await widget.fetchItems!(page, widget.pageSize);
    setState(() {
      if (page == 0) {
        _displayedItems = newItems;
      } else {
        _displayedItems.addAll(newItems);
      }
      _isLoading = false;
      _cachedFilteredItems = null;
    });
    _refreshDropdown();
  }

  void _toggleItem(T item) {
    setState(() {
      if (widget.multiSelect) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      } else {
        _selectedItems = [item];
      }
      widget.onChanged(_selectedItems);
    });

    if (!widget.multiSelect) {
      _removeOverlay();
    } else {
      _refreshDropdown();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_bottomSheetCompleter != null && !_bottomSheetCompleter!.isCompleted) {
      _bottomSheetCompleter!.complete();
    }
    _bottomSheetSetState = null;
  }

  void _openDropdown() {
    _searchController.clear();
    setState(() {
      _searchText = "";
      _cachedFilteredItems = null;
    });

    if (widget.mode == DropdownMode.overlay) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _openBottomSheet();
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx + widget.dropdownOffset.dx,
              top: offset.dy + size.height + widget.dropdownOffset.dy,
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(0, size.height),
                child: _buildDropdownContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBottomSheet() {
    _bottomSheetCompleter = Completer();
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        // Wrap with StatefulBuilder
        builder: (BuildContext context, StateSetter setState) {
          _bottomSheetSetState = setState; // Store setState function
          return _buildDropdownContent();
        },
      ),
    ).then((_) {
      _bottomSheetCompleter?.complete();
      _bottomSheetCompleter = null;
      _bottomSheetSetState = null; // Clean up
    });
  }

  void _refreshDropdown() {
    _overlayEntry?.markNeedsBuild();
    if (_bottomSheetCompleter != null && !_bottomSheetCompleter!.isCompleted) {
      _bottomSheetCompleter!.complete();
      _bottomSheetCompleter = null;
    }
    if (widget.mode == DropdownMode.bottomSheet &&
        _bottomSheetSetState != null) {
      _bottomSheetSetState!(() {});
    }
  }

  List<T> _filteredItems() {
    if (_cachedFilteredItems != null) return _cachedFilteredItems!;
    if (_searchText.isEmpty) {
      _cachedFilteredItems = _displayedItems;
      return _cachedFilteredItems!;
    }
    final lower = _searchText.toLowerCase();
    _cachedFilteredItems = _displayedItems
        .where((item) => widget.itemLabel(item).toLowerCase().contains(lower))
        .toList();
    return _cachedFilteredItems!;
  }

  Widget _buildDropdownContent() {
    final filteredItems = _filteredItems();
    return Material(
      elevation: 4,
      child: Container(
        decoration:
            widget.dropdownDecoration ??
            BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
        constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight),
        child: Column(
          children: [
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.searchPlaceholder,
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= filteredItems.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = filteredItems[index];
                  final isSelected = _selectedItems.contains(item);
                  return ListTile(
                    title: Text(widget.itemLabel(item)),
                    leading: widget.multiSelect
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleItem(item),
                          )
                        : null,
                    onTap: () => _toggleItem(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChips() {
    if (!widget.multiSelect || _selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: widget.chipSpacing,
      alignment: widget.chipWrapAlignment,
      children: _selectedItems.map((item) {
        return widget.chipBuilder != null
            ? widget.chipBuilder!(item, () => _toggleItem(item))
            : Chip(
                label: Text(widget.itemLabel(item)),
                onDeleted: () => _toggleItem(item),
              );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _openDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _selectedItems.isEmpty
                        ? const Text("Select...")
                        : Text(
                            widget.multiSelect
                                ? "${_selectedItems.length} selected"
                                : widget.itemLabel(_selectedItems.first),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          _buildChips(),
        ],
      ),
    );
  }
}
