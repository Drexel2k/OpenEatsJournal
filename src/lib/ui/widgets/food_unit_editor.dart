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
  late FoodUnitEditorViewModel _foodUnitEditorViewModel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _foodUnitEditorViewModel = widget._foodUnitEditorViewModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _nameController.text = _foodUnitEditorViewModel.name.value;
    _amountController.text = _foodUnitEditorViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(_foodUnitEditorViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
              child: ValueListenableBuilder(
                valueListenable: _foodUnitEditorViewModel.foodUnitsEditMode,
                builder: (_, _, _) {
                  if (_foodUnitEditorViewModel.foodUnitsEditMode.value) {
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
                  valueListenable: _foodUnitEditorViewModel.foodUnitsEditMode,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _nameController,
                      enabled: _foodUnitEditorViewModel.foodUnitsEditMode.value,
                      onChanged: (value) {
                        _foodUnitEditorViewModel.name.value = value;
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: ValueListenableBuilder(
                valueListenable: _foodUnitEditorViewModel.foodUnitsEditMode,
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
                    enabled: _foodUnitEditorViewModel.foodUnitsEditMode.value,
                    onTap: () {
                      _amountController.selection = TextSelection(baseOffset: 0, extentOffset: _amountController.text.length);
                    },
                    onChanged: (value) {
                      double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                      _foodUnitEditorViewModel.amount.value = doubleValue;
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
                listenable: _foodUnitEditorViewModel.measurementUnitSwitchButtonChanged,
                builder: (_, _) {
                  return RoundOutlinedButton(
                    onPressed: _foodUnitEditorViewModel.foodUnitsEditMode.value
                        ? (_foodUnitEditorViewModel.measurementUnitSwitchButtonEnabled.value
                              ? () {
                                  _foodUnitEditorViewModel.currentMeasurementUnit.value =
                                      _foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                                      ? MeasurementUnit.milliliter
                                      : MeasurementUnit.gram;
                                }
                              : null)
                        : null,
                    child: Text(
                      _foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
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
                listenable: _foodUnitEditorViewModel.defaultButtonChanged,
                builder: (_, _) {
                  return Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: _foodUnitEditorViewModel.defaultFoodUnit.value,
                    onChanged: _foodUnitEditorViewModel.foodUnitsEditMode.value
                        ? (value) {
                            if (value) {
                              //Calback must only triggered from ui change, because it then changes the default flag of other food units which causes a stack
                              //overflow if any change from the model trigger the callback, too. Order is important, first remove default flag from the existing
                              //default food unit, then set default flag on the current food unit. Otherwise the callback may remove the default on the current
                              //food unit immediately again.
                              _foodUnitEditorViewModel.triggerDefaultChangedCallback();

                              _foodUnitEditorViewModel.defaultFoodUnit.value = value;
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: ValueListenableBuilder(
                valueListenable: _foodUnitEditorViewModel.foodUnitsEditMode,
                builder: (_, _, _) {
                  return RoundOutlinedButton(
                    onPressed: _foodUnitEditorViewModel.foodUnitsEditMode.value
                        ? () {
                            _foodUnitEditorViewModel.removeFoodUnit();
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
          valueListenable: _foodUnitEditorViewModel.nameValid,
          builder: (_, _, _) {
            if (!_foodUnitEditorViewModel.nameValid.value) {
              return Text(
                AppLocalizations.of(context)!.input_invalid_value(
                  AppLocalizations.of(context)!.name_capital,
                  _foodUnitEditorViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                      ? AppLocalizations.of(context)!.empty
                      : _foodUnitEditorViewModel.name.value,
                ),
                style: textTheme.labelMedium!.copyWith(color: Colors.red),
              );
            } else {
              return SizedBox();
            }
          },
        ),
        ValueListenableBuilder(
          valueListenable: _foodUnitEditorViewModel.amountValid,
          builder: (_, _, _) {
            if (!_foodUnitEditorViewModel.amountValid.value) {
              return Text(
                AppLocalizations.of(
                  context,
                )!.input_invalid(AppLocalizations.of(context)!.amount),
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
    if (widget._foodUnitEditorViewModel != _foodUnitEditorViewModel) {
      _foodUnitEditorViewModel.dispose();
    }

    _nameController.dispose();
    _amountController.dispose();

    super.dispose();
  }
}
