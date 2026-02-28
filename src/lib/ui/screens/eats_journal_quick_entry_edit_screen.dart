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
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:provider/provider.dart";

class EatsJournalQuickEntryEditScreen extends StatefulWidget {
  const EatsJournalQuickEntryEditScreen({super.key});

  @override
  State<EatsJournalQuickEntryEditScreen> createState() => _EatsJournalQuickEntryEditScreenState();
}

class _EatsJournalQuickEntryEditScreenState extends State<EatsJournalQuickEntryEditScreen> with SingleTickerProviderStateMixin {
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

  OverlayDisplay? _overlayDisplayEatsJournalEntryEdit;

  @override
  void initState() {
    super.initState();

    EatsJournalQuickEntryEditScreenViewModel eatsJournalQuickEntryEditScreenViewModel = Provider.of<EatsJournalQuickEntryEditScreenViewModel>(
      context,
      listen: false,
    );

    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _nameController.text = eatsJournalQuickEntryEditScreenViewModel.name.value;
    _amountController.text = eatsJournalQuickEntryEditScreenViewModel.amount.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalQuickEntryEditScreenViewModel.amount.value!)
        : OpenEatsJournalStrings.emptyString;
    _energyController.text = eatsJournalQuickEntryEditScreenViewModel.energy.value != null
        ? ConvertValidate.numberFomatterInt.format(eatsJournalQuickEntryEditScreenViewModel.energy.value)
        : OpenEatsJournalStrings.emptyString;
    _carbohydratesController.text = eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value!)
        : OpenEatsJournalStrings.emptyString;
    _sugarController.text = eatsJournalQuickEntryEditScreenViewModel.sugar.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalQuickEntryEditScreenViewModel.sugar.value!)
        : OpenEatsJournalStrings.emptyString;
    _fatController.text = eatsJournalQuickEntryEditScreenViewModel.fat.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalQuickEntryEditScreenViewModel.fat.value!)
        : OpenEatsJournalStrings.emptyString;
    _saturatedFatController.text = eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value!)
        : OpenEatsJournalStrings.emptyString;
    _proteinController.text = eatsJournalQuickEntryEditScreenViewModel.protein.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalQuickEntryEditScreenViewModel.protein.value!)
        : OpenEatsJournalStrings.emptyString;
    _saltController.text = eatsJournalQuickEntryEditScreenViewModel.salt.value != null
        ? ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: eatsJournalQuickEntryEditScreenViewModel.salt.value!)
        : OpenEatsJournalStrings.emptyString;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    double inputFieldsWidth = 90;

    return Consumer<EatsJournalQuickEntryEditScreenViewModel>(
      builder: (context, eatsJournalQuickEntryEditScreenViewModel, _) => MainLayout(
        route: OpenEatsJournalStrings.navigatorRouteQuickEntryEdit,
        title: eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
            ? AppLocalizations.of(context)!.add_quick_entry
            : AppLocalizations.of(context)!.edit_quick_entry,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.currentEntryDate,
                    builder: (_, _, _) {
                      return OutlinedButton(
                        onPressed: () async {
                          //for creating entries take value from setting, for editing entries take value from entry
                          DateTime initialDate = eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
                              ? eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value
                              : eatsJournalQuickEntryEditScreenViewModel.quickEntry.entryDate;

                          await _selectDate(
                            eatsJournalQuickEntryEditScreenViewModel: eatsJournalQuickEntryEditScreenViewModel,
                            initialDate: initialDate,
                            context: context,
                          );
                        },
                        style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          ConvertValidate.dateFormatterDisplayLongDateOnly.format(eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.currentMeal,
                    builder: (_, _, _) {
                      //for creating entries take value from setting, for editing entries take value from entry
                      int initialSelection = eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
                          ? eatsJournalQuickEntryEditScreenViewModel.currentMeal.value.value
                          : eatsJournalQuickEntryEditScreenViewModel.quickEntry.meal.value;

                      return OpenEatsJournalDropdownMenu<int>(
                        onSelected: (int? mealValue) {
                          eatsJournalQuickEntryEditScreenViewModel.currentMeal.value = Meal.getByValue(mealValue!);
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
                              valueListenable: eatsJournalQuickEntryEditScreenViewModel.name,
                              builder: (_, _, _) {
                                return OpenEatsJournalTextField(
                                  controller: _nameController,
                                  onChanged: (value) {
                                    eatsJournalQuickEntryEditScreenViewModel.name.value = value;
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
                              valueListenable: eatsJournalQuickEntryEditScreenViewModel.nameValid,
                              builder: (_, _, _) {
                                if (!eatsJournalQuickEntryEditScreenViewModel.nameValid.value) {
                                  return Text(
                                    AppLocalizations.of(context)!.input_invalid_value(
                                      AppLocalizations.of(context)!.name_capital,
                                      eatsJournalQuickEntryEditScreenViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                                          ? AppLocalizations.of(context)!.empty
                                          : eatsJournalQuickEntryEditScreenViewModel.name.value,
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
                eatsJournalQuickEntryEditScreenViewModel.quickEntry.id != null
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
                                            entryDate: eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value,
                                            name: eatsJournalQuickEntryEditScreenViewModel.name.value,
                                            kJoule: eatsJournalQuickEntryEditScreenViewModel.energy.value != null
                                                ? ConvertValidate.getEnergyKJ(displayEnergy: eatsJournalQuickEntryEditScreenViewModel.energy.value!)
                                                : 1,
                                            meal: eatsJournalQuickEntryEditScreenViewModel.currentMeal.value,
                                            amount: eatsJournalQuickEntryEditScreenViewModel.amount.value,
                                            amountMeasurementUnit: eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value,
                                            carbohydrates: eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value,
                                            sugar: eatsJournalQuickEntryEditScreenViewModel.sugar.value,
                                            fat: eatsJournalQuickEntryEditScreenViewModel.fat.value,
                                            saturatedFat: eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value,
                                            protein: eatsJournalQuickEntryEditScreenViewModel.protein.value,
                                            salt: eatsJournalQuickEntryEditScreenViewModel.salt.value,
                                          ),
                                        )
                                        as EntityEdited?;

                                if (eatsJournalEntryEdited != null) {
                                  _overlayDisplayEatsJournalEntryEdit = OverlayDisplay(
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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.energy,
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
                          eatsJournalQuickEntryEditScreenViewModel.energy.value = intValue;
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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.amount,
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
                          eatsJournalQuickEntryEditScreenViewModel.amount.value = doubleValue;

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
                      listenable: eatsJournalQuickEntryEditScreenViewModel.measurementUnitSwitchButtonChanged,
                      builder: (_, _) {
                        return RoundOutlinedButton(
                          onPressed: () {
                            eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value =
                                eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value == MeasurementUnit.gram
                                ? MeasurementUnit.milliliter
                                : MeasurementUnit.gram;
                          },
                          child: Text(
                            eatsJournalQuickEntryEditScreenViewModel.amountMeasurementUnit.value == MeasurementUnit.gram
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
              valueListenable: eatsJournalQuickEntryEditScreenViewModel.energyValid,
              builder: (_, _, _) {
                if (!eatsJournalQuickEntryEditScreenViewModel.energyValid.value) {
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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.carbohydrates,
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
                          eatsJournalQuickEntryEditScreenViewModel.carbohydrates.value = doubleValue;

                          if (doubleValue != null) {
                            _carbohydratesController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(
                              doubleValue: doubleValue,
                              doubleValueString: value,
                            );
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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.sugar,
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
                          eatsJournalQuickEntryEditScreenViewModel.sugar.value = doubleValue;

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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.fat,
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
                          eatsJournalQuickEntryEditScreenViewModel.fat.value = doubleValue;

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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.saturatedFat,
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
                          eatsJournalQuickEntryEditScreenViewModel.saturatedFat.value = doubleValue;

                          if (doubleValue != null) {
                            _saturatedFatController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(
                              doubleValue: doubleValue,
                              doubleValueString: value,
                            );
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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.protein,
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
                          eatsJournalQuickEntryEditScreenViewModel.protein.value = doubleValue;

                          if (doubleValue != null) {
                            _proteinController.text = ConvertValidate.getCleanDoubleEditString3DecimalDigits(
                              doubleValue: doubleValue,
                              doubleValueString: value,
                            );
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
                    valueListenable: eatsJournalQuickEntryEditScreenViewModel.salt,
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
                          eatsJournalQuickEntryEditScreenViewModel.salt.value = doubleValue as double?;

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
                  int? originalQuickEntryId = eatsJournalQuickEntryEditScreenViewModel.quickEntry.id;

                  if (!(await eatsJournalQuickEntryEditScreenViewModel.setQuickEntry())) {
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
                child: eatsJournalQuickEntryEditScreenViewModel.quickEntry.id == null
                    ? Icon(Icons.add_circle_outline, size: 36)
                    : Icon(Icons.save_alt, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate({
    required EatsJournalQuickEntryEditScreenViewModel eatsJournalQuickEntryEditScreenViewModel,
    required DateTime initialDate,
    required BuildContext context,
  }) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));

    if (date != null) {
      eatsJournalQuickEntryEditScreenViewModel.currentEntryDate.value = date;
    }
  }

  @override
  void dispose() {
    if (_overlayDisplayEatsJournalEntryEdit != null) {
      _overlayDisplayEatsJournalEntryEdit!.stop();
    }

    _animationController.dispose();

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
