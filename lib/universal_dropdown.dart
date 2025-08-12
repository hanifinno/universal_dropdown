import 'dart:async';

import 'package:flutter/material.dart';

typedef ItemBuilder<T> =
    Widget Function(BuildContext context, T item, bool isSelected);
typedef ItemFetcher<T> = Future<List<T>> Function(int page, int pageSize);

class UniversalDropdown<T> extends StatefulWidget {
  /// Optional: Full list of items (if pagination is not needed)
  final List<T>? items;

  /// Optional: Function to fetch items per page (for pagination)
  /// Parameters: page index (starting from 0), page size
  /// If provided, pagination mode is enabled and [items] must be null.
  final ItemFetcher<T>? itemFetcher;

  /// How many items per page to fetch
  final int pageSize;

  /// Function to get string label for an item
  final String Function(T item) itemLabel;

  /// Is multi-select enabled
  final bool isMultiSelect;

  /// Initial selected items
  final List<T> initialSelectedItems;

  /// Optional custom widget builder for each item
  final ItemBuilder<T>? itemBuilder;

  /// Optional chip builder for selected items
  final Widget Function(T item, void Function() onDeleted)? chipBuilder;

  /// Optional: show dropdown as bottom sheet instead of overlay
  final bool showAsBottomSheet;

  /// Optional width of dropdown list
  final double dropdownWidth;

  /// Hint text to show when nothing is selected
  final String hintText;

  /// Callback on selection changed
  final void Function(List<T> selectedItems) onSelectionChanged;

  const UniversalDropdown({
    super.key,
    this.items,
    this.itemFetcher,
    this.pageSize = 50,
    required this.itemLabel,
    required this.onSelectionChanged,
    this.isMultiSelect = false,
    this.initialSelectedItems = const [],
    this.itemBuilder,
    this.chipBuilder,
    this.showAsBottomSheet = false,
    this.dropdownWidth = 300,
    this.hintText = 'Select item',
  }) : assert(
         (items != null && itemFetcher == null) ||
             (items == null && itemFetcher != null),
         'Either provide items for non-paginated mode or itemFetcher for paginated mode, not both.',
       );

  @override
  State<UniversalDropdown<T>> createState() => _UniversalDropdownState<T>();
}

class _UniversalDropdownState<T> extends State<UniversalDropdown<T>> {
  final LayerLink _layerLink = LayerLink();

  List<T> _loadedItems = [];
  List<T> _selectedItems = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  final ScrollController _scrollController = ScrollController();

  bool get _isPaginated => widget.itemFetcher != null;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
    if (_isPaginated) {
      _loadPage(0);
      _scrollController.addListener(_onScroll);
    } else {
      // Non paginated mode: load full list from items
      _loadedItems = widget.items ?? [];
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    if (!_isPaginated || _isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final newItems = await widget.itemFetcher!(page, widget.pageSize);
      setState(() {
        if (page == 0)
          _loadedItems = newItems;
        else
          _loadedItems.addAll(newItems);
        _currentPage = page;
        _hasMore = newItems.length == widget.pageSize;
      });
    } catch (e) {
      setState(() {
        _hasMore = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= 100) {
      if (!_isLoading && _hasMore) {
        _loadPage(_currentPage + 1);
      }
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      if (widget.showAsBottomSheet) {
        _openBottomSheet();
      } else {
        _openOverlay();
      }
    }
  }

  void _openOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isDropdownOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isDropdownOpen = false);
  }

  void _openBottomSheet() async {
    final result = await showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DropdownContent(
        items: _loadedItems,
        selectedItems: _selectedItems,
        itemLabel: widget.itemLabel,
        isMultiSelect: widget.isMultiSelect,
        itemBuilder: widget.itemBuilder,
        onItemTap: _onItemTap,
        scrollController: _scrollController,
        isLoading: _isLoading,
        hasMore: _hasMore,
        loadMore: () => _loadPage(_currentPage + 1),
        chipBuilder: widget.chipBuilder,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedItems = result;
        widget.onSelectionChanged(_selectedItems);
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _closeDropdown(),
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: widget.dropdownWidth,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 5),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: _DropdownContent(
                      items: _loadedItems,
                      selectedItems: _selectedItems,
                      itemLabel: widget.itemLabel,
                      isMultiSelect: widget.isMultiSelect,
                      itemBuilder: widget.itemBuilder,
                      onItemTap: _onItemTap,
                      scrollController: _scrollController,
                      isLoading: _isLoading,
                      hasMore: _hasMore,
                      loadMore: () => _loadPage(_currentPage + 1),
                      chipBuilder: widget.chipBuilder,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTap(T item) {
    setState(() {
      if (widget.isMultiSelect) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      } else {
        _selectedItems = [item];
        _closeDropdown();
      }
      widget.onSelectionChanged(_selectedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: widget.dropdownWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: _selectedItems.isEmpty
                    ? Text(
                        widget.hintText,
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: _selectedItems.map((item) {
                          return widget.chipBuilder?.call(item, () {
                                _onItemTap(item);
                              }) ??
                              Chip(
                                label: Text(widget.itemLabel(item)),
                                onDeleted: () => _onItemTap(item),
                              );
                        }).toList(),
                      ),
              ),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownContent<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final bool isMultiSelect;
  final ItemBuilder<T>? itemBuilder;
  final void Function(T item) onItemTap;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasMore;
  final Future<void> Function() loadMore;
  final Widget Function(T item, void Function() onDeleted)? chipBuilder;

  const _DropdownContent({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    required this.isMultiSelect,
    required this.onItemTap,
    required this.scrollController,
    required this.isLoading,
    required this.hasMore,
    required this.loadMore,
    this.itemBuilder,
    this.chipBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading && items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No items found')),
          )
        else
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: items.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  // Load more indicator
                  loadMore();
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final item = items[index];
                final isSelected = selectedItems.contains(item);
                return ListTile(
                  leading: isMultiSelect
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (_) => onItemTap(item),
                        )
                      : null,
                  title: itemBuilder != null
                      ? itemBuilder!(context, item, isSelected)
                      : Text(itemLabel(item)),
                  onTap: () => onItemTap(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
