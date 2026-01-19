import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class EatsJournalQuickEntryEditScreen extends StatefulWidget {
  const EatsJournalQuickEntryEditScreen({super.key, required EatsJournalQuickEntryEditScreenViewModel eatsJournalQuickEntryAddScreenViewModel})
    : _eatsJournalQuickEntryAddScreenViewModel = eatsJournalQuickEntryAddScreenViewModel;

  final EatsJournalQuickEntryEditScreenViewModel _eatsJournalQuickEntryAddScreenViewModel;

  @override
  State<EatsJournalQuickEntryEditScreen> createState() => _EatsJournalQuickEntryEditScreenState();
}

class _EatsJournalQuickEntryEditScreenState extends State<EatsJournalQuickEntryEditScreen> {
  late EatsJournalQuickEntryEditScreenViewModel _eatsJournalQuickEntryAddScreenViewModel;

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
  void initState() {
    _eatsJournalQuickEntryAddScreenViewModel = widget._eatsJournalQuickEntryAddScreenViewModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _nameController.text = _eatsJournalQuickEntryAddScreenViewModel.name.value;
    _amountController.text = _eatsJournalQuickEntryAddScreenViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(_eatsJournalQuickEntryAddScreenViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;
    _kCalController.text = _eatsJournalQuickEntryAddScreenViewModel.kJoule.value != null
        ? ConvertValidate.numberFomatterInt.format(
            NutritionCalculator.getKCalsFromKJoules(kJoules: _eatsJournalQuickEntryAddScreenViewModel.kJoule.value as int),
          )
        : OpenEatsJournalStrings.emptyString;

    double inputFieldsWidth = 90;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
      title: _eatsJournalQuickEntryAddScreenViewModel.quickEntry.id == null
          ? AppLocalizations.of(context)!.add_quick_entry
          : AppLocalizations.of(context)!.edit_quick_entry,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.currentEntryDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        //for creating entries take value from setting, for editing entries take value from entry
                        DateTime initialDate = _eatsJournalQuickEntryAddScreenViewModel.quickEntry.id == null
                            ? _eatsJournalQuickEntryAddScreenViewModel.currentEntryDate.value
                            : _eatsJournalQuickEntryAddScreenViewModel.quickEntry.entryDate;

                        await _selectDate(initialDate: initialDate, context: context);
                      },
                      style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalQuickEntryAddScreenViewModel.currentEntryDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    //for creating entries take value from setting, for editing entries take value from entry
                    int initialSelection = _eatsJournalQuickEntryAddScreenViewModel.quickEntry.id == null
                        ? _eatsJournalQuickEntryAddScreenViewModel.currentMeal.value.value
                        : _eatsJournalQuickEntryAddScreenViewModel.quickEntry.meal.value;

                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _eatsJournalQuickEntryAddScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(context: context),
                      initialSelection: initialSelection,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [Expanded(child: Text(AppLocalizations.of(context)!.name_capital, style: textTheme.titleSmall))],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: _eatsJournalQuickEntryAddScreenViewModel.name,
                            builder: (_, _, _) {
                              return OpenEatsJournalTextField(
                                controller: _nameController,
                                onChanged: (value) {
                                  _eatsJournalQuickEntryAddScreenViewModel.name.value = value;
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
                            valueListenable: _eatsJournalQuickEntryAddScreenViewModel.nameValid,
                            builder: (_, _, _) {
                              if (!_eatsJournalQuickEntryAddScreenViewModel.nameValid.value) {
                                return Text(
                                  AppLocalizations.of(context)!.input_invalid_value(
                                    AppLocalizations.of(context)!.name_capital,
                                    _eatsJournalQuickEntryAddScreenViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                                        ? AppLocalizations.of(context)!.empty
                                        : _eatsJournalQuickEntryAddScreenViewModel.name.value,
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
                  ],
                ),
              ),
              _eatsJournalQuickEntryAddScreenViewModel.quickEntry.id != null
                  ? PopupMenuButton<String>(
                      onSelected: (selected) {},
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
                                arguments: EatsJournalEntry.quick(
                                  entryDate: _eatsJournalQuickEntryAddScreenViewModel.currentEntryDate.value,
                                  name: _eatsJournalQuickEntryAddScreenViewModel.name.value,
                                  kJoule: _eatsJournalQuickEntryAddScreenViewModel.kJoule.value != null
                                      ? _eatsJournalQuickEntryAddScreenViewModel.kJoule.value!
                                      : 1,
                                  meal: _eatsJournalQuickEntryAddScreenViewModel.currentMeal.value,
                                  amount: _eatsJournalQuickEntryAddScreenViewModel.amount.value,
                                  amountMeasurementUnit: _eatsJournalQuickEntryAddScreenViewModel.amountMeasurementUnit.value,
                                  carbohydrates: _eatsJournalQuickEntryAddScreenViewModel.carbohydrates.value,
                                  sugar: _eatsJournalQuickEntryAddScreenViewModel.sugar.value,
                                  fat: _eatsJournalQuickEntryAddScreenViewModel.fat.value,
                                  saturatedFat: _eatsJournalQuickEntryAddScreenViewModel.saturatedFat.value,
                                  protein: _eatsJournalQuickEntryAddScreenViewModel.protein.value,
                                  salt: _eatsJournalQuickEntryAddScreenViewModel.salt.value,
                                ),
                              );
                            },
                            child: Text(AppLocalizations.of(context)!.as_new_eats_journal_entry),
                          ),
                        ];
                      },
                      child: SizedBox(height: 30, width: 40, child: Icon(Icons.more_vert)),
                    )
                  : SizedBox(),
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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.kJoule,
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
                        _eatsJournalQuickEntryAddScreenViewModel.kJoule.value = intValue != null
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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.amount,
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
                        _eatsJournalQuickEntryAddScreenViewModel.amount.value = doubleValue;

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
                    listenable: _eatsJournalQuickEntryAddScreenViewModel.measurementUnitSwitchButtonChanged,
                    builder: (_, _) {
                      return RoundOutlinedButton(
                        onPressed: () {
                          _eatsJournalQuickEntryAddScreenViewModel.currentMeasurementUnit.value =
                              _eatsJournalQuickEntryAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                              ? MeasurementUnit.milliliter
                              : MeasurementUnit.gram;
                        },
                        child: Text(
                          _eatsJournalQuickEntryAddScreenViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
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
            valueListenable: _eatsJournalQuickEntryAddScreenViewModel.kJouleValid,
            builder: (_, _, _) {
              if (!_eatsJournalQuickEntryAddScreenViewModel.kJouleValid.value) {
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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.carbohydrates,
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
                        _eatsJournalQuickEntryAddScreenViewModel.carbohydrates.value = doubleValue;

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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.sugar,
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
                        _eatsJournalQuickEntryAddScreenViewModel.sugar.value = doubleValue;

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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.fat,
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
                        _eatsJournalQuickEntryAddScreenViewModel.fat.value = doubleValue;

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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.saturatedFat,
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
                        _eatsJournalQuickEntryAddScreenViewModel.saturatedFat.value = doubleValue;

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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.protein,
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
                        _eatsJournalQuickEntryAddScreenViewModel.protein.value = doubleValue;

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
                  valueListenable: _eatsJournalQuickEntryAddScreenViewModel.salt,
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
                        _eatsJournalQuickEntryAddScreenViewModel.salt.value = doubleValue as double?;

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
                  int? originalQuickEntryId = _eatsJournalQuickEntryAddScreenViewModel.quickEntry.id;

                  if (!(await _eatsJournalQuickEntryAddScreenViewModel.setQuickEntry())) {
                    SnackBar snackBar = SnackBar(
                      content: Text(AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.cant_create_quick_entry),
                      action: SnackBarAction(
                        label: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.close,
                        onPressed: () {
                          //Click on SnackbarAction closes the SnackBar,
                          //nothing else to do here...
                        },
                      ),
                    );
                    ScaffoldMessenger.of(AppGlobal.navigatorKey.currentContext!).showSnackBar(snackBar);
                  } else {
                    SnackBar snackBar = SnackBar(
                      content: originalQuickEntryId == null
                          ? Text(AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added)
                          : Text(AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated),
                      action: SnackBarAction(
                        label: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.close,
                        onPressed: () {
                          //Click on SnackbarAction closes the SnackBar,
                          //nothing else to do here...
                        },
                      ),
                    );
                    ScaffoldMessenger.of(AppGlobal.navigatorKey.currentContext!).showSnackBar(snackBar);
                    Navigator.pop(AppGlobal.navigatorKey.currentContext!);
                  }
                },
                child: _eatsJournalQuickEntryAddScreenViewModel.quickEntry.id == null
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
      _eatsJournalQuickEntryAddScreenViewModel.currentEntryDate.value = date;
    }
  }

  @override
  void dispose() {
    widget._eatsJournalQuickEntryAddScreenViewModel.dispose();
    if (widget._eatsJournalQuickEntryAddScreenViewModel != _eatsJournalQuickEntryAddScreenViewModel) {
      _eatsJournalQuickEntryAddScreenViewModel.dispose();
    }

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
