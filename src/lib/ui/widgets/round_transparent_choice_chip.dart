import "package:flutter/material.dart";

class RoundTransparentChoiceChip extends StatelessWidget {
  const RoundTransparentChoiceChip({
    super.key,
    required bool selected,
    ValueChanged<bool>? onSelected,
    required Widget label,
  }) : _selected = selected,
       _onSelected = onSelected,
       _label = label;

  final bool _selected;
  final ValueChanged<bool>? _onSelected;
  final Widget _label;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        selected: _selected,
        onSelected: _onSelected,
        shape: CircleBorder(),
        label: _label,
        showCheckmark: false,
        selectedColor: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
