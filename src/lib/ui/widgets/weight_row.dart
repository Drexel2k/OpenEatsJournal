import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/weight_row_viewmodel.dart';

class WeightRow extends StatefulWidget {
  const WeightRow({
    super.key,
    required WeightRowViewModel weightRowViewModel,
    required DateTime date,
    required Future<void> Function({required DateTime date, required double weight}) onWeightEdit,
    required bool deleteEnabled,
    required Future<void> Function({required DateTime date}) onDeletePressed,
    required Color deleteIconColor,
  }) : _weightRowViewModel = weightRowViewModel,
       _date = date,
       _onWeightEdit = onWeightEdit,
       _deleteEnabled = deleteEnabled,
       _onDeletePressed = onDeletePressed,
       _deleteIconColor = deleteIconColor;

  final WeightRowViewModel _weightRowViewModel;
  final DateTime _date;
  final Future<void> Function({required DateTime date, required double weight}) _onWeightEdit;
  final bool _deleteEnabled;
  final Future<void> Function({required DateTime date}) _onDeletePressed;
  final Color _deleteIconColor;

  @override
  State<WeightRow> createState() => _WeightRowState();
}

class _WeightRowState extends State<WeightRow> {
  _WeightRowState() {
    widget._weightRowViewModel.weightChanged = _weightChanged;
  }

  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    _weightController.text = ConvertValidate.getCleanDoubleString(doubleValue: widget._weightRowViewModel.lastValidWeight);

    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: Text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._date), style: textTheme.titleSmall)),
            Expanded(
              flex: 2,
              child: ValueListenableBuilder(
                valueListenable: widget._weightRowViewModel.weight,
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
                          return newValue;
                        } else {
                          return oldValue;
                        }
                      }),
                    ],
                    onTap: () {
                      _weightController.selection = TextSelection(baseOffset: 0, extentOffset: _weightController.text.length);
                    },
                    onChanged: (value) {
                      num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value);
                      widget._weightRowViewModel.weight.value = doubleValue as double?;

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
                icon: Icon(Icons.delete, color: widget._deleteIconColor),
                onPressed: () async {
                  if (widget._deleteEnabled) {
                    await widget._onDeletePressed(date: widget._date);
                  } else {
                    await _showRecalulateKJouleConfirmDialog(context: context);
                  }
                },
                tooltip: AppLocalizations.of(context)!.cant_delete_last_weight_journal_entry,
              ),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: widget._weightRowViewModel.weightValid,
          builder: (_, _, _) {
            if (!widget._weightRowViewModel.weightValid.value) {
              return Text(
                AppLocalizations.of(context)!.input_invalid_value(AppLocalizations.of(context)!.weight, widget._weightRowViewModel.lastValidWeight),
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

  void _weightChanged() async {
    await widget._onWeightEdit(date: widget._date, weight: widget._weightRowViewModel.lastValidWeight);
  }

  Future<void> _showRecalulateKJouleConfirmDialog({required BuildContext context}) async {
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
    _weightController.dispose();

    super.dispose();
  }
}
