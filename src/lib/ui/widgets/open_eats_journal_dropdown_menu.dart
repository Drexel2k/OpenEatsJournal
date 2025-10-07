import "package:flutter/material.dart";

class OpenEatsJournalDropdownMenu<T> extends StatelessWidget {
  const OpenEatsJournalDropdownMenu({
    super.key,
    ValueChanged<T?>? onSelected,
    required List<DropdownMenuEntry<T>> dropdownMenuEntries,
    T? initialSelection,
    bool? enabled,
  }) : _onSelected = onSelected,
       _dropdownMenuEntries = dropdownMenuEntries,
       _initialSelection = initialSelection,
       _enabled = enabled;

  final ValueChanged<T?>? _onSelected;
  final List<DropdownMenuEntry<T>> _dropdownMenuEntries;
  final T? _initialSelection;
  final bool? _enabled;

  @override
  Widget build(BuildContext context) {
    final InputDecorationThemeData inputDecorationTheme = Theme.of(context).inputDecorationTheme;

    if (_enabled == null) {
      return DropdownMenu<T>(
        onSelected: _onSelected,
        dropdownMenuEntries: _dropdownMenuEntries,
        inputDecorationTheme: inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints.tight(const Size.fromHeight(40)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
        expandedInsets: EdgeInsets.zero,
        initialSelection: _initialSelection,
      );
    } else {
      return DropdownMenu<T>(
        onSelected: _onSelected,
        dropdownMenuEntries: _dropdownMenuEntries,
        inputDecorationTheme: inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: BoxConstraints.tight(const Size.fromHeight(40)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32)),
        ),
        expandedInsets: EdgeInsets.zero,
        initialSelection: _initialSelection,
        enabled: _enabled,
      );
    }
  }
}
