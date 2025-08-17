import "package:flutter/material.dart";

class TransparentChoiceChip extends StatelessWidget {
  const TransparentChoiceChip({
    super.key,
    required String label,
    IconData? icon,
    bool selected = false,
    ValueChanged<bool>? onSelected
    }
  ) : 
  _icon = icon,
  _label = label,
  _selected = selected,
  _onSelected = onSelected;

  final IconData? _icon;
  final String _label;
  final bool _selected;
  final ValueChanged<bool>? _onSelected;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        avatar: _icon != null ? Icon(_icon) : null,
        label: Text(_label),
        showCheckmark: false,
        selected: _selected,
        onSelected: _onSelected,
        selectedColor: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
