import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/gender.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class OnboardingScreenPage3 extends StatefulWidget {
  const OnboardingScreenPage3({super.key, required OnboardingScreenViewModel onboardingScreenViewModel, required VoidCallback onDone})
    : _onboardingScreenViewModel = onboardingScreenViewModel,
      _onDone = onDone;

  final OnboardingScreenViewModel _onboardingScreenViewModel;
  final VoidCallback _onDone;

  @override
  State<OnboardingScreenPage3> createState() => _OnboardingScreenPage3State();
}

class _OnboardingScreenPage3State extends State<OnboardingScreenPage3> {
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _birthDayController.text = widget._onboardingScreenViewModel.birthday.value != null
        ? ConvertValidate.dateFormatterDisplayMediumDateOnly.format(widget._onboardingScreenViewModel.birthday.value!)
        : OpenEatsJournalStrings.emptyString;
    _heightController.text = widget._onboardingScreenViewModel.height.value != null
        ? ConvertValidate.numberFomatterInt.format(widget._onboardingScreenViewModel.height.value!)
        : OpenEatsJournalStrings.emptyString;
    _weightController.text = widget._onboardingScreenViewModel.weight.value != null
        ? ConvertValidate.getCleanDoubleString(doubleValue: widget._onboardingScreenViewModel.weight.value!)
        : OpenEatsJournalStrings.emptyString;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.859),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                          valueListenable: widget._onboardingScreenViewModel.gender,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              icon: Icons.male,
                              label: AppLocalizations.of(contextBuilder)!.male,
                              selected: widget._onboardingScreenViewModel.gender.value == Gender.male,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.gender.value = Gender.male;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: widget._onboardingScreenViewModel.gender,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              icon: Icons.female,
                              label: AppLocalizations.of(contextBuilder)!.female,
                              selected: widget._onboardingScreenViewModel.gender.value == Gender.female,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.gender.value = Gender.female;
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
                        onTap: () async {
                          await _selectDate(initialDate: widget._onboardingScreenViewModel.birthday.value ?? DateTime.now(), context: context);
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
                        valueListenable: widget._onboardingScreenViewModel.height,
                        builder: (_, _, _) {
                          return SettingsTextField(
                            controller: _heightController,
                            keyboardType: TextInputType.numberWithOptions(signed: false),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onTap: () {
                              _heightController.selection = TextSelection(baseOffset: 0, extentOffset: _heightController.text.length);
                            },
                            onChanged: (value) {
                              int? intValue = int.tryParse(value);
                              widget._onboardingScreenViewModel.height.value = intValue;
                              if (intValue != null) {
                                _heightController.text = ConvertValidate.numberFomatterInt.format(intValue);
                              }
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
                        valueListenable: widget._onboardingScreenViewModel.weight,
                        builder: (_, _, _) {
                          return SettingsTextField(
                            controller: _weightController,
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
                              _weightController.selection = TextSelection(baseOffset: 0, extentOffset: _weightController.text.length);
                            },
                            onChanged: (value) {
                              double? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value) as double?;
                              widget._onboardingScreenViewModel.weight.value = doubleValue;

                              if (doubleValue != null) {
                                _weightController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                              }
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
                          valueListenable: widget._onboardingScreenViewModel.activityFactor,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              label: AppLocalizations.of(contextBuilder)!.very_low,
                              selected: widget._onboardingScreenViewModel.activityFactor.value == 1.2,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.activityFactor.value = 1.2;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: widget._onboardingScreenViewModel.activityFactor,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              label: AppLocalizations.of(contextBuilder)!.low,
                              selected: widget._onboardingScreenViewModel.activityFactor.value == 1.4,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.activityFactor.value = 1.4;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: widget._onboardingScreenViewModel.activityFactor,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              label: AppLocalizations.of(contextBuilder)!.medium,
                              selected: widget._onboardingScreenViewModel.activityFactor.value == 1.6,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.activityFactor.value = 1.6;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: widget._onboardingScreenViewModel.activityFactor,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              label: AppLocalizations.of(contextBuilder)!.high,
                              selected: widget._onboardingScreenViewModel.activityFactor.value == 1.8,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.activityFactor.value = 1.8;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: widget._onboardingScreenViewModel.activityFactor,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              label: AppLocalizations.of(contextBuilder)!.very_high,
                              selected: widget._onboardingScreenViewModel.activityFactor.value == 2.1,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.activityFactor.value = 2.1;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: widget._onboardingScreenViewModel.activityFactor,
                          builder: (contextBuilder, _, _) {
                            return TransparentChoiceChip(
                              label: AppLocalizations.of(contextBuilder)!.professional_athlete,
                              selected: widget._onboardingScreenViewModel.activityFactor.value == 2.4,
                              onSelected: (bool selected) {
                                widget._onboardingScreenViewModel.activityFactor.value = 2.4;
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
                    if (widget._onboardingScreenViewModel.gender.value == null) {
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

                    if (widget._onboardingScreenViewModel.birthday.value == null) {
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

                    if (widget._onboardingScreenViewModel.height.value == null ||
                        widget._onboardingScreenViewModel.height.value! <= 0 ||
                        widget._onboardingScreenViewModel.height.value! > 999) {
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

                    if (widget._onboardingScreenViewModel.weight.value == null ||
                        widget._onboardingScreenViewModel.weight.value! <= 0 ||
                        widget._onboardingScreenViewModel.weight.value! > 999) {
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

                    if (widget._onboardingScreenViewModel.activityFactor.value == null) {
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

                    widget._onDone();
                  },

                  child: Text(AppLocalizations.of(context)!.proceed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    DateTime? date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime.now());

    if (date != null) {
      _birthDayController.text = ConvertValidate.dateFormatterDisplayMediumDateOnly.format(date);
      widget._onboardingScreenViewModel.birthday.value = date;
    }
  }

  @override
  void dispose() {
    _birthDayController.dispose();

    super.dispose();
  }
}
