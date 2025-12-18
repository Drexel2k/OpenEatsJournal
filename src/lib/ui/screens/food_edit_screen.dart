import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/food_unit.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/object_with_order.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/global_navigator_key.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/main_layout.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/ui/screens/food_edit_screen_viewmodel.dart';
import 'package:openeatsjournal/ui/widgets/food_unit_editor.dart';
import 'package:openeatsjournal/ui/widgets/food_unit_editor_viewmodel.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class FoodEditScreen extends StatelessWidget {
  FoodEditScreen({super.key, required FoodEditScreenViewModel foodEditScreenViewModel}) : _foodEditScreenViewModel = foodEditScreenViewModel;

  final FoodEditScreenViewModel _foodEditScreenViewModel;

  final TextEditingController _nameController = TextEditingController();
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

    _nameController.text = _foodEditScreenViewModel.name.value;
    _gramAmountController.text = _foodEditScreenViewModel.nutritionPerGramAmount.value != null
        ? ConvertValidate.numberFomatterInt.format(_foodEditScreenViewModel.nutritionPerGramAmount.value)
        : OpenEatsJournalStrings.emptyString;
    _milliliterAmountController.text = _foodEditScreenViewModel.nutritionPerMilliliterAmount.value != null
        ? ConvertValidate.numberFomatterInt.format(_foodEditScreenViewModel.nutritionPerMilliliterAmount.value)
        : OpenEatsJournalStrings.emptyString;
    _kCalController.text = ConvertValidate.numberFomatterInt.format(
      NutritionCalculator.getKCalsFromKJoules(kJoules: _foodEditScreenViewModel.kJoule.value as int),
    );

    double inputFieldsWidth = 90;

    return MainLayout(
      route: OpenEatsJournalStrings.navigatorRouteFoodEdit,
      title: AppLocalizations.of(context)!.edit_food,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [Expanded(child: Text(AppLocalizations.of(context)!.name_capital, style: textTheme.titleSmall))],
          ),

          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _foodEditScreenViewModel.name,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _nameController,
                      onChanged: (value) {
                        _foodEditScreenViewModel.name.value = value;
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
                  valueListenable: _foodEditScreenViewModel.nameValid,
                  builder: (_, _, _) {
                    if (!_foodEditScreenViewModel.nameValid.value) {
                      return Text(
                        AppLocalizations.of(context)!.input_invalid(
                          AppLocalizations.of(context)!.name_capital,
                          _foodEditScreenViewModel.name.value.trim() == OpenEatsJournalStrings.emptyString
                              ? AppLocalizations.of(context)!.empty
                              : _foodEditScreenViewModel.name.value,
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
                  valueListenable: _foodEditScreenViewModel.nutritionPerGramAmount,
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
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _foodEditScreenViewModel.nutritionPerGramAmount.value = doubleValue;

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
                  valueListenable: _foodEditScreenViewModel.nutritionPerMilliliterAmount,
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
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _foodEditScreenViewModel.nutritionPerMilliliterAmount.value = doubleValue;

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
            valueListenable: _foodEditScreenViewModel.amountsValid,
            builder: (_, _, _) {
              if (!_foodEditScreenViewModel.amountsValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.gram_milliliter, AppLocalizations.of(context)!.nothing),
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
                  valueListenable: _foodEditScreenViewModel.kJoule,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _kCalController,
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        int? intValue = int.tryParse(value);
                        _foodEditScreenViewModel.kJoule.value = intValue != null ? NutritionCalculator.getKJoulesFromKCals(kCals: intValue) : null;
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
            valueListenable: _foodEditScreenViewModel.kJouleValid,
            builder: (_, _, _) {
              if (!_foodEditScreenViewModel.kJouleValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.kjoule, AppLocalizations.of(context)!.nothing),
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
                  valueListenable: _foodEditScreenViewModel.carbohydrates,
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
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _foodEditScreenViewModel.carbohydrates.value = doubleValue;

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
                  valueListenable: _foodEditScreenViewModel.sugar,
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
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _foodEditScreenViewModel.sugar.value = doubleValue;

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
                  valueListenable: _foodEditScreenViewModel.fat,
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
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _foodEditScreenViewModel.fat.value = doubleValue;

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
                  valueListenable: _foodEditScreenViewModel.saturatedFat,
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
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _foodEditScreenViewModel.saturatedFat.value = doubleValue;

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
                  valueListenable: _foodEditScreenViewModel.protein,
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
                      onChanged: (value) {
                        double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                        _foodEditScreenViewModel.protein.value = doubleValue;

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
                  valueListenable: _foodEditScreenViewModel.salt,
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
                      onChanged: (value) {
                        num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value);
                        _foodEditScreenViewModel.salt.value = doubleValue as double?;

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
                    _foodEditScreenViewModel.addFoddUnit(
                      measurementUnit: _foodEditScreenViewModel.nutritionPerGramAmount.value != null
                          ? MeasurementUnit.gram
                          : _foodEditScreenViewModel.nutritionPerMilliliterAmount.value != null
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
                valueListenable: _foodEditScreenViewModel.foodUnitsEditMode,
                builder: (_, _, _) {
                  if (_foodEditScreenViewModel.foodUnitsEditMode.value) {
                    return RoundOutlinedButton(
                      onPressed: () {
                        _foodEditScreenViewModel.foodUnitsEditMode.value = false;
                        _foodEditScreenViewModel.reorderableStateChanged.notify();
                      },
                      child: Icon(Icons.swap_vert),
                    );
                  } else {
                    return RoundOutlinedButton(
                      onPressed: () {
                        _foodEditScreenViewModel.foodUnitsEditMode.value = true;
                        _foodEditScreenViewModel.reorderableStateChanged.notify();
                      },
                      child: Icon(Icons.mode_edit),
                    );
                  }
                },
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: _foodEditScreenViewModel.foodUnitsCopyValid,
            builder: (_, _, _) {
              if (!_foodEditScreenViewModel.foodUnitsCopyValid.value) {
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
              listenable: _foodEditScreenViewModel.reorderableStateChanged,
              builder: (_, _) {
                return ReorderableListView(
                  buildDefaultDragHandles: !_foodEditScreenViewModel.foodUnitsEditMode.value,
                  onReorder: (oldIndex, newIndex) {
                    _foodEditScreenViewModel.reorder(oldIndex, newIndex);
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
                  int? originalFoodId = _foodEditScreenViewModel.foodId;
                  if (!(await _foodEditScreenViewModel.createFood())) {
                    SnackBar snackBar = SnackBar(
                      content: Text(AppLocalizations.of(navigatorKey.currentContext!)!.cant_create_food),
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
                      content: originalFoodId == null
                          ? Text(AppLocalizations.of(navigatorKey.currentContext!)!.food_created)
                          : Text(AppLocalizations.of(navigatorKey.currentContext!)!.food_updated),
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
                child: _foodEditScreenViewModel.foodId == null ? Text(AppLocalizations.of(context)!.create) : Text(AppLocalizations.of(context)!.update),
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
    for (ObjectWithOrder<FoodUnit> foodUnitWithOrder in _foodEditScreenViewModel.foodFoodUnitsWithOrderCopy) {
      foodUnitEditors.add(
        FoodUnitEditor(
          key: Key("$index"),
          foodUnitEditorViewModel: _foodEditScreenViewModel.foodUnitEditorViewModels.firstWhere(
            (FoodUnitEditorViewModel foodUnitEditorViewModel) => foodUnitEditorViewModel.foodUnit == foodUnitWithOrder.object,
          ),
        ),
      );

      index++;
    }

    return foodUnitEditors;
  }
}
