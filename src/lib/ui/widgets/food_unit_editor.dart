import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/widgets/food_unit_editor_viewmodel.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class FoodUnitEditor extends StatefulWidget {
  const FoodUnitEditor({super.key, required FoodUnitEditorViewModel foodUnitEditorViewModel}) : _foodUnitEditorViewModel = foodUnitEditorViewModel;

  final FoodUnitEditorViewModel _foodUnitEditorViewModel;

  @override
  State<FoodUnitEditor> createState() => _FoodUnitEditorState();
}

class _FoodUnitEditorState extends State<FoodUnitEditor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _nameController.text = widget._foodUnitEditorViewModel.name.value;
    _amountController.text = widget._foodUnitEditorViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(widget._foodUnitEditorViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
              child: ValueListenableBuilder(
                valueListenable: widget._foodUnitEditorViewModel.foodUnitsEditMode,
                builder: (_, _, _) {
                  if (widget._foodUnitEditorViewModel.foodUnitsEditMode.value) {
                    return Icon(Icons.mode_edit);
                  } else {
                    return Icon(Icons.drag_handle);
                  }
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                child: ValueListenableBuilder(
                  valueListenable: widget._foodUnitEditorViewModel.foodUnitsEditMode,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _nameController,
                      enabled: widget._foodUnitEditorViewModel.foodUnitsEditMode.value,
                      onChanged: (value) {
                        widget._foodUnitEditorViewModel.name.value = value;
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: ValueListenableBuilder(
                valueListenable: widget._foodUnitEditorViewModel.foodUnitsEditMode,
                builder: (_, _, _) {
                  return OpenEatsJournalTextField(
                    controller: _amountController,
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
                    enabled: widget._foodUnitEditorViewModel.foodUnitsEditMode.value,
                    onTap: () {
                      _amountController.selection = TextSelection(baseOffset: 0, extentOffset: _amountController.text.length);
                    },
                    onChanged: (value) {
                      double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                      widget._foodUnitEditorViewModel.amount.value = doubleValue;
                      if (doubleValue != null) {
                        _amountController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: ListenableBuilder(
                listenable: widget._foodUnitEditorViewModel.measurementUnitSwitchButtonChanged,
                builder: (_, _) {
                  return RoundOutlinedButton(
                    onPressed: widget._foodUnitEditorViewModel.foodUnitsEditMode.value
                        ? (widget._foodUnitEditorViewModel.measurementUnitSwitchButtonEnabled.value
                              ? () {
                                  widget._foodUnitEditorViewModel.currentMeasurementUnit.value =
                                      widget._foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                                      ? MeasurementUnit.milliliter
                                      : MeasurementUnit.gram;
                                }
                              : null)
                        : null,
                    child: Text(
                      widget._foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                          ? AppLocalizations.of(context)!.gram_abbreviated
                          : AppLocalizations.of(context)!.milliliter_abbreviated,
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: 52,
              child: ListenableBuilder(
                listenable: widget._foodUnitEditorViewModel.defaultButtonChanged,
                builder: (_, _) {
                  return Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: widget._foodUnitEditorViewModel.defaultFoodUnit.value,
                    onChanged: widget._foodUnitEditorViewModel.foodUnitsEditMode.value
                        ? (value) => widget._foodUnitEditorViewModel.defaultFoodUnit.value = value
                        : null,
                  );
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: ValueListenableBuilder(
                valueListenable: widget._foodUnitEditorViewModel.foodUnitsEditMode,
                builder: (_, _, _) {
                  return RoundOutlinedButton(
                    onPressed: widget._foodUnitEditorViewModel.foodUnitsEditMode.value
                        ? () {
                            widget._foodUnitEditorViewModel.removeFoodUnit();
                          }
                        : null,
                    child: Icon(Icons.delete),
                  );
                },
              ),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: widget._foodUnitEditorViewModel.nameValid,
          builder: (_, _, _) {
            if (!widget._foodUnitEditorViewModel.nameValid.value) {
              return Text(
                AppLocalizations.of(context)!.input_invalid_value(
                  AppLocalizations.of(context)!.name_capital,
                  widget._foodUnitEditorViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                      ? AppLocalizations.of(context)!.empty
                      : widget._foodUnitEditorViewModel.name.value,
                ),
                style: textTheme.labelMedium!.copyWith(color: Colors.red),
              );
            } else {
              return SizedBox();
            }
          },
        ),
        ValueListenableBuilder(
          valueListenable: widget._foodUnitEditorViewModel.amountValid,
          builder: (_, _, _) {
            if (!widget._foodUnitEditorViewModel.amountValid.value) {
              return Text(
                AppLocalizations.of(context)!.input_invalid_value(
                  AppLocalizations.of(context)!.kjoule,
                  ConvertValidate.numberFomatterInt.format(widget._foodUnitEditorViewModel.amount.value),
                ),
                style: textTheme.labelMedium!.copyWith(color: Colors.red),
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget._foodUnitEditorViewModel.dispose();
    _nameController.dispose();
    _amountController.dispose();

    super.dispose();
  }
}
