import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class OnboardingScreenPage3 extends StatelessWidget {
  OnboardingScreenPage3({super.key, required OnboardingScreenViewModel onboardingScreenViewModel, required VoidCallback onDone})
    : _onboardingScreenViewModel = onboardingScreenViewModel,
      _onDone = onDone,
      _birthDayController = TextEditingController();

  final OnboardingScreenViewModel _onboardingScreenViewModel;
  final VoidCallback _onDone;
  final TextEditingController _birthDayController;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(AppLocalizations.of(context)!.your_gender, style: textTheme.titleSmall)),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.gender,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        icon: Icons.male,
                        label: AppLocalizations.of(contextBuilder)!.male,
                        selected: _onboardingScreenViewModel.gender.value == Gender.male,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.gender.value = Gender.male;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.gender,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        icon: Icons.female,
                        label: AppLocalizations.of(contextBuilder)!.female,
                        selected: _onboardingScreenViewModel.gender.value == Gender.femail,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.gender.value = Gender.femail;
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
            Expanded(child: Text(AppLocalizations.of(context)!.your_birthday, style: textTheme.titleSmall)),
            Flexible(
              child: Align(
                alignment: Alignment.topLeft,
                child: SettingsTextField(
                  controller: _birthDayController,
                  onTap: () {
                    _selectDate(initialDate: _onboardingScreenViewModel.birthday.value ?? DateTime.now(), context: context);
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
            Expanded(child: Text(AppLocalizations.of(context)!.your_height, style: textTheme.titleSmall)),
            Flexible(
              child: Align(
                alignment: Alignment.topLeft,
                child: ValueListenableBuilder(
                  valueListenable: _onboardingScreenViewModel.height,
                  builder: (_, _, _) {
                    return SettingsTextField(
                      keyboardType: TextInputType.numberWithOptions(signed: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text.trim();
                          if (text.isEmpty) {
                            return newValue;
                          }

                          int? intValue = int.tryParse(text);
                          if (intValue != null) {
                            return newValue;
                          } else {
                            return oldValue;
                          }
                        }),
                      ],
                      onChanged: (value) {
                        _onboardingScreenViewModel.height.value = int.tryParse(value);
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
            Expanded(child: Text(AppLocalizations.of(context)!.your_weight, style: textTheme.titleSmall)),
            Flexible(
              child: Align(
                alignment: Alignment.topLeft,
                child: ValueListenableBuilder(
                  valueListenable: _onboardingScreenViewModel.weight,
                  builder: (_, _, _) {
                    return SettingsTextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                      inputFormatters: [
                        //if filter is not matched, the value is set to empty string
                        //which feels strange in the ui
                        //FilteringTextInputFormatter.allow(RegExp(weightRegExp)),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text.trim();
                          if (text.isEmpty) {
                            return newValue;
                          }

                          double? doubleValue = double.tryParse(text);
                          if (doubleValue != null) {
                            return newValue;
                          } else {
                            return oldValue;
                          }
                        }),
                      ],
                      onChanged: (value) {
                        double? doubleValue = double.tryParse(value);
                        _onboardingScreenViewModel.weight.value = doubleValue;
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.your_acitivty_level, style: textTheme.titleSmall),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.very_low,
                        selected: _onboardingScreenViewModel.activityFactor.value == 1.2,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.activityFactor.value = 1.2;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.low,
                        selected: _onboardingScreenViewModel.activityFactor.value == 1.4,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.activityFactor.value = 1.4;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.medium,
                        selected: _onboardingScreenViewModel.activityFactor.value == 1.6,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.activityFactor.value = 1.6;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.high,
                        selected: _onboardingScreenViewModel.activityFactor.value == 1.8,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.activityFactor.value = 1.8;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.very_high,
                        selected: _onboardingScreenViewModel.activityFactor.value == 2.1,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.activityFactor.value = 2.1;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.activityFactor,
                    builder: (contextBuilder, _, _) {
                      return TransparentChoiceChip(
                        label: AppLocalizations.of(contextBuilder)!.professional_athlete,
                        selected: _onboardingScreenViewModel.activityFactor.value == 2.4,
                        onSelected: (bool selected) {
                          _onboardingScreenViewModel.activityFactor.value = 2.4;
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
              if (_onboardingScreenViewModel.gender.value == null) {
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

              if (_onboardingScreenViewModel.birthday.value == null) {
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

              if (_onboardingScreenViewModel.height.value == null ||
                  _onboardingScreenViewModel.height.value! <= 0 ||
                  _onboardingScreenViewModel.height.value! > 999) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.valid_height),
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

              if (_onboardingScreenViewModel.weight.value == null ||
                  _onboardingScreenViewModel.weight.value! <= 0 ||
                  _onboardingScreenViewModel.weight.value! > 999) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.valid_weight),
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

              if (_onboardingScreenViewModel.activityFactor.value == null) {
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
              _onboardingScreenViewModel.weightTarget.value = WeightTarget.keep;
              _onDone();
            },

            child: Text(AppLocalizations.of(context)!.proceed),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime.now());

    if (date != null) {
      _birthDayController.text = ConvertValidate.dateFormatterDisplayLongDateOnly.format(date);
      _onboardingScreenViewModel.birthday.value = date;
    }
  }
}
