import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/utils/custom_icons.dart';
import 'package:opennutritracker/generated/l10n.dart';

class MealSearchBar extends StatefulWidget {
  final ValueNotifier<String> searchStringListener;
  final Function(String) onSearchSubmit;
  final Function() onBarcodePressed;

  const MealSearchBar({
    super.key,
    required this.searchStringListener,
    required this.onSearchSubmit,
    required this.onBarcodePressed,
  });

  @override
  State<MealSearchBar> createState() => _MealSearchBarState();
}

class _MealSearchBarState extends State<MealSearchBar> {
  final _searchTextController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchTextController.dispose();
    super.dispose();
  }

  void _onTextChanged(String input) {
    widget.searchStringListener.value = input;

    // Debounce: fire search 500ms after user stops typing (min 2 chars)
    _debounce?.cancel();
    if (input.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        widget.onSearchSubmit(input);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: TextField(
            controller: _searchTextController,
            textInputAction: TextInputAction.search,
            onChanged: _onTextChanged,
            onSubmitted: (input) {
              _debounce?.cancel(); // cancel pending debounce, fire immediately
              widget.onSearchSubmit(input);
            },
            decoration: InputDecoration(
              hintText: S.of(context).searchLabel,
              prefixIcon: const Icon(Icons.search_outlined),
              suffixIcon: IconButton(
                icon: const Icon(CustomIcons.barcode_scan),
                onPressed: widget.onBarcodePressed,
              ),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        IconButton(
          onPressed: () {
            _debounce?.cancel();
            FocusManager.instance.primaryFocus?.unfocus();
            widget.onSearchSubmit(_searchTextController.text);
          },
          icon: const Icon(Icons.search_outlined),
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
