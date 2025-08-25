import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";
import "package:openeatsjournal/ui/utils/convert_validate.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class OnboardingScreenPage3 extends StatelessWidget {
  OnboardingScreenPage3({super.key, required OnboardingViewModel onboardingViewModel, required VoidCallback onDone})
    : _onboardingViewModel = onboardingViewModel,
      _onDone = onDone,
      _birthDayController = TextEditingController();

  final OnboardingViewModel _onboardingViewModel;
  final VoidCallback _onDone;
  final TextEditingController _birthDayController;

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String decimalSeparator = NumberFormat.decimalPattern(languageCode).symbols.DECIMAL_SEP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_gender, style: textTheme.titleMedium)),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.gender,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        icon: Icons.male,
                        label: AppLocalizations.of(contextBuilder)!.male,
                        selected: _onboardingViewModel.gender.value == Gender.male,
                        onSelected: (bool selected) {
                          _onboardingViewModel.gender.value = Gender.male;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.gender,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        icon: Icons.female,
                        label: AppLocalizations.of(contextBuilder)!.female,
                        selected: _onboardingViewModel.gender.value == Gender.femail,
                        onSelected: (bool selected) {
                          _onboardingViewModel.gender.value = Gender.femail;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_birthday, style: textTheme.titleMedium)),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: SettingsTextField(
                  controller: _birthDayController,
                  onTap: () {
                    _selectDate(initialDate: _onboardingViewModel.birthday.value ?? DateTime.now(), context: context);
                  },
                  readOnly: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_height, style: textTheme.titleMedium)),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: ValueListenableBuilder(
                  valueListenable: _onboardingViewModel.height,
                  builder: (_, _, _) {
                    return SettingsTextField(
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text.trim();
                          return text.isEmpty
                              ? newValue
                              : text.length <= 3
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        _onboardingViewModel.height.value = int.tryParse(value);
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
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.your_weight, style: textTheme.titleMedium)),
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.topLeft,
                child: ValueListenableBuilder(
                  valueListenable: _onboardingViewModel.weight,
                  builder: (_, _, _) {
                    return SettingsTextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                      inputFormatters: [
                        //if filter is not matched, the value is set to empty string
                        //which feels strange in the ui
                        //FilteringTextInputFormatter.allow(RegExp(weightRegExp)),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text.trim();
                          return text.isEmpty
                              ? newValue
                              : ConvertValidate.validateWeight(weight: text, decimalSeparator: decimalSeparator)
                              ? newValue
                              : oldValue;
                        }),
                      ],
                      onChanged: (value) {
                        double? weightNum = ConvertValidate.convertLocalStringToDouble(
                          numberString: value,
                          languageCode: languageCode,
                        );
                        _onboardingViewModel.weight.value = weightNum;
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.your_acitivty_level, style: textTheme.titleMedium),
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: Duration(seconds: 60),
                    message: AppLocalizations.of(context)!.acitivity_level_explanation,
                    child: Icon(Icons.help_outline),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.very_low,
                        selected: _onboardingViewModel.activityFactor.value == 1.2,
                        onSelected: (bool selected) {
                          _onboardingViewModel.activityFactor.value = 1.2;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.low,
                        selected: _onboardingViewModel.activityFactor.value == 1.4,
                        onSelected: (bool selected) {
                          _onboardingViewModel.activityFactor.value = 1.4;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.medium,
                        selected: _onboardingViewModel.activityFactor.value == 1.6,
                        onSelected: (bool selected) {
                          _onboardingViewModel.activityFactor.value = 1.6;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.high,
                        selected: _onboardingViewModel.activityFactor.value == 1.8,
                        onSelected: (bool selected) {
                          _onboardingViewModel.activityFactor.value = 1.8;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.very_high,
                        selected: _onboardingViewModel.activityFactor.value == 2.1,
                        onSelected: (bool selected) {
                          _onboardingViewModel.activityFactor.value = 2.1;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.professional_athlete,
                        selected: _onboardingViewModel.activityFactor.value == 2.4,
                        onSelected: (bool selected) {
                          _onboardingViewModel.activityFactor.value = 2.4;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Spacer(),
        Center(
          child: FilledButton(
            onPressed: () {
              if (_onboardingViewModel.gender.value == null) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.select_gender),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.close,
                    onPressed: () {
                      //Click on SnackbarAction closes the SnackBar,
                      //nothing else to do here...
                    },
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              if (_onboardingViewModel.birthday.value == null) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.select_birthday),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.close,
                    onPressed: () {
                      //Click on SnackbarAction closes the SnackBar,
                      //nothing else to do here...
                    },
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              if (_onboardingViewModel.height.value == null || _onboardingViewModel.height.value! <= 0) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.select_height),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.close,
                    onPressed: () {
                      //Click on SnackbarAction closes the SnackBar,
                      //nothing else to do here...
                    },
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              if (_onboardingViewModel.weight.value == null || _onboardingViewModel.weight.value! <= 0) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.select_weight),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.close,
                    onPressed: () {
                      //Click on SnackbarAction closes the SnackBar,
                      //nothing else to do here...
                    },
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              if (_onboardingViewModel.activityFactor.value == null) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.select_activity_level),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.close,
                    onPressed: () {
                      //Click on SnackbarAction closes the SnackBar,
                      //nothing else to do here...
                    },
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                return;
              }

              //is initially null, a change triggers calculation of needed and target
              //kcals which are displayed on next page.
              _onboardingViewModel.weightTarget.value = WeightTarget.keep;
              _onDone();
            },

            child: Text(AppLocalizations.of(context)!.proceed),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    final String languageCode = Localizations.localeOf(context).toString();

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _birthDayController.text = DateFormat.yMMMMd(languageCode).format(date);
      _onboardingViewModel.birthday.value = date;
    }
  }
}
