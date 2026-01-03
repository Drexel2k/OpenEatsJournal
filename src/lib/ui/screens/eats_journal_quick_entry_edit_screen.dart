import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/meal.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/global_navigator_key.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/main_layout.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen_viewmodel.dart';
import 'package:openeatsjournal/ui/utils/localized_drop_down_entries.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class EatsJournalQuickEntryEditScreen extends StatefulWidget {
  const EatsJournalQuickEntryEditScreen({super.key, required EatsJournalQuickEntryEditScreenViewModel eatsJournalQuickEntryAddScreenViewModel})
    : _eatsJournalQuickEntryAddScreenViewModel = eatsJournalQuickEntryAddScreenViewModel;

  final EatsJournalQuickEntryEditScreenViewModel _eatsJournalQuickEntryAddScreenViewModel;

  @override
  State<EatsJournalQuickEntryEditScreen> createState() => _EatsJournalQuickEntryEditScreenState();
}

class _EatsJournalQuickEntryEditScreenState extends State<EatsJournalQuickEntryEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _kCalController = TextEditingController();
  final TextEditingController _carbohydratesController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _saturatedFatController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _saltController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _nameController.text = widget._eatsJournalQuickEntryAddScreenViewModel.name.value;
    _amountController.text = widget._eatsJournalQuickEntryAddScreenViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(widget._eatsJournalQuickEntryAddScreenViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;
    _kCalController.text = widget._eatsJournalQuickEntryAddScreenViewModel.kJoule.value != null
        ? ConvertValidate.numberFomatterInt.format(
            NutritionCalculator.getKCalsFromKJoules(kJoules: widget._eatsJournalQuickEntryAddScreenViewModel.kJoule.value as int),
          )
        : OpenEatsJournalStrings.emptyString;

    double inputFieldsWidth = 90;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
      title: widget._eatsJournalQuickEntryAddScreenViewModel.quickEntryId == null
          ? AppLocalizations.of(context)!.add_quick_entry
          : AppLocalizations.of(context)!.edit_quick_entry,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.currentJournalDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        await _selectDate(initialDate: widget._eatsJournalQuickEntryAddScreenViewModel.currentJournalDate.value, context: context);
                      },
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._eatsJournalQuickEntryAddScreenViewModel.currentJournalDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        widget._eatsJournalQuickEntryAddScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: widget._eatsJournalQuickEntryAddScreenViewModel.currentMeal.value.value,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [Expanded(child: Text(AppLocalizations.of(context)!.name_capital, style: textTheme.titleSmall))],
          ),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.name,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _nameController,
                      onChanged: (value) {
                        widget._eatsJournalQuickEntryAddScreenViewModel.name.value = value;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.nameValid,
                  builder: (_, _, _) {
                    if (!widget._eatsJournalQuickEntryAddScreenViewModel.nameValid.value) {
                      return Text(
                        AppLocalizations.of(context)!.input_invalid_value(
                          AppLocalizations.of(context)!.name_capital,
                          widget._eatsJournalQuickEntryAddScreenViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                              ? AppLocalizations.of(context)!.empty
                              : widget._eatsJournalQuickEntryAddScreenViewModel.name.value,
                        ),
                        style: textTheme.labelMedium!.copyWith(color: Colors.red),
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
          Divider(thickness: 2, height: 20),
          Text(AppLocalizations.of(context)!.nutrition_values, style: textTheme.titleMedium),
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.kcal_label, style: textTheme.titleSmall)),
              Expanded(child: Text(AppLocalizations.of(context)!.amount_label, style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.kJoule,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _kCalController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () {
                        _kCalController.selection = TextSelection(baseOffset: 0, extentOffset: _kCalController.text.length);
                      },
                      onChanged: (value) {
                        int? intValue = int.tryParse(value);
                        widget._eatsJournalQuickEntryAddScreenViewModel.kJoule.value = intValue != null
                            ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue)
                            : null;
                        if (intValue != null) {
                          _kCalController.text = ConvertValidate.numberFomatterInt.format(intValue);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox(height: 0)),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.amount,
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
                      onTap: () {
                        _amountController.selection = TextSelection(baseOffset: 0, extentOffset: _amountController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalQuickEntryAddScreenViewModel.amount.value = doubleValue;

                        if (doubleValue != null) {
                          _amountController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: 50,
                  child: ListenableBuilder(
                    listenable: widget._eatsJournalQuickEntryAddScreenViewModel.measurementUnitSwitchButtonChanged,
                    builder: (_, _) {
                      return RoundOutlinedButton(
                        onPressed: () {
                          widget._eatsJournalQuickEntryAddScreenViewModel.currentMeasurementUnit.value =
                              widget._eatsJournalQuickEntryAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                              ? MeasurementUnit.milliliter
                              : MeasurementUnit.gram;
                        },
                        child: Text(
                          widget._eatsJournalQuickEntryAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                              ? AppLocalizations.of(context)!.gram_abbreviated
                              : AppLocalizations.of(context)!.milliliter_abbreviated,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.kJouleValid,
            builder: (_, _, _) {
              if (!widget._eatsJournalQuickEntryAddScreenViewModel.kJouleValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid_value(AppLocalizations.of(context)!.kjoule, AppLocalizations.of(context)!.nothing),
                  style: textTheme.labelMedium!.copyWith(color: Colors.red),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.carbohydrates, style: textTheme.titleSmall)),
              Expanded(child: Text(AppLocalizations.of(context)!.sugar, style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.carbohydrates,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _carbohydratesController,
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
                        _carbohydratesController.selection = TextSelection(baseOffset: 0, extentOffset: _carbohydratesController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalQuickEntryAddScreenViewModel.carbohydrates.value = doubleValue;

                        if (doubleValue != null) {
                          _carbohydratesController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox(height: 0)),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.sugar,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _sugarController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
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
                        _sugarController.selection = TextSelection(baseOffset: 0, extentOffset: _sugarController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalQuickEntryAddScreenViewModel.sugar.value = doubleValue;

                        if (doubleValue != null) {
                          _sugarController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox(height: 0)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.fat_label, style: textTheme.titleSmall)),
              Expanded(child: Text(AppLocalizations.of(context)!.saturated_fat, style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.fat,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _fatController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
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
                        _fatController.selection = TextSelection(baseOffset: 0, extentOffset: _fatController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalQuickEntryAddScreenViewModel.fat.value = doubleValue;

                        if (doubleValue != null) {
                          _fatController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox(height: 0)),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.saturatedFat,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _saturatedFatController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
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
                        _saturatedFatController.selection = TextSelection(baseOffset: 0, extentOffset: _saturatedFatController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalQuickEntryAddScreenViewModel.saturatedFat.value = doubleValue;

                        if (doubleValue != null) {
                          _saturatedFatController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox(height: 0)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.protein, style: textTheme.titleSmall)),
              Expanded(child: Text(AppLocalizations.of(context)!.salt, style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.protein,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
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
                        _proteinController.selection = TextSelection(baseOffset: 0, extentOffset: _proteinController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._eatsJournalQuickEntryAddScreenViewModel.protein.value = doubleValue;

                        if (doubleValue != null) {
                          _proteinController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox()),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._eatsJournalQuickEntryAddScreenViewModel.salt,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _saltController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
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
                        _saltController.selection = TextSelection(baseOffset: 0, extentOffset: _saltController.text.length);
                      },
                      onChanged: (value) {
                        num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value);
                        widget._eatsJournalQuickEntryAddScreenViewModel.salt.value = doubleValue as double?;

                        if (doubleValue != null) {
                          _saltController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          Divider(thickness: 2, height: 20),
          Align(
            alignment: AlignmentGeometry.center,
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () async {
                  int? originalQuickEntryId = widget._eatsJournalQuickEntryAddScreenViewModel.quickEntryId;

                  if (!(await widget._eatsJournalQuickEntryAddScreenViewModel.setQuickEntry())) {
                    SnackBar snackBar = SnackBar(
                      content: Text(AppLocalizations.of(navigatorKey.currentContext!)!.cant_create_quick_entry),
                      action: SnackBarAction(
                        label: AppLocalizations.of(navigatorKey.currentContext!)!.close,
                        onPressed: () {
                          //Click on SnackbarAction closes the SnackBar,
                          //nothing else to do here...
                        },
                      ),
                    );
                    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackBar);
                  } else {
                    SnackBar snackBar = SnackBar(
                      content: originalQuickEntryId == null
                          ? Text(AppLocalizations.of(navigatorKey.currentContext!)!.quick_entry_added)
                          : Text(AppLocalizations.of(navigatorKey.currentContext!)!.quick_entry_updated),
                      action: SnackBarAction(
                        label: AppLocalizations.of(navigatorKey.currentContext!)!.close,
                        onPressed: () {
                          //Click on SnackbarAction closes the SnackBar,
                          //nothing else to do here...
                        },
                      ),
                    );
                    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackBar);
                    Navigator.pop(navigatorKey.currentContext!);
                  }
                },
                child: widget._eatsJournalQuickEntryAddScreenViewModel.quickEntryId == null
                    ? Text(AppLocalizations.of(context)!.add)
                    : Text(AppLocalizations.of(context)!.update),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      widget._eatsJournalQuickEntryAddScreenViewModel.currentJournalDate.value = date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _kCalController.dispose();
    _carbohydratesController.dispose();
    _sugarController.dispose();
    _fatController.dispose();
    _saturatedFatController.dispose();
    _proteinController.dispose();
    _saltController.dispose();

    super.dispose();
  }
}
