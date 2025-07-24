import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:openeatsjournal/domain/gender.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart';
import 'package:openeatsjournal/ui/widgets/onboarding/onboarding_textfield.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({
    super.key,
    required this.onDone,
    required OnboardingViewModel onboardingViewModel,
  }) : _onboardingViewModel = onboardingViewModel;
  final OnboardingViewModel _onboardingViewModel;

  final VoidCallback onDone;

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
  final TextEditingController _birthDayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String currentLocale = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;
    String decimalSeparator = NumberFormat.decimalPattern(currentLocale).symbols.DECIMAL_SEP;

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.your_gender,
          style: textTheme.titleMedium,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder(
              valueListenable: widget._onboardingViewModel.gender,
              builder: (context, value, _) {
                return ChoiceChip(
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  avatar: Icon(Icons.male),
                  label: Text(AppLocalizations.of(context)!.male),
                  showCheckmark: false,
                  selected: widget._onboardingViewModel.gender.value == Gender.male,
                  onSelected: (bool selected) {
                    widget._onboardingViewModel.gender.value = Gender.male;
                  },
                );
              },
            ),
            SizedBox(width: 8),
            ValueListenableBuilder(
              valueListenable: widget._onboardingViewModel.gender,
              builder: (context, value, _) {
                return ChoiceChip(
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  avatar: Icon(Icons.female),
                  label: Text(AppLocalizations.of(context)!.female),
                  showCheckmark: false,
                  selected: widget._onboardingViewModel.gender.value == Gender.femail,
                  onSelected: (bool selected) {
                    widget._onboardingViewModel.gender.value = Gender.femail;
                  },
                );
              },
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Text(
          AppLocalizations.of(context)!.your_birthday,
          style: textTheme.titleMedium,
        ),
        OnboardingTextField(
          controller: _birthDayController,
          onTap: () {
            _selectDate(currentLocale);
          },
          readOnly: true
        ),
        SizedBox(height: 10.0),
        Text(
          AppLocalizations.of(context)!.your_height,
          style: textTheme.titleMedium,
        ),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.height,
          builder: (context, value, _) {
            return OnboardingTextField(
              keyboardType: TextInputType.numberWithOptions(signed: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final String text = newValue.text;
                  return text.isEmpty
                      ? newValue
                      : text.length > 3
                      ? oldValue
                      : newValue;
                }),
              ],
              onChanged: (value) {
                widget._onboardingViewModel.height.value = int.tryParse(value);
              },
            );
          },
        ),
        SizedBox(height: 10.0),
        Text(
          AppLocalizations.of(context)!.your_weight,
          style: textTheme.titleMedium,
        ),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.weight,
          builder: (context, value, _) {
            return OnboardingTextField(
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              inputFormatters: [
                //if filter is not matched, the value is set to empty string
                //which feels strange in the ui
                //FilteringTextInputFormatter.allow(RegExp(weightRegExp)),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final String text = newValue.text;
                  return text.isEmpty
                      ? newValue
                      : _matchWeight(text, decimalSeparator)
                      ? newValue
                      : oldValue;
                }),
              ],
              onChanged: (value) {
                num? weightNum = NumberFormat(
                  null,
                  currentLocale,
                ).tryParse(value);
                widget._onboardingViewModel.weight.value = weightNum != null
                  ? weightNum as double
                  : null;
              },
            );
          },
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.your_acitivty_level,
              style: textTheme.titleMedium,
            ),
            Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 60),
              message: AppLocalizations.of(
                context,
              )!.acitivity_level_explanation,
              child: Icon(Icons.help_outline),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.activityFactor,
          builder: (context, value, _) {
            return ChoiceChip(
              padding: EdgeInsets.symmetric(vertical: 13.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(AppLocalizations.of(context)!.very_low),
              selected: widget._onboardingViewModel.activityFactor.value == 1.2,
              onSelected: (bool selected) {
                widget._onboardingViewModel.activityFactor.value = 1.2;
              },
            );
          },
        ),
        SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.activityFactor,
          builder: (context, value, _) {
            return ChoiceChip(
              padding: EdgeInsets.symmetric(vertical: 13.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(AppLocalizations.of(context)!.low),
              selected: widget._onboardingViewModel.activityFactor.value == 1.4,
              onSelected: (bool selected) {
                widget._onboardingViewModel.activityFactor.value = 1.4;
              },
            );
          },
        ),
        SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.activityFactor,
          builder: (context, value, _) {
            return ChoiceChip(
              padding: EdgeInsets.symmetric(vertical: 13.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(AppLocalizations.of(context)!.medium),
              selected: widget._onboardingViewModel.activityFactor.value == 1.6,
              onSelected: (bool selected) {
                widget._onboardingViewModel.activityFactor.value = 1.6;
              },
            );
          },
        ),
        SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.activityFactor,
          builder: (context, value, _) {
            return ChoiceChip(
              padding: EdgeInsets.symmetric(vertical: 13.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(AppLocalizations.of(context)!.high),
              selected: widget._onboardingViewModel.activityFactor.value == 1.8,
              onSelected: (bool selected) {
                widget._onboardingViewModel.activityFactor.value = 1.8;
              },
            );
          },
        ),
        SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.activityFactor,
          builder: (context, value, _) {
            return ChoiceChip(
              padding: EdgeInsets.symmetric(vertical: 13.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(AppLocalizations.of(context)!.very_high),
              selected: widget._onboardingViewModel.activityFactor.value == 2.1,
              onSelected: (bool selected) {
                widget._onboardingViewModel.activityFactor.value = 2.1;
              },
            );
          },
        ),
        SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: widget._onboardingViewModel.activityFactor,
          builder: (context, value, _) {
            return ChoiceChip(
              padding: EdgeInsets.symmetric(vertical: 13.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(AppLocalizations.of(context)!.professional_athlete),
              selected: widget._onboardingViewModel.activityFactor.value == 2.4,
              onSelected: (bool selected) {
                widget._onboardingViewModel.activityFactor.value = 2.4;
              },
            );
          },
        ),
        Spacer(),
        FilledButton(
          onPressed: () {
            if (widget._onboardingViewModel.gender.value == null) {
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

            if (widget._onboardingViewModel.birthday.value == null) {
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

            if (widget._onboardingViewModel.height.value == null ||
                widget._onboardingViewModel.height.value! <= 0) {
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

            if (widget._onboardingViewModel.weight.value == null ||
                widget._onboardingViewModel.weight.value! <= 0) {
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

            if (widget._onboardingViewModel.activityFactor.value == null) {
              SnackBar snackBar = SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.select_activity_level,
                ),
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

            widget.onDone();
          },

          child: Text(AppLocalizations.of(context)!.proceed),
        ),
      ],
    );
  }

  Future<void> _selectDate(String locale) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _birthDayController.text = DateFormat.yMMMMd(locale).format(date);
      widget._onboardingViewModel.birthday.value = date;
    }
  }

  bool _matchWeight(String weight, String decimalSeparator) {
    var matches = RegExp(
      r"^\d*\" + decimalSeparator + r"?\d*$",
    ).allMatches(weight);
    if (matches.length != 1) {
      return false;
    }

    List<String> parts = weight.split(decimalSeparator);

    if (parts.length > 3) {
      return false;
    }

    if (parts[0].length > 3) {
      return false;
    }

    if (parts.length > 1) {
      if (parts[1].length > 1) {
        return false;
      }
    }

    return true;
  }

  @override
  void dispose() {
    _birthDayController.dispose();
    super.dispose();
  }
}
