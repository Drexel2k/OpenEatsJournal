import "package:flutter/material.dart";
import "package:flutter/services.dart";

class OejTextField extends StatelessWidget {
  const OejTextField({
    super.key,
    String? hintText,
    GestureTapCallback? onTap,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) : _hintText = hintText,
       _onTap = onTap,
       _controller = controller,
       _keyboardType = keyboardType,
       _inputFormatters = inputFormatters,
       _onChanged = onChanged,
       _readOnly = readOnly;

  final String? _hintText;
  final GestureTapCallback? _onTap;
  final TextEditingController? _controller;
  final TextInputType? _keyboardType;
  final List<TextInputFormatter>? _inputFormatters;
  final ValueChanged<String>? _onChanged;
  final bool _readOnly;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );

    return TextField(
      decoration: InputDecoration(
        hintText: _hintText,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        isDense: true,
        contentPadding: EdgeInsets.all(7),
      ),
      readOnly: _readOnly,
      controller: _controller,
      onTap: _onTap,
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      onChanged: _onChanged,
    );
  }
}
