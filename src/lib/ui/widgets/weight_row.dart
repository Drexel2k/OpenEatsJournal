import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/weight_row_viewmodel.dart";

class WeightRow extends StatefulWidget {
  const WeightRow({
    super.key,
    required WeightRowViewModel weightRowViewModel,
    required bool deleteEnabled,
    required Future<void> Function({required DateTime date}) onDeletePressed,
    required Color deleteIconColor,
  }) : _weightRowViewModel = weightRowViewModel,
       _deleteEnabled = deleteEnabled,
       _onDeletePressed = onDeletePressed,
       _deleteIconColor = deleteIconColor;

  final WeightRowViewModel _weightRowViewModel;
  final bool _deleteEnabled;
  final Future<void> Function({required DateTime date}) _onDeletePressed;
  final Color _deleteIconColor;

  @override
  State<WeightRow> createState() => _WeightRowState();
}

class _WeightRowState extends State<WeightRow> {
  late WeightRowViewModel _weightRowViewModel;
  late bool _deleteEnabled;
  late Future<void> Function({required DateTime date}) _onDeletePressed;
  late Color _deleteIconColor;

  final TextEditingController _weightController = TextEditingController();

  final FocusNode _weightFocusNode = FocusNode();

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _weightRowViewModel = widget._weightRowViewModel;
    _deleteEnabled = widget._deleteEnabled;
    _onDeletePressed = widget._onDeletePressed;
    _deleteIconColor = widget._deleteIconColor;

    _weightController.text = ConvertValidate.getCleanDoubleString(doubleValue: _weightRowViewModel.lastValidWeightDisplay);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: Text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(_weightRowViewModel.date), style: textTheme.titleSmall)),
            Expanded(
              flex: 2,
              child: ValueListenableBuilder(
                valueListenable: _weightRowViewModel.weight,
                builder: (_, _, _) {
                  return OpenEatsJournalTextField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final String text = newValue.text.trim();
                        if (text.isEmpty) {
                          return newValue;
                        }

                        num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(text);
                        if (doubleValue != null) {
                          if (ConvertValidate.decimalHasMoreThan1Fraction(decimalstring: text)) {
                            return oldValue;
                          }

                          return newValue;
                        } else {
                          return oldValue;
                        }
                      }),
                    ],
                    focusNode: _weightFocusNode,
                    onTap: () {
                      //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                      //effect.
                      if (!_weightFocusNode.hasFocus) {
                        _weightController.selection = TextSelection(baseOffset: 0, extentOffset: _weightController.text.length);
                      }
                    },
                    onChanged: (value) {
                      num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value);
                      _weightRowViewModel.weight.value = doubleValue as double?;

                      if (doubleValue != null) {
                        _weightController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                      }
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.delete, color: _deleteIconColor),
                onPressed: () async {
                  if (_deleteEnabled) {
                    await _onDeletePressed(date: _weightRowViewModel.date);
                  } else {
                    await _showCantDeleteConfirmDialog(context: context);
                  }
                },
                tooltip: AppLocalizations.of(context)!.cant_delete_last_weight_journal_entry,
              ),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: _weightRowViewModel.weightValid,
          builder: (_, _, _) {
            if (!_weightRowViewModel.weightValid.value) {
              return Text(
                AppLocalizations.of(context)!.input_invalid_value(AppLocalizations.of(context)!.weight, _weightRowViewModel.lastValidWeightDisplay),
                style: textTheme.labelSmall!.copyWith(color: Colors.red),
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ],
    );
  }

  Future<void> _showCantDeleteConfirmDialog({required BuildContext context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextBuilder) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete_weight_journal_entry),
          content: Text(AppLocalizations.of(context)!.cant_delete_last_weight_journal_entry),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                Navigator.pop(contextBuilder, true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    widget._weightRowViewModel.dispose();
    if (widget._weightRowViewModel != _weightRowViewModel) {
      _weightRowViewModel.dispose();
    }

    _weightController.dispose();

    _weightFocusNode.dispose();

    super.dispose();
  }
}
