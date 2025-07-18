import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_state.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_state_data.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
  final TextEditingController _birthDayController = TextEditingController();
  OnboardingStateData? _onboardingData;
  String? _decimalSeparator;

  @override
  Widget build(BuildContext context) {
    _onboardingData = OnboardingState.of(context).data;
    final String currentLocale = Localizations.localeOf(context).toString();
    final TextTheme textTheme = Theme.of(context).textTheme;
    _decimalSeparator = NumberFormat.decimalPattern(currentLocale).symbols.DECIMAL_SEP;

    return Column(
      children: [
        Text(AppLocalizations.of(context)!.your_gender, style: textTheme.labelMedium),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ChoiceChip(
              label: Text(AppLocalizations.of(context)!.male),
              selected: _onboardingData!.gender == 1,
              onSelected: (bool selected) {
                setState(() {
                  _onboardingData!.gender = 1;
                });
              },
            ),
            ChoiceChip(
              label: Text(AppLocalizations.of(context)!.female),
              selected: _onboardingData!.gender == 2,
              onSelected: (bool selected) {
                setState(() {
                  _onboardingData!.gender = 2;
                });
              },
            )
          ]
        ),
        Text(AppLocalizations.of(context)!.your_birthday, style: textTheme.labelMedium),
        TextField(
          readOnly: true,
          controller: _birthDayController,
          onTap: (){
            _selectDate(currentLocale);
          },
        ),
        Text(AppLocalizations.of(context)!.your_height, style: textTheme.labelMedium),
        TextField(
          keyboardType: TextInputType.numberWithOptions(signed: false,),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            TextInputFormatter.withFunction((oldValue, newValue) {
              final String text = newValue.text;
              return text.isEmpty ?
                newValue :
                text.length > 3 ?
                  oldValue :
                  newValue;
              }
            )
          ],
          onChanged:(value) {
            _onboardingData!.height = int.tryParse(value);
          },
          ),
        Text(AppLocalizations.of(context)!.your_weight, style: textTheme.labelMedium),
        TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false,),
          inputFormatters: [
            //if filter is not matched, the value is set to empty string
            //which feels strange in the ui
            //FilteringTextInputFormatter.allow(RegExp(weightRegExp)),
            TextInputFormatter.withFunction((oldValue, newValue) {
              final String text = newValue.text;
              return text.isEmpty ?
                newValue :
                _matchWeight(text) ?
                  newValue :
                  oldValue;
              }
            ),
          ],
            onChanged:(value) {
              num? weightNum = NumberFormat(null, currentLocale).tryParse(value);
              _onboardingData!.weight = weightNum == null ? null : weightNum as double;
          },
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.your_acitivty_level, style: textTheme.labelMedium),
            Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 60),
              message: AppLocalizations.of(context)!.acitivity_level_explanation, child:  Icon(Icons.help_outline)),
          ]
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.very_low),
          selected: _onboardingData!.activityFactor == 1.2,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.activityFactor = 1.2;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.low),
          selected: _onboardingData!.activityFactor == 1.4,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.activityFactor = 1.4;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.medium),
          selected: _onboardingData!.activityFactor == 1.6,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.activityFactor = 1.6;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.high),
          selected: _onboardingData!.activityFactor == 1.8,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.activityFactor = 1.8;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.very_high),
          selected: _onboardingData!.activityFactor == 2.1,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.activityFactor = 2.1;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.professional_athlete),
          selected: _onboardingData!.activityFactor == 2.4,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.activityFactor = 2.4;
            });
          },
        ),
        Spacer(),
        FilledButton (onPressed: () {
            if(_onboardingData!.gender == null) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.select_gender),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.close,
                  onPressed: () {
                    //Click on SnackbarAction closes the SnackBar,
                    //nothing else to do here...
                  },            
                )
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            if(_onboardingData!.birthDay == null) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.select_birthday),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.close,
                  onPressed: () {
                    //Click on SnackbarAction closes the SnackBar,
                    //nothing else to do here...
                  },            
                )
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            if(_onboardingData!.height ==  null || _onboardingData!.height! <= 0) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.select_height),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.close,
                  onPressed: () {
                    //Click on SnackbarAction closes the SnackBar,
                    //nothing else to do here...
                  },            
                )
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            if(_onboardingData!.weight == null || _onboardingData!.weight! <= 0) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.select_weight),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.close,
                  onPressed: () {
                    //Click on SnackbarAction closes the SnackBar,
                    //nothing else to do here...
                  },            
                )
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            if(_onboardingData!.activityFactor == null) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.select_activity_level),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.close,
                  onPressed: () {
                    //Click on SnackbarAction closes the SnackBar,
                    //nothing else to do here...
                  },            
                )
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            widget.onDone();
        },
          child: Text(AppLocalizations.of(context)!.proceed))
      ]
    );
  }

Future<void> _selectDate(String locale) async {
  DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now());

    if (date != null){
      _birthDayController.text = DateFormat.yMMMMd(locale).format(date);
      _onboardingData!.birthDay = date;
    }
  }
  
  bool _matchWeight(String weight) {
    var matches = RegExp(r"^\d*\" + _decimalSeparator! + r"?\d*$").allMatches(weight);
    if(matches.length != 1)
    {
      return false;
    }

    List<String> parts = weight.split(_decimalSeparator!);

    if(parts.length > 3) {
      return false;
    }

    if(parts[0].length > 3) {
      return false;
    }
    
    if (parts.length > 1) {
      if(parts[1].length > 1) {
        return false;
      }
    }
    
    return true;
  }
}