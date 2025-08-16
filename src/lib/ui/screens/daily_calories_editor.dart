import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/kcal_settings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/daily_calories_editor_viewmodel.dart";
import "package:openeatsjournal/ui/utils/convert_validate.dart";
import "package:openeatsjournal/ui/utils/debouncer.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";

class DailyCaloriesEditor extends StatelessWidget {
  DailyCaloriesEditor({
    super.key,
    required DailyCaloriesEditorViewModel dailyCaloriesEditorViewModel,
    required int dailyCalories,
    required int originalDailyWeightLossCalories,
  }) : _dailyCaloriesEditorViewModel = dailyCaloriesEditorViewModel,
       _dailyCalories = dailyCalories,
       _originalDailyWeightLossCalories = originalDailyWeightLossCalories,
       _kCalMondayController = TextEditingController(),
       _kCalTuesdayController = TextEditingController(),
       _kCalWednesdayController = TextEditingController(),
       _kCalThursdayController = TextEditingController(),
       _kCalFridayController = TextEditingController(),
       _kCalSaturdayController = TextEditingController(),
       _kCalSundayController = TextEditingController();

  final DailyCaloriesEditorViewModel _dailyCaloriesEditorViewModel;
  final int _dailyCalories;
  final int _originalDailyWeightLossCalories;
  final TextEditingController _kCalMondayController;
  final TextEditingController _kCalTuesdayController;
  final TextEditingController _kCalWednesdayController;
  final TextEditingController _kCalThursdayController;
  final TextEditingController _kCalFridayController;
  final TextEditingController _kCalSaturdayController;
  final TextEditingController _kCalSundayController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String thousandSeparator = NumberFormat.decimalPattern(
      languageCode,
    ).symbols.GROUP_SEP;

    final NumberFormat formatter = NumberFormat(null, languageCode);

    _kCalMondayController.text = formatter.format(
      _dailyCaloriesEditorViewModel.kCalsMonday.value,
    );
    _kCalTuesdayController.text = formatter.format(
      _dailyCaloriesEditorViewModel.kCalsTuesday.value,
    );
    _kCalWednesdayController.text = formatter.format(
      _dailyCaloriesEditorViewModel.kCalsWednesday.value,
    );
    _kCalThursdayController.text = formatter.format(
      _dailyCaloriesEditorViewModel.kCalsThursday.value,
    );
    _kCalFridayController.text = formatter.format(
      _dailyCaloriesEditorViewModel.kCalsFriday.value,
    );
    _kCalSaturdayController.text = formatter.format(
      _dailyCaloriesEditorViewModel.kCalsSaturday.value,
    );
    _kCalSundayController.text = formatter.format(
      _dailyCaloriesEditorViewModel.kCalsSunday.value,
    );

    final Debouncer kCalMondayDebouncer = Debouncer();
    final Debouncer kCalTuesdayDebouncer = Debouncer();
    final Debouncer kCalWednesdayDebouncer = Debouncer();
    final Debouncer kCalThursdayDebouncer = Debouncer();
    final Debouncer kCalFridayDebouncer = Debouncer();
    final Debouncer kCalSaturdayDebouncer = Debouncer();
    final Debouncer kCalSundayDebouncer = Debouncer();

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.edit_calories_target),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.daily_target_new,
                        style: textTheme.titleMedium,
                      ),
                      Text(
                        AppLocalizations.of(context)!.daily_target_original,
                        style: textTheme.bodySmall,
                      ),
                      Text(
                        AppLocalizations.of(context)!.daily_calories,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _dailyCaloriesEditorViewModel
                                  .kCalsWeightLossDaily,
                              builder: (_, _, _) {
                                return Text(
                                  AppLocalizations.of(context)!.amount_kcal(
                                    formatter.format(
                                      _dailyCaloriesEditorViewModel
                                          .kCalsWeightLossDaily
                                          .value,
                                    ),
                                  ),
                                  style: textTheme.titleMedium,
                                );
                              },
                            ),
                            Text(
                              AppLocalizations.of(context)!.amount_kcal(
                                formatter.format(
                                  _originalDailyWeightLossCalories,
                                ),
                              ),
                              style: textTheme.bodySmall,
                            ),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.amount_kcal(formatter.format(_dailyCalories)),
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.monday_kcals,
                    style: textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SettingsTextField(
                      controller: _kCalMondayController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          return text.isEmpty
                              ? TextEditingValue(text: "1")
                              : ConvertValidate.validateCalories(
                                      kCals: text,
                                      thousandSeparator: thousandSeparator,
                                    ) &&
                                    ConvertValidate.convertLocalStringToDouble(
                                          numberString: text,
                                          languageCode: languageCode,
                                        )! >=
                                        1
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        kCalMondayDebouncer.run(
                          callback: () {
                            _dailyCaloriesEditorViewModel.kCalsMonday.value =
                                ConvertValidate.convertLocalStringToInt(
                                  numberString: value,
                                  languageCode: languageCode,
                                )!;
                            _kCalMondayController.text = formatter.format(
                              _dailyCaloriesEditorViewModel.kCalsMonday.value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.tuesday_kcals,
                    style: textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SettingsTextField(
                      controller: _kCalTuesdayController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          return text.isEmpty
                              ? TextEditingValue(text: "1")
                              : ConvertValidate.validateCalories(
                                      kCals: text,
                                      thousandSeparator: thousandSeparator,
                                    ) &&
                                    ConvertValidate.convertLocalStringToDouble(
                                          numberString: text,
                                          languageCode: languageCode,
                                        )! >=
                                        1
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        kCalTuesdayDebouncer.run(
                          callback: () {
                            _dailyCaloriesEditorViewModel.kCalsTuesday.value =
                                ConvertValidate.convertLocalStringToInt(
                                  numberString: value,
                                  languageCode: languageCode,
                                )!;
                            _kCalTuesdayController.text = formatter.format(
                              _dailyCaloriesEditorViewModel.kCalsTuesday.value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.wednesday_kcals,
                    style: textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SettingsTextField(
                      controller: _kCalWednesdayController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          return text.isEmpty
                              ? TextEditingValue(text: "1")
                              : ConvertValidate.validateCalories(
                                      kCals: text,
                                      thousandSeparator: thousandSeparator,
                                    ) &&
                                    ConvertValidate.convertLocalStringToDouble(
                                          numberString: text,
                                          languageCode: languageCode,
                                        )! >=
                                        1
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        kCalWednesdayDebouncer.run(
                          callback: () {
                            _dailyCaloriesEditorViewModel.kCalsWednesday.value =
                                ConvertValidate.convertLocalStringToInt(
                                  numberString: value,
                                  languageCode: languageCode,
                                )!;
                            _kCalWednesdayController.text = formatter.format(
                              _dailyCaloriesEditorViewModel
                                  .kCalsWednesday
                                  .value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.thursday_kcals,
                    style: textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SettingsTextField(
                      controller: _kCalThursdayController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          return text.isEmpty
                              ? TextEditingValue(text: "1")
                              : ConvertValidate.validateCalories(
                                      kCals: text,
                                      thousandSeparator: thousandSeparator,
                                    ) &&
                                    ConvertValidate.convertLocalStringToDouble(
                                          numberString: text,
                                          languageCode: languageCode,
                                        )! >=
                                        1
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        kCalThursdayDebouncer.run(
                          callback: () {
                            _dailyCaloriesEditorViewModel.kCalsThursday.value =
                                ConvertValidate.convertLocalStringToInt(
                                  numberString: value,
                                  languageCode: languageCode,
                                )!;
                            _kCalThursdayController.text = formatter.format(
                              _dailyCaloriesEditorViewModel.kCalsThursday.value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.friday_kcals,
                    style: textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SettingsTextField(
                      controller: _kCalFridayController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          return text.isEmpty
                              ? TextEditingValue(text: "1")
                              : ConvertValidate.validateCalories(
                                      kCals: text,
                                      thousandSeparator: thousandSeparator,
                                    ) &&
                                    ConvertValidate.convertLocalStringToDouble(
                                          numberString: text,
                                          languageCode: languageCode,
                                        )! >=
                                        1
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        kCalFridayDebouncer.run(
                          callback: () {
                            _dailyCaloriesEditorViewModel.kCalsFriday.value =
                                ConvertValidate.convertLocalStringToInt(
                                  numberString: value,
                                  languageCode: languageCode,
                                )!;
                            _kCalFridayController.text = formatter.format(
                              _dailyCaloriesEditorViewModel.kCalsFriday.value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.saturday_kcals,
                    style: textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SettingsTextField(
                      controller: _kCalSaturdayController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          return text.isEmpty
                              ? TextEditingValue(text: "1")
                              : ConvertValidate.validateCalories(
                                      kCals: text,
                                      thousandSeparator: thousandSeparator,
                                    ) &&
                                    ConvertValidate.convertLocalStringToDouble(
                                          numberString: text,
                                          languageCode: languageCode,
                                        )! >=
                                        1
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        kCalSaturdayDebouncer.run(
                          callback: () {
                            _dailyCaloriesEditorViewModel.kCalsSaturday.value =
                                ConvertValidate.convertLocalStringToInt(
                                  numberString: value,
                                  languageCode: languageCode,
                                )!;
                            _kCalSaturdayController.text = formatter.format(
                              _dailyCaloriesEditorViewModel.kCalsSaturday.value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.sunday_kcals,
                    style: textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SettingsTextField(
                      controller: _kCalSundayController,
                      keyboardType: TextInputType.numberWithOptions(
                        signed: false,
                      ),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text;
                          return text.isEmpty
                              ? TextEditingValue(text: "1")
                              : ConvertValidate.validateCalories(
                                      kCals: text,
                                      thousandSeparator: thousandSeparator,
                                    ) &&
                                    ConvertValidate.convertLocalStringToDouble(
                                          numberString: text,
                                          languageCode: languageCode,
                                        )! >=
                                        1
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        kCalSundayDebouncer.run(
                          callback: () {
                            _dailyCaloriesEditorViewModel.kCalsSunday.value =
                                ConvertValidate.convertLocalStringToInt(
                                  numberString: value,
                                  languageCode: languageCode,
                                )!;
                            _kCalSundayController.text = formatter.format(
                              _dailyCaloriesEditorViewModel.kCalsSunday.value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.ok),

          onPressed: () {
            KCalSettings kCalSettings = KCalSettings(
              kCalsMonday: ConvertValidate.convertLocalStringToInt(
                numberString: _kCalMondayController.text,
                languageCode: languageCode,
              )!,
              kCalsTuesday: ConvertValidate.convertLocalStringToInt(
                numberString: _kCalTuesdayController.text,
                languageCode: languageCode,
              )!,
              kCalsWednesday: ConvertValidate.convertLocalStringToInt(
                numberString: _kCalWednesdayController.text,
                languageCode: languageCode,
              )!,
              kCalsThursday: ConvertValidate.convertLocalStringToInt(
                numberString: _kCalThursdayController.text,
                languageCode: languageCode,
              )!,
              kCalsFriday: ConvertValidate.convertLocalStringToInt(
                numberString: _kCalFridayController.text,
                languageCode: languageCode,
              )!,
              kCalsSaturday: ConvertValidate.convertLocalStringToInt(
                numberString: _kCalSaturdayController.text,
                languageCode: languageCode,
              )!,
              kCalsSunday: ConvertValidate.convertLocalStringToInt(
                numberString: _kCalSundayController.text,
                languageCode: languageCode,
              )!,
            );

            Navigator.pop(context, kCalSettings);
          },
        ),
      ],
    );
  }
}
