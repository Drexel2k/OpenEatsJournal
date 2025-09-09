import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
    super.key,
    GestureTapCallback? onTap,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
  }) : _onTap = onTap,
       _controller = controller,
       _keyboardType = keyboardType,
       _inputFormatters = inputFormatters,
       _onChanged = onChanged,
       _readOnly = readOnly;

  final GestureTapCallback? _onTap;
  final TextEditingController? _controller;
  final TextInputType? _keyboardType;
  final List<TextInputFormatter>? _inputFormatters;
  final ValueChanged<String>? _onChanged;
  final bool _readOnly;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 140.0,
      child: OpenEatsJournalTextField(
        readOnly: _readOnly,
        controller: _controller,
        onTap: _onTap,
        keyboardType: _keyboardType,
        inputFormatters: _inputFormatters,
        onChanged: _onChanged,
      ),
    );
  }
}
