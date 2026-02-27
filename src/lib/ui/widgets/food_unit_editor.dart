import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/widgets/food_unit_editor_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:provider/provider.dart";

class FoodUnitEditor extends StatefulWidget {
  const FoodUnitEditor({super.key});

  @override
  State<FoodUnitEditor> createState() => _FoodUnitEditorState();
}

class _FoodUnitEditorState extends State<FoodUnitEditor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    FoodUnitEditorViewModel foodUnitEditorViewModel = Provider.of<FoodUnitEditorViewModel>(context, listen: false);

    _nameController.text = foodUnitEditorViewModel.name.value;
    _amountController.text = foodUnitEditorViewModel.amount.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: foodUnitEditorViewModel.amount.value!)
        : OpenEatsJournalStrings.emptyString;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<FoodUnitEditorViewModel>(
      builder: (context, foodUnitEditorViewModel, _) => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: ValueListenableBuilder(
                  valueListenable: foodUnitEditorViewModel.foodUnitsEditMode,
                  builder: (_, _, _) {
                    if (foodUnitEditorViewModel.foodUnitsEditMode.value) {
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
                    valueListenable: foodUnitEditorViewModel.foodUnitsEditMode,
                    builder: (_, _, _) {
                      return OpenEatsJournalTextField(
                        controller: _nameController,
                        enabled: foodUnitEditorViewModel.foodUnitsEditMode.value,
                        onChanged: (value) {
                          foodUnitEditorViewModel.name.value = value;
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                child: ValueListenableBuilder(
                  valueListenable: foodUnitEditorViewModel.foodUnitsEditMode,
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

                          num? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(text);
                          if (doubleValue != null) {
                            if (ConvertValidate.decimalHasMoreThan3DecimalDigits(decimalstring: text)) {
                              return oldValue;
                            }

                            return newValue;
                          } else {
                            return oldValue;
                          }
                        }),
                      ],
                      enabled: foodUnitEditorViewModel.foodUnitsEditMode.value,
                      focusNode: _amountFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_amountFocusNode.hasFocus) {
                          _amountController.selection = TextSelection(baseOffset: 0, extentOffset: _amountController.text.length);
                        }
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                        foodUnitEditorViewModel.amount.value = doubleValue;
                        if (doubleValue != null) {
                          _amountController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: 50,
                child: ListenableBuilder(
                  listenable: foodUnitEditorViewModel.measurementUnitSwitchButtonChanged,
                  builder: (_, _) {
                    return RoundOutlinedButton(
                      onPressed: foodUnitEditorViewModel.foodUnitsEditMode.value
                          ? (foodUnitEditorViewModel.measurementUnitSwitchButtonEnabled.value
                                ? () {
                                    foodUnitEditorViewModel.currentMeasurementUnit.value =
                                        foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                                        ? MeasurementUnit.milliliter
                                        : MeasurementUnit.gram;
                                  }
                                : null)
                          : null,
                      child: Text(
                        foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                            ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)
                            : ConvertValidate.getLocalizedVolumeUnit2char(context: context),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 52,
                child: ListenableBuilder(
                  listenable: foodUnitEditorViewModel.defaultButtonChanged,
                  builder: (_, _) {
                    return Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: foodUnitEditorViewModel.defaultFoodUnit.value,
                      onChanged: foodUnitEditorViewModel.foodUnitsEditMode.value
                          ? (value) {
                              if (value) {
                                //Calback must only triggered from ui change, because it then changes the default flag of other food units which causes a stack
                                //overflow if any change from the model trigger the callback, too. Order is important, first remove default flag from the existing
                                //default food unit, then set default flag on the current food unit. Otherwise the callback may remove the default on the current
                                //food unit immediately again.
                                foodUnitEditorViewModel.triggerDefaultChangedCallback();

                                foodUnitEditorViewModel.defaultFoodUnit.value = value;
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
                  valueListenable: foodUnitEditorViewModel.foodUnitsEditMode,
                  builder: (_, _, _) {
                    return RoundOutlinedButton(
                      onPressed: foodUnitEditorViewModel.foodUnitsEditMode.value
                          ? () {
                              foodUnitEditorViewModel.removeFoodUnit();
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
            valueListenable: foodUnitEditorViewModel.nameValid,
            builder: (_, _, _) {
              if (!foodUnitEditorViewModel.nameValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid_value(
                    AppLocalizations.of(context)!.name_capital,
                    foodUnitEditorViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                        ? AppLocalizations.of(context)!.empty
                        : foodUnitEditorViewModel.name.value,
                  ),
                  style: textTheme.labelMedium!.copyWith(color: Colors.red),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          ValueListenableBuilder(
            valueListenable: foodUnitEditorViewModel.amountValid,
            builder: (_, _, _) {
              if (!foodUnitEditorViewModel.amountValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.amount),
                  style: textTheme.labelMedium!.copyWith(color: Colors.red),
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

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();

    _amountFocusNode.dispose();

    super.dispose();
  }
}
