import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/food_unit.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/object_with_order.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/app_global.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/main_layout.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/ui/screens/food_edit_screen_viewmodel.dart';
import 'package:openeatsjournal/ui/widgets/food_unit_editor.dart';
import 'package:openeatsjournal/ui/widgets/food_unit_editor_viewmodel.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class FoodEditScreen extends StatefulWidget {
  const FoodEditScreen({super.key, required FoodEditScreenViewModel foodEditScreenViewModel}) : _foodEditScreenViewModel = foodEditScreenViewModel;

  final FoodEditScreenViewModel _foodEditScreenViewModel;

  @override
  State<FoodEditScreen> createState() => _FoodEditScreenState();
}

class _FoodEditScreenState extends State<FoodEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _gramAmountController = TextEditingController();
  final TextEditingController _milliliterAmountController = TextEditingController();
  final TextEditingController _kCalController = TextEditingController();
  final TextEditingController _carbohydratesController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _saturatedFatController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _saltController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _nameController.text = widget._foodEditScreenViewModel.name.value;
    _barcodeController.text = widget._foodEditScreenViewModel.barcode.value != null
        ? "${widget._foodEditScreenViewModel.barcode.value}"
        : OpenEatsJournalStrings.emptyString;
    _gramAmountController.text = widget._foodEditScreenViewModel.nutritionPerGramAmount.value != null
        ? ConvertValidate.getCleanDoubleString(doubleValue: widget._foodEditScreenViewModel.nutritionPerGramAmount.value!)
        : OpenEatsJournalStrings.emptyString;
    _milliliterAmountController.text = widget._foodEditScreenViewModel.nutritionPerMilliliterAmount.value != null
        ? ConvertValidate.getCleanDoubleString(doubleValue: widget._foodEditScreenViewModel.nutritionPerMilliliterAmount.value!)
        : OpenEatsJournalStrings.emptyString;
    _kCalController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: widget._foodEditScreenViewModel.kJoule.value!),
    );

    double inputFieldsWidth = 90;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFoodEdit,
      title: AppLocalizations.of(context)!.edit_food,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.basics, style: textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(children: [Text(AppLocalizations.of(context)!.name_label, style: textTheme.titleSmall)]),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: widget._foodEditScreenViewModel.name,
                            builder: (_, _, _) {
                              return OpenEatsJournalTextField(
                                controller: _nameController,
                                onChanged: (value) {
                                  widget._foodEditScreenViewModel.name.value = value;
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                    Row(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: widget._foodEditScreenViewModel.nameValid,
                          builder: (_, _, _) {
                            if (!widget._foodEditScreenViewModel.nameValid.value) {
                              return Text(
                                AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.name_capital),
                                style: textTheme.labelMedium!.copyWith(color: Colors.red),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(children: [Text(AppLocalizations.of(context)!.barcode, style: textTheme.titleSmall)]),
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: widget._foodEditScreenViewModel.barcode,
                            builder: (_, _, _) {
                              return OpenEatsJournalTextField(
                                controller: _barcodeController,
                                keyboardType: TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (value) {
                                  int? intValue = int.tryParse(value);
                                  widget._foodEditScreenViewModel.barcode.value = intValue;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(thickness: 2, height: 20),
          Text(AppLocalizations.of(context)!.amount_for_nutrition_values, style: textTheme.titleMedium),
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)!.gram, style: textTheme.titleSmall)),
              Expanded(child: Text(AppLocalizations.of(context)!.milliliter, style: textTheme.titleSmall)),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._foodEditScreenViewModel.nutritionPerGramAmount,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _gramAmountController,
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
                        _gramAmountController.selection = TextSelection(baseOffset: 0, extentOffset: _gramAmountController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._foodEditScreenViewModel.nutritionPerGramAmount.value = doubleValue;

                        if (doubleValue != null) {
                          _gramAmountController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
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
                  valueListenable: widget._foodEditScreenViewModel.nutritionPerMilliliterAmount,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _milliliterAmountController,
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
                        _milliliterAmountController.selection = TextSelection(baseOffset: 0, extentOffset: _milliliterAmountController.text.length);
                      },
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        widget._foodEditScreenViewModel.nutritionPerMilliliterAmount.value = doubleValue;

                        if (doubleValue != null) {
                          _milliliterAmountController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(child: SizedBox(height: 0)),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widget._foodEditScreenViewModel.amountsValid,
            builder: (_, _, _) {
              if (!widget._foodEditScreenViewModel.amountsValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.gram_milliliter),
                  style: textTheme.labelMedium!.copyWith(color: Colors.red),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          Divider(thickness: 2, height: 20),
          Text(AppLocalizations.of(context)!.nutrition_values, style: textTheme.titleMedium),
          Row(
            children: [Expanded(child: Text(AppLocalizations.of(context)!.kcal_label, style: textTheme.titleSmall))],
          ),
          Row(
            children: [
              SizedBox(
                width: inputFieldsWidth,
                child: ValueListenableBuilder(
                  valueListenable: widget._foodEditScreenViewModel.kJoule,
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
                        widget._foodEditScreenViewModel.kJoule.value = intValue != null ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue) : null;
                        if (intValue != null) {
                          _kCalController.text = ConvertValidate.numberFomatterInt.format(intValue);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widget._foodEditScreenViewModel.kJouleValid,
            builder: (_, _, _) {
              if (!widget._foodEditScreenViewModel.kJouleValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.kjoule),
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
                  valueListenable: widget._foodEditScreenViewModel.carbohydrates,
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
                        widget._foodEditScreenViewModel.carbohydrates.value = doubleValue;

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
                  valueListenable: widget._foodEditScreenViewModel.sugar,
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
                        widget._foodEditScreenViewModel.sugar.value = doubleValue;

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
                  valueListenable: widget._foodEditScreenViewModel.fat,
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
                        widget._foodEditScreenViewModel.fat.value = doubleValue;

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
                  valueListenable: widget._foodEditScreenViewModel.saturatedFat,
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
                        widget._foodEditScreenViewModel.saturatedFat.value = doubleValue;

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
                  valueListenable: widget._foodEditScreenViewModel.protein,
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
                        widget._foodEditScreenViewModel.protein.value = doubleValue;

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
                  valueListenable: widget._foodEditScreenViewModel.salt,
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
                        widget._foodEditScreenViewModel.salt.value = doubleValue as double?;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(AppLocalizations.of(context)!.food_units, style: textTheme.titleMedium),
              Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                child: RoundOutlinedButton(
                  onPressed: () {
                    widget._foodEditScreenViewModel.addFoddUnit(
                      measurementUnit: widget._foodEditScreenViewModel.nutritionPerGramAmount.value != null
                          ? MeasurementUnit.gram
                          : widget._foodEditScreenViewModel.nutritionPerMilliliterAmount.value != null
                          ? MeasurementUnit.milliliter
                          : MeasurementUnit.gram,
                    );

                    //Jump to end after rendering the ListView, see comment below.
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    });

                    //ListView ist not rendered here, so maxScrollExtent is the value before adding the new item and the list view is only scrolled to the item
                    //before the last item.
                    //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  },
                  child: Icon(Icons.add),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: widget._foodEditScreenViewModel.foodUnitsEditMode,
                builder: (_, _, _) {
                  if (widget._foodEditScreenViewModel.foodUnitsEditMode.value) {
                    return RoundOutlinedButton(
                      onPressed: () {
                        widget._foodEditScreenViewModel.foodUnitsEditMode.value = false;
                        widget._foodEditScreenViewModel.reorderableStateChanged.notify();
                      },
                      child: Icon(Icons.swap_vert),
                    );
                  } else {
                    return RoundOutlinedButton(
                      onPressed: () {
                        widget._foodEditScreenViewModel.foodUnitsEditMode.value = true;
                        widget._foodEditScreenViewModel.reorderableStateChanged.notify();
                      },
                      child: Icon(Icons.mode_edit),
                    );
                  }
                },
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widget._foodEditScreenViewModel.foodUnitsCopyValid,
            builder: (_, _, _) {
              if (!widget._foodEditScreenViewModel.foodUnitsCopyValid.value) {
                return Text(AppLocalizations.of(context)!.food_units_invalid, style: textTheme.labelMedium!.copyWith(color: Colors.red));
              } else {
                return SizedBox();
              }
            },
          ),
          Row(
            children: [
              SizedBox(width: 30),
              Expanded(child: Text(AppLocalizations.of(context)!.name_capital, style: textTheme.titleSmall)),
              SizedBox(width: 66, child: Text(AppLocalizations.of(context)!.amount_abbreviated, style: textTheme.titleSmall)),
              SizedBox(
                width: 44,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(AppLocalizations.of(context)!.unit_abbreviated, style: textTheme.titleSmall),
                ),
              ),
              SizedBox(
                width: 57,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(AppLocalizations.of(context)!.default_abbreviated, style: textTheme.titleSmall),
                ),
              ),
              SizedBox(
                width: 45,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Text(AppLocalizations.of(context)!.delete_abbreviated, style: textTheme.titleSmall),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget._foodEditScreenViewModel.reorderableStateChanged,
              builder: (_, _) {
                return ReorderableListView(
                  buildDefaultDragHandles: !widget._foodEditScreenViewModel.foodUnitsEditMode.value,
                  onReorder: (oldIndex, newIndex) {
                    widget._foodEditScreenViewModel.reorder(oldIndex, newIndex);
                  },
                  scrollController: _scrollController,
                  children: _getFoodUnitEditors(textTheme: textTheme, context: context),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: AlignmentGeometry.center,
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () async {
                  int? originalFoodId = widget._foodEditScreenViewModel.foodId;
                  if (!(await widget._foodEditScreenViewModel.saveFood())) {
                    SnackBar snackBar = SnackBar(
                      content: Text(AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.cant_create_food),
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
                      content: originalFoodId == null
                          ? Text(AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_created)
                          : Text(AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_updated),
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
                child: widget._foodEditScreenViewModel.foodId == null ? Text(AppLocalizations.of(context)!.create) : Text(AppLocalizations.of(context)!.update),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getFoodUnitEditors({required TextTheme textTheme, required BuildContext context}) {
    List<Widget> foodUnitEditors = [];

    int index = 0;
    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in widget._foodEditScreenViewModel.foodFoodUnitsWithOrderCopy) {
      foodUnitEditors.add(
        FoodUnitEditor(
          key: Key("$index"),
          foodUnitEditorViewModel: widget._foodEditScreenViewModel.foodUnitEditorViewModels.firstWhere(
            (FoodUnitEditorViewModel foodUnitEditorViewModel) => foodUnitEditorViewModel.foodUnit == foodUnitWithOrder.object,
          ),
        ),
      );

      index++;
    }

    return foodUnitEditors;
  }

  @override
  void dispose() {
    widget._foodEditScreenViewModel.dispose();
    _nameController.dispose();
    _barcodeController.dispose();
    _gramAmountController.dispose();
    _milliliterAmountController.dispose();
    _kCalController.dispose();
    _carbohydratesController.dispose();
    _sugarController.dispose();
    _fatController.dispose();
    _saturatedFatController.dispose();
    _proteinController.dispose();
    _saltController.dispose();

    _scrollController.dispose();

    super.dispose();
  }
}
