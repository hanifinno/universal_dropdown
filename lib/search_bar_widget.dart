import 'package:flutter/material.dart';

class SearchBarWidget<T> extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback clear;
  final ValueChanged<String> onChanged;
  final Widget Function(
    BuildContext,
    TextEditingController,
    VoidCallback,
    ValueChanged<String>,
  )?
  searchBarBuilder;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.clear,
    required this.onChanged,
    this.searchBarBuilder,
  });

  @override
  State<SearchBarWidget<T>> createState() => _SearchBarWidgetState<T>();
}

class _SearchBarWidgetState<T> extends State<SearchBarWidget<T>> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      print('SearchBarWidget focus changed: ${widget.focusNode.hasFocus}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.searchBarBuilder?.call(
          context,
          widget.controller,
          widget.clear,
          widget.onChanged,
        ) ??
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              hintText: 'Search…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: widget.clear,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
            onChanged: widget.onChanged,
            onSubmitted: (value) {
              print('Enter pressed with query: $value');
              widget.onChanged(value);
            },
          ),
        );
  }
}
