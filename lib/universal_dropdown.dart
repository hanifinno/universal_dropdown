import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universal_dropdown/search_bar_widget.dart';

/// Ultra‑customizable dropdown supporting:
/// - Overlay / BottomSheet modes
/// - Single / Multi select
/// - Full builder-based APIs for items, selected display, chips, checkbox, search bar, loader, empty state
/// - Async pagination + server-side search
/// - Layout controls: offsets, alignment, paddings, separators
///
/// Drop this file into your project and import it.

enum DropdownMode { overlay, bottomSheet }

enum CheckboxPosition { none, leading, trailing }

enum ChipPlacement { none, aboveField, belowField }

class UniversalDropdown<T> extends StatefulWidget {
  /// Static items (optional if using [fetchItems]).
  final List<T>? items;

  /// Pre-selected items (mutated internally via copies; original list is not modified).
  final List<T>? selectedItems;

  /// Callback when selection changes.
  final ValueChanged<List<T>> onChanged;

  /// Async data source for pagination / server search.
  /// Signature: (page, pageSize, searchQuery) => Future<List<T>>
  final Future<List<T>> Function(int page, int pageSize, String query)?
  fetchItems;

  /// ===== Behavior =====
  final bool multiSelect;
  final bool closeOnSelectWhenSingle; // if single-select, close after choosing
  final bool searchable; // enables search bar rendering
  final bool paginate; // enable infinite scroll
  final int pageSize;

  /// ===== Visuals: Field & Dropdown =====
  final String
  placeholder; // shown by default selected display builder when empty
  final DropdownMode mode;
  final Alignment dropdownAlignment; // relative alignment for overlay anchor
  final Offset dropdownOffset; // pixel offset for overlay positioning
  final BoxDecoration? dropdownDecoration;
  final double dropdownMaxHeight;
  final EdgeInsetsGeometry dropdownPadding;

  /// ===== Builders: give you total control =====
  /// Item row in the list (you decide every pixel).
  final Widget Function(
    BuildContext context,
    T item,
    bool isSelected,
    int index,
  )
  itemBuilder;

  /// How the closed field looks. Tap should open the dropdown; we also
  /// pass a helper [open] to do that and [clear] to clear selection.
  final Widget Function(
    BuildContext context,
    List<T> selected,
    VoidCallback open,
    VoidCallback clear,
  )?
  selectedDisplayBuilder;

  /// Build the checkbox/toggle indicator used for each item.
  /// If null, a Material Checkbox/Radio is used depending on [multiSelect].
  final Widget Function(BuildContext context, bool isSelected)? checkboxBuilder;

  /// Where to place the checkbox relative to the item row.
  final CheckboxPosition checkboxPosition;

  /// Chips for multi-select summary (when not providing your own selected display).
  final Widget Function(BuildContext context, T item, VoidCallback onRemove)?
  chipBuilder;

  /// Where to render the chips (if using default selected display).
  final ChipPlacement chipPlacement;

  /// Spacing + alignment for default chips area.
  final double chipSpacing;
  final WrapAlignment chipWrapAlignment;

  /// Search bar (fully custom). Given controller + clear helper + onChanged.
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    VoidCallback clear,
    ValueChanged<String> onChanged,
  )?
  searchBarBuilder;

  /// Loader for pagination.
  final Widget Function(BuildContext context)? loaderBuilder;

  /// Empty-state when there are no items to show.
  final Widget Function(BuildContext context)? emptyStateBuilder;

  /// Optional header/footer widgets inside dropdown panel.
  final Widget Function(BuildContext context)? headerBuilder;
  final Widget Function(BuildContext context)? footerBuilder;

  /// Optional separator between items.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// List padding inside dropdown.
  final EdgeInsetsGeometry listPadding;

  /// Animation tuning (overlay open/close).
  final Duration animationDuration;
  final Curve animationCurve;

  UniversalDropdown({
    super.key,
    // data
    this.items,
    this.selectedItems,
    required this.onChanged,
    this.fetchItems,
    // behavior
    this.multiSelect = false,
    this.closeOnSelectWhenSingle = true,
    this.searchable = false,
    this.paginate = false,
    this.pageSize = 20,
    // visuals
    this.placeholder = 'Select…',
    this.mode = DropdownMode.overlay,
    this.dropdownAlignment = Alignment.topLeft,
    this.dropdownOffset = Offset.zero,
    this.dropdownDecoration,
    this.dropdownMaxHeight = 320,
    this.dropdownPadding = const EdgeInsets.symmetric(
      vertical: 8,
      horizontal: 8,
    ),
    // builders
    required this.itemBuilder,
    this.selectedDisplayBuilder,
    this.checkboxBuilder,
    this.checkboxPosition = CheckboxPosition.leading,
    this.chipBuilder,
    this.chipPlacement = ChipPlacement.belowField,
    this.chipSpacing = 8,
    this.chipWrapAlignment = WrapAlignment.start,
    this.searchBarBuilder,
    this.loaderBuilder,
    this.emptyStateBuilder,
    this.headerBuilder,
    this.footerBuilder,
    this.separatorBuilder,
    this.listPadding = const EdgeInsets.symmetric(vertical: 4),
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOutCubic,
  }) : assert(
         items != null || fetchItems != null,
         'Provide either static items or a fetchItems callback.',
       );

  @override
  State<UniversalDropdown<T>> createState() => _UniversalDropdownState<T>();
}

class _UniversalDropdownState<T> extends State<UniversalDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late List<T> _selected;
  late List<T> _displayed;
  // final GlobalKey _overlayKey = GlobalKey();
  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String _query = '';
  FocusScopeNode? _overlayFocusNode;
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _animCtrl;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.selectedItems ?? []);
    _displayed = List<T>.from(widget.items ?? const []);
    _overlayFocusNode = FocusScopeNode();

    _scrollCtrl.addListener(_handleScroll);
    _animCtrl = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _opacity = CurvedAnimation(
      parent: _animCtrl,
      curve: Interval(0.0, 1.0, curve: widget.animationCurve),
    );
    _scale = Tween<double>(begin: 0.98, end: 1.0).animate(_opacity);

    if (widget.paginate && widget.fetchItems != null) {
      _resetAndLoad();
    }
  }

  @override
  void didUpdateWidget(covariant UniversalDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItems != widget.selectedItems) {
      _selected = List<T>.from(widget.selectedItems ?? []);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayFocusNode?.dispose();
    _debounceTimer?.cancel();
    _searchFocusNode.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.paginate || _isLoading || !_hasMore) return;
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 64) {
      _loadMore();
    }
  }

  Future<void> _resetAndLoad() async {
    print('Resetting and loading items for query: $_query');
    setState(() {
      _page = 1;
      _hasMore = true;
      _displayed.clear();
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (widget.fetchItems == null) return;
    setState(() => _isLoading = true);
    final newItems = await widget.fetchItems!(_page, widget.pageSize, _query);
    setState(() {
      _displayed.addAll(newItems);
      _isLoading = false;
      if (newItems.length < widget.pageSize) _hasMore = false;
      _page += 1;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _open() {
    if (widget.mode == DropdownMode.bottomSheet) {
      _openBottomSheet();
    } else {
      _openOverlay();
    }
  }

  void _close() {
    if (widget.mode == DropdownMode.bottomSheet) {
      Navigator.of(context).maybePop();
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _openOverlay() {
    if (_overlayEntry != null) return;
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: [
            Positioned(
              left:
                  renderBox.localToGlobal(Offset.zero).dx +
                  widget.dropdownOffset.dx,
              top:
                  renderBox.localToGlobal(Offset.zero).dy +
                  size.height +
                  widget.dropdownOffset.dy,
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(0, size.height),
                child: Material(
                  color: Colors.transparent,
                  child: FocusScope(
                    node: _overlayFocusNode,
                    child: FadeTransition(
                      opacity: _opacity,
                      child: ScaleTransition(
                        scale: _scale,
                        alignment: Alignment.topCenter,
                        child: _panel(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animCtrl.forward(from: 0);
    // Add delay to ensure overlay is fully built before focusing
    Future.delayed(const Duration(milliseconds: 10), () {
      if (_overlayEntry != null) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateForBottomSheet) {
            return _panel(setStateForBottomSheet: setStateForBottomSheet);
          },
        );
      },
    ).then((_) {
      _searchFocusNode.unfocus(); // Unfocus when bottom sheet closes
    });
  }

  Widget _buildSearchBar({StateSetter? setStateForBottomSheet}) {
    void clear() {
      print('Clearing search query');
      _searchCtrl.clear();
      _query = '';
      if (widget.fetchItems != null) {
        _resetAndLoad().then((_) {
          print('Reset and load complete for async items');
          if (setStateForBottomSheet != null) {
            setStateForBottomSheet(() {});
          } else {
            setState(() {});
            _overlayEntry?.markNeedsBuild();
          }
          // Schedule focus request after rebuild
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_searchFocusNode.hasFocus) return;
            _searchFocusNode.requestFocus();
            print('Focus requested after clear');
          });
        });
      } else {
        print('Updating displayed items for static list');
        setState(() {
          _displayed = List<T>.from(widget.items ?? const []);
        });
        if (setStateForBottomSheet != null) {
          setStateForBottomSheet(() {});
        }
        _overlayEntry?.markNeedsBuild();
        // Schedule focus request after rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_searchFocusNode.hasFocus) return;
          _searchFocusNode.requestFocus();
          print('Focus requested after clear (static)');
        });
      }
    }

    /// Refreshes UI depending on mode (overlay/bottomSheet).
    void refreshUI() {
      if (setStateForBottomSheet != null) {
        setStateForBottomSheet(() {});
      } else {
        setState(() {});
        _overlayEntry?.markNeedsBuild();
      }
      // Keep focus only if lost
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_searchFocusNode.hasFocus) {
          _searchFocusNode.requestFocus();
          print('Focus restored to search field');
        }
      });
    }

    void performSearch(String query) {
      print('Performing search with query: $query');
      _query = query;

      if (widget.fetchItems != null) {
        // Async search
        _resetAndLoad().then((_) {
          print('Async search complete, displayed: ${_displayed.length} items');
          refreshUI();
        });
      } else {
        // Static filtering
        final all = widget.items ?? const [];
        final filtered = all
            .where(
              (e) => e.toString().toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();
        print('Filtered ${filtered.length} items for static list');
        _displayed = filtered;
        refreshUI();
      }
    }

    void handleSearch(String value) {
      print('Handling search input: $value');
      if (widget.fetchItems != null) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          performSearch(value);
        });
      } else {
        performSearch(value);
      }
    }

    // Wrap SearchBarWidget in a FocusScope to ensure focus retention
    return SearchBarWidget<T>(
      controller: _searchCtrl,
      focusNode: _searchFocusNode,
      clear: clear,
      onChanged: handleSearch,
      searchBarBuilder: widget.searchBarBuilder,
    );
  }

  Widget _panel({StateSetter? setStateForBottomSheet}) {
    final decoration =
        widget.dropdownDecoration ??
        BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Theme.of(context).dividerColor),
        );

    print('Building panel with ${_displayed.length} items');

    return Material(
      color: Colors.transparent,
      child: Container(
        // key: ValueKey(_displayed.length),
        decoration: decoration,
        constraints: BoxConstraints(maxHeight: widget.dropdownMaxHeight),
        padding: widget.dropdownPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.headerBuilder != null) widget.headerBuilder!(context),
            if (widget.searchable)
              _buildSearchBar(setStateForBottomSheet: setStateForBottomSheet),
            Expanded(
              child: _buildList(setStateForBottomSheet: setStateForBottomSheet),
            ),
            if (widget.footerBuilder != null) widget.footerBuilder!(context),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child:
                    widget.loaderBuilder?.call(context) ??
                    const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({StateSetter? setStateForBottomSheet}) {
    print('Building list with ${_displayed.length} items: $_displayed');

    if (_displayed.isEmpty && !_isLoading) {
      return widget.emptyStateBuilder?.call(context) ??
          const Center(child: Text('No items'));
    }

    return ListView.separated(
      // key: ValueKey(_displayed.hashCode),
      controller: _scrollCtrl,
      padding: widget.listPadding,
      itemCount: _displayed.length,
      separatorBuilder: (c, i) =>
          widget.separatorBuilder?.call(c, i) ?? const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final item = _displayed[index];
        final isSelected = _selected.contains(item);

        final row = InkWell(
          onTap: () {
            if (setStateForBottomSheet != null) {
              setStateForBottomSheet(() {
                _toggle(item, isSelected);
              });
            } else {
              _toggle(item, isSelected);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.checkboxPosition == CheckboxPosition.leading)
                _buildCheckbox(isSelected),
              Expanded(
                child: widget.itemBuilder(context, item, isSelected, index),
              ),
              if (widget.checkboxPosition == CheckboxPosition.trailing)
                _buildCheckbox(isSelected),
            ],
          ),
        );

        return row;
      },
    );
  }

  Widget _buildCheckbox(bool isSelected) {
    if (widget.checkboxBuilder != null) {
      return widget.checkboxBuilder!(context, isSelected);
    }
    if (!widget.multiSelect) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
      );
    }
    return Checkbox(value: isSelected, onChanged: (_) {});
  }

  void _toggle(T item, bool isSelected) {
    setState(() {
      if (widget.multiSelect) {
        if (isSelected) {
          _selected.remove(item);
        } else {
          _selected.add(item);
        }
      } else {
        _selected
          ..clear()
          ..add(item);
        if (widget.closeOnSelectWhenSingle) _close();
      }
    });
    widget.onChanged(List<T>.from(_selected));
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _clearSelection() {
    setState(() => _selected.clear());
    widget.onChanged(List<T>.from(_selected));
  }

  Widget _defaultSelectedField() {
    final hasSelection = _selected.isNotEmpty;

    final chips =
        (widget.multiSelect &&
            hasSelection &&
            widget.chipPlacement != ChipPlacement.none)
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: widget.chipSpacing,
              alignment: widget.chipWrapAlignment,
              children: _selected.map((e) {
                return widget.chipBuilder?.call(context, e, () {
                      setState(() => _selected.remove(e));
                      widget.onChanged(List<T>.from(_selected));
                    }) ??
                    Chip(
                      label: Text(e.toString()),
                      onDeleted: () {
                        setState(() => _selected.remove(e));
                        widget.onChanged(List<T>.from(_selected));
                      },
                    );
              }).toList(),
            ),
          )
        : const SizedBox.shrink();

    final field = GestureDetector(
      onTap: _open,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: hasSelection
                  ? Text(
                      widget.multiSelect
                          ? '${_selected.length} selected'
                          : _selected.first.toString(),
                    )
                  : Text(
                      widget.placeholder,
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
            ),
            Icon(Icons.arrow_drop_down, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );

    switch (widget.chipPlacement) {
      case ChipPlacement.none:
        return field;
      case ChipPlacement.aboveField:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [chips, field],
        );
      case ChipPlacement.belowField:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [field, chips],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedField =
        widget.selectedDisplayBuilder?.call(
          context,
          List<T>.from(_selected),
          _open,
          _clearSelection,
        ) ??
        _defaultSelectedField();

    return CompositedTransformTarget(link: _layerLink, child: selectedField);
  }
}
