import "package:flutter/material.dart";
import "package:flutter/services.dart";

class OpenEatsJournalTextField extends StatelessWidget {
  const OpenEatsJournalTextField({
    super.key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? hintText,

    Widget? decorationSuffixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    bool? selectAllOnFocus,
    GestureTapCallback? onTap,
  }) : _controller = controller,
       _focusNode = focusNode,
       _hintText = hintText,
       _decorationSuffixIcon = decorationSuffixIcon,
       _keyboardType = keyboardType,
       _readOnly = readOnly,
       _onChanged = onChanged,
       _onSubmitted = onSubmitted,
       _inputFormatters = inputFormatters,
       _enabled = enabled,
       _selectAllOnFocus = selectAllOnFocus,
       _onTap = onTap;

  final TextEditingController? _controller;
  final FocusNode? _focusNode;
  final String? _hintText;
  final Widget? _decorationSuffixIcon;
  final TextInputType? _keyboardType;
  final bool _readOnly;
  final ValueChanged<String>? _onChanged;
  final ValueChanged<String>? _onSubmitted;
  final List<TextInputFormatter>? _inputFormatters;
  final bool? _enabled;
  final bool? _selectAllOnFocus;
  final GestureTapCallback? _onTap;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: _hintText,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        isDense: true,
        suffixIcon: _decorationSuffixIcon,
        suffixIconConstraints: _decorationSuffixIcon != null ? BoxConstraints(maxHeight: 18) : null,
        contentPadding: EdgeInsets.all(7),
      ),
      keyboardType: _keyboardType,
      readOnly: _readOnly,
      onChanged: _onChanged,
      onSubmitted: _onSubmitted,
      inputFormatters: _inputFormatters,
      enabled: _enabled,
      selectAllOnFocus: _selectAllOnFocus,
      onTap: _onTap,
    );
  }
}
