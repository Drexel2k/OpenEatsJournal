import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/weight_row_viewmodel.dart";
import "package:provider/provider.dart";

class WeightRow extends StatefulWidget {
  const WeightRow({
    super.key,
    required bool deleteEnabled,
    required Future<void> Function({required DateTime date}) onDeletePressed,
    required Color deleteIconColor,
  }) : _deleteEnabled = deleteEnabled,
       _onDeletePressed = onDeletePressed,
       _deleteIconColor = deleteIconColor;

  final bool _deleteEnabled;
  final Future<void> Function({required DateTime date}) _onDeletePressed;
  final Color _deleteIconColor;

  @override
  State<WeightRow> createState() => _WeightRowState();
}

class _WeightRowState extends State<WeightRow> {
  final TextEditingController _weightController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WeightRowViewModel weightRowViewModel = Provider.of<WeightRowViewModel>(context, listen: false);
    _weightController.text = ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: weightRowViewModel.lastValidWeight);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<WeightRowViewModel>(
      builder: (context, weightRowViewModel, _) => Column(
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: Text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(weightRowViewModel.date), style: textTheme.titleSmall)),
              Expanded(
                flex: 2,
                child: ValueListenableBuilder(
                  valueListenable: weightRowViewModel.weight,
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

                          num? doubleValue = ConvertValidate.numberFomatterDouble1DecimalDigit.tryParse(text);
                          if (doubleValue != null) {
                            if (ConvertValidate.decimalHasMoreThan1DecimalDigit(decimalstring: text)) {
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
                        num? doubleValue = ConvertValidate.numberFomatterDouble1DecimalDigit.tryParse(value);
                        weightRowViewModel.weight.value = doubleValue as double?;

                        if (doubleValue != null) {
                          _weightController.text = ConvertValidate.getCleanDoubleEditString1DecimalDigit(doubleValue: doubleValue, doubleValueString: value);
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
                      await widget._onDeletePressed(date: weightRowViewModel.date);
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
            valueListenable: weightRowViewModel.weightValid,
            builder: (_, _, _) {
              if (!weightRowViewModel.weightValid.value) {
                return Text(
                  "${AppLocalizations.of(context)!.input_invalid_value(AppLocalizations.of(context)!.weight_capital, ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: weightRowViewModel.lastValidWeight))} ${AppLocalizations.of(context)!.valid_weight} (1-${ConvertValidate.getCleanDoubleString1DecimalDigit(doubleValue: ConvertValidate.getDisplayWeightKg(weightKg: ConvertValidate.maxWeightKg.toDouble()))}).",
                  style: textTheme.labelSmall!.copyWith(color: Colors.red),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
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
    _weightController.dispose();
    _weightFocusNode.dispose();

    super.dispose();
  }
}
