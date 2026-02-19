import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/entity_edited.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class EatsJournalQuickEntryEditScreen extends StatefulWidget {
  const EatsJournalQuickEntryEditScreen({super.key, required EatsJournalQuickEntryEditScreenViewModel eatsJournalQuickEntryEditScreenViewModel})
    : _eatsJournalQuickEntryEditScreenViewModel = eatsJournalQuickEntryEditScreenViewModel;

  final EatsJournalQuickEntryEditScreenViewModel _eatsJournalQuickEntryEditScreenViewModel;

  @override
  State<EatsJournalQuickEntryEditScreen> createState() => _EatsJournalQuickEntryEditScreenState();
}

class _EatsJournalQuickEntryEditScreenState extends State<EatsJournalQuickEntryEditScreen> with SingleTickerProviderStateMixin {
  late EatsJournalQuickEntryEditScreenViewModel _eatsJournalQuickEntryEditScreenViewModel;
  late AnimationController _animationController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _energyController = TextEditingController();
  final TextEditingController _carbohydratesController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _saturatedFatController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _saltController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _energyFocusNode = FocusNode();
  final FocusNode _carbohydratesFocusNode = FocusNode();
  final FocusNode _sugarFocusNode = FocusNode();
  final FocusNode _fatFocusNode = FocusNode();
  final FocusNode _saturatedFatFocusNode = FocusNode();
  final FocusNode _proteinFocusNode = FocusNode();
  final FocusNode _saltFocusNode = FocusNode();

  @override
  void initState() {
    _eatsJournalQuickEntryEditScreenViewModel = widget._eatsJournalQuickEntryEditScreenViewModel;
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _nameController.text = _eatsJournalQuickEntryEditScreenViewModel.name.value;
    _amountController.text = _eatsJournalQuickEntryEditScreenViewModel.amount.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalQuickEntryEditScreenViewModel.amount.value!)
        : OpenEatsJournalStrings.emptyString;
    _energyController.text = _eatsJournalQuickEntryEditScreenViewModel.energy.value != null
        ? ConvertValidate.numberFomatterInt.format(_eatsJournalQuickEntryEditScreenViewModel.energy.value)
        : OpenEatsJournalStrings.emptyString;
    _carbohydratesController.text = _eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value!)
        : OpenEatsJournalStrings.emptyString;
    _sugarController.text = _eatsJournalQuickEntryEditScreenViewModel.sugar.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalQuickEntryEditScreenViewModel.sugar.value!)
        : OpenEatsJournalStrings.emptyString;
    _fatController.text = _eatsJournalQuickEntryEditScreenViewModel.fat.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalQuickEntryEditScreenViewModel.fat.value!)
        : OpenEatsJournalStrings.emptyString;
    _saturatedFatController.text = _eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value!)
        : OpenEatsJournalStrings.emptyString;
    _proteinController.text = _eatsJournalQuickEntryEditScreenViewModel.protein.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalQuickEntryEditScreenViewModel.protein.value!)
        : OpenEatsJournalStrings.emptyString;
    _saltController.text = _eatsJournalQuickEntryEditScreenViewModel.salt.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: _eatsJournalQuickEntryEditScreenViewModel.salt.value!)
        : OpenEatsJournalStrings.emptyString;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    double inputFieldsWidth = 90;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
      title: _eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
          ? AppLocalizations.of(context)!.add_quick_entry
          : AppLocalizations.of(context)!.edit_quick_entry,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.currentEntryDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        //for creating entries take value from setting, for editing entries take value from entry
                        DateTime initialDate = _eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
                            ? _eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value
                            : _eatsJournalQuickEntryEditScreenViewModel.quickEntry.entryDate;

                        await _selectDate(initialDate: initialDate, context: context);
                      },
                      style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    //for creating entries take value from setting, for editing entries take value from entry
                    int initialSelection = _eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
                        ? _eatsJournalQuickEntryEditScreenViewModel.currentMeal.value.value
                        : _eatsJournalQuickEntryEditScreenViewModel.quickEntry.meal.value;

                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _eatsJournalQuickEntryEditScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
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
                      children: [Expanded(child: Text("${AppLocalizations.of(context)!.name}:", style: textTheme.titleSmall))],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: _eatsJournalQuickEntryEditScreenViewModel.name,
                            builder: (_, _, _) {
                              return OpenEatsJournalTextField(
                                controller: _nameController,
                                onChanged: (value) {
                                  _eatsJournalQuickEntryEditScreenViewModel.name.value = value;
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
                            valueListenable: _eatsJournalQuickEntryEditScreenViewModel.nameValid,
                            builder: (_, _, _) {
                              if (!_eatsJournalQuickEntryEditScreenViewModel.nameValid.value) {
                                return Text(
                                  AppLocalizations.of(context)!.input_invalid_value(
                                    AppLocalizations.of(context)!.name_capital,
                                    _eatsJournalQuickEntryEditScreenViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                                        ? AppLocalizations.of(context)!.empty
                                        : _eatsJournalQuickEntryEditScreenViewModel.name.value,
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
              _eatsJournalQuickEntryEditScreenViewModel.quickEntry.id != null
                  ? PopupMenuButton<String>(
                      onSelected: (selected) {},
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            onTap: () async {
                              EntityEdited? eatsJournalEntryEdited =
                                  await Navigator.pushNamed(
                                        context,
                                        OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
                                        arguments: EatsJournalEntry.quick(
                                          entryDate: _eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value,
                                          name: _eatsJournalQuickEntryEditScreenViewModel.name.value,
                                          kJoule: _eatsJournalQuickEntryEditScreenViewModel.energy.value != null
                                              ? ConvertValidate.getEnergyKJ(displayEnergy: _eatsJournalQuickEntryEditScreenViewModel.energy.value!)
                                              : 1,
                                          meal: _eatsJournalQuickEntryEditScreenViewModel.currentMeal.value,
                                          amount: _eatsJournalQuickEntryEditScreenViewModel.amount.value,
                                          amountMeasurementUnit: _eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value,
                                          carbohydrates: _eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value,
                                          sugar: _eatsJournalQuickEntryEditScreenViewModel.sugar.value,
                                          fat: _eatsJournalQuickEntryEditScreenViewModel.fat.value,
                                          saturatedFat: _eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value,
                                          protein: _eatsJournalQuickEntryEditScreenViewModel.protein.value,
                                          salt: _eatsJournalQuickEntryEditScreenViewModel.salt.value,
                                        ),
                                      )
                                      as EntityEdited?;

                              if (eatsJournalEntryEdited != null) {
                                UiHelpers.showOverlay(
                                  context: AppGlobal.navigatorKey.currentContext!,
                                  displayText: eatsJournalEntryEdited.originalId == null
                                      ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                                      : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                                  animationController: _animationController,
                                );
                              }
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
              Expanded(
                child: Text("${ConvertValidate.getLocalizedEnergyUnit(context: context)}:", style: textTheme.titleSmall),
              ),
              Expanded(child: Text("${AppLocalizations.of(context)!.amount}:", style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.energy,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _energyController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      focusNode: _energyFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_energyFocusNode.hasFocus) {
                          _energyController.selection = TextSelection(baseOffset: 0, extentOffset: _energyController.text.length);
                        }
                      },
                      onChanged: (value) {
                        int? intValue = int.tryParse(value);
                        _eatsJournalQuickEntryEditScreenViewModel.energy.value = intValue;
                        if (intValue != null) {
                          _energyController.text = ConvertValidate.numberFomatterInt.format(intValue);
                        }
                      },
                    );
                  },
                ),
              ),
              Spacer(),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.amount,
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
                        _eatsJournalQuickEntryEditScreenViewModel.amount.value = doubleValue;

                        if (doubleValue != null) {
                          _amountController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
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
                    listenable: _eatsJournalQuickEntryEditScreenViewModel.measurementUnitSwitchButtonChanged,
                    builder: (_, _) {
                      return RoundOutlinedButton(
                        onPressed: () {
                          _eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value =
                              _eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value == MeasurementUnit.gram
                              ? MeasurementUnit.milliliter
                              : MeasurementUnit.gram;
                        },
                        child: Text(
                          _eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value == MeasurementUnit.gram
                              ? ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)
                              : ConvertValidate.getLocalizedVolumeUnit2char(context: context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: _eatsJournalQuickEntryEditScreenViewModel.energyValid,
            builder: (_, _, _) {
              if (!_eatsJournalQuickEntryEditScreenViewModel.energyValid.value) {
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
              Expanded(child: Text("${AppLocalizations.of(context)!.carbohydrates}:", style: textTheme.titleSmall)),
              Expanded(child: Text("${AppLocalizations.of(context)!.sugar}:", style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.carbohydrates,
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
                      focusNode: _carbohydratesFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_carbohydratesFocusNode.hasFocus) {
                          _carbohydratesController.selection = TextSelection(baseOffset: 0, extentOffset: _carbohydratesController.text.length);
                        }
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                        _eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value = doubleValue;

                        if (doubleValue != null) {
                          _carbohydratesController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Spacer(),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.sugar,
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
                      focusNode: _sugarFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_sugarFocusNode.hasFocus) {
                          _sugarController.selection = TextSelection(baseOffset: 0, extentOffset: _sugarController.text.length);
                        }
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                        _eatsJournalQuickEntryEditScreenViewModel.sugar.value = doubleValue;

                        if (doubleValue != null) {
                          _sugarController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Spacer(),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("${AppLocalizations.of(context)!.fat}:", style: textTheme.titleSmall)),
              Expanded(child: Text("${AppLocalizations.of(context)!.saturated_fat}:", style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.fat,
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
                      focusNode: _fatFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_fatFocusNode.hasFocus) {
                          _fatController.selection = TextSelection(baseOffset: 0, extentOffset: _fatController.text.length);
                        }
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                        _eatsJournalQuickEntryEditScreenViewModel.fat.value = doubleValue;

                        if (doubleValue != null) {
                          _fatController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Spacer(),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.saturatedFat,
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
                      focusNode: _saturatedFatFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_saturatedFatFocusNode.hasFocus) {
                          _saturatedFatController.selection = TextSelection(baseOffset: 0, extentOffset: _saturatedFatController.text.length);
                        }
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                        _eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value = doubleValue;

                        if (doubleValue != null) {
                          _saturatedFatController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Spacer(),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("${AppLocalizations.of(context)!.protein}:", style: textTheme.titleSmall)),
              Expanded(child: Text("${AppLocalizations.of(context)!.salt}:", style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.protein,
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
                      focusNode: _proteinFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_proteinFocusNode.hasFocus) {
                          _proteinController.selection = TextSelection(baseOffset: 0, extentOffset: _proteinController.text.length);
                        }
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value) as double?;
                        _eatsJournalQuickEntryEditScreenViewModel.protein.value = doubleValue;

                        if (doubleValue != null) {
                          _proteinController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Spacer(),
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: _eatsJournalQuickEntryEditScreenViewModel.salt,
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
                      focusNode: _saltFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_saltFocusNode.hasFocus) {
                          _saltController.selection = TextSelection(baseOffset: 0, extentOffset: _saltController.text.length);
                        }
                      },
                      onChanged: (value) {
                        num? doubleValue = ConvertValidate.numberFomatterDouble3DecimalDigits.tryParse(value);
                        _eatsJournalQuickEntryEditScreenViewModel.salt.value = doubleValue as double?;

                        if (doubleValue != null) {
                          _saltController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Spacer(),
            ],
          ),
          Divider(thickness: 2, height: 20),
          Align(
            alignment: AlignmentGeometry.center,

            child: RoundOutlinedButton(
              onPressed: () async {
                int? originalQuickEntryId = _eatsJournalQuickEntryEditScreenViewModel.quickEntry.id;

                if (!(await _eatsJournalQuickEntryEditScreenViewModel.setQuickEntry())) {
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
                  Navigator.pop(AppGlobal.navigatorKey.currentContext!, EntityEdited(originalId: originalQuickEntryId));
                }
              },
              child: _eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
                  ? Icon(Icons.add_circle_outline, size: 36)
                  : Icon(Icons.save_alt, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      _eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value = date;
    }
  }

  @override
  void dispose() {
    widget._eatsJournalQuickEntryEditScreenViewModel.dispose();
    if (widget._eatsJournalQuickEntryEditScreenViewModel != _eatsJournalQuickEntryEditScreenViewModel) {
      _eatsJournalQuickEntryEditScreenViewModel.dispose();
    }

    _nameController.dispose();
    _amountController.dispose();
    _energyController.dispose();
    _carbohydratesController.dispose();
    _sugarController.dispose();
    _fatController.dispose();
    _saturatedFatController.dispose();
    _proteinController.dispose();
    _saltController.dispose();

    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    _energyFocusNode.dispose();
    _carbohydratesFocusNode.dispose();
    _sugarFocusNode.dispose();
    _fatFocusNode.dispose();
    _saturatedFatFocusNode.dispose();
    _proteinFocusNode.dispose();
    _saltFocusNode.dispose();

    super.dispose();
  }
}
