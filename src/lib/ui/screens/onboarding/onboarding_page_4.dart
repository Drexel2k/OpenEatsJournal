import 'package:flutter/material.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_state.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_state_data.dart';

class OnboardingPage4 extends StatefulWidget {
  const OnboardingPage4({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  OnboardingStateData? _onboardingData;
  int? dailyKCalories;
  int? dailyWeightLossCalories;
  int? dailyCarbohydrate;
  int? dailyProtein;
  int? dailyFat;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    _onboardingData = OnboardingState.of(context).data;
    
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.your_weight_target, style: textTheme.labelMedium),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.keep_weight),
          selected: _onboardingData!.target == 1,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.target = 1;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.lose_025),
          selected: _onboardingData!.target == 2,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.target = 2;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.lose_05),
          selected: _onboardingData!.target == 3,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.target = 3;
            });
          },
        ),
        ChoiceChip(
          label: Text(AppLocalizations.of(context)!.lose_075),
          selected: _onboardingData!.target == 4,
          onSelected: (bool selected) {
            setState(() {
              _onboardingData!.target = 4;
            });
          },
        ),
        Text("Dayily kCalories: " + (dailyKCalories == null ? "" : dailyKCalories!.toString())),
        Text("Daily weightloss kCalories: " + (dailyKCalories == null ? "" : dailyWeightLossCalories!.toString())),
        Text("Daily weightloss carbohydrates: " + (dailyCarbohydrate == null ? "" : dailyCarbohydrate!.toString())),
        Text("Daily weightloss proteins: " + (dailyProtein == null ? "" : dailyProtein!.toString())),
        Text("Daily weightloss fat: " + (dailyFat == null ? "" : dailyFat!.toString())),
        Text(AppLocalizations.of(context)!.proposed_values),
        Text(AppLocalizations.of(context)!.in_doubt_consult_doctor),
        Spacer(),
        FilledButton (onPressed: () {
            if(_onboardingData!.target == null) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.select_target),
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
            setState(() {
              int age = 0;
              final DateTime today = DateTime.now();
              age = today.year - _onboardingData!.birthDay!.year;
              final month = today.month - _onboardingData!.birthDay!.month;
 
              if(month < 0){
                age = age -1;
              }

              double weightLossKg = 0;
              if(_onboardingData!.target == 2) {
                weightLossKg = 0.25;
              }

              if(_onboardingData!.target == 3) {
                weightLossKg = 0.5;
              }

              if(_onboardingData!.target == 4) {
                weightLossKg = 0.75;
              }

              double dailyKCaloriesD =  NutritionCalculator.calculateTotalKCaloriesPerDay(_onboardingData!.weight!, _onboardingData!.height!, age, _onboardingData!.gender!, _onboardingData!.activityFactor!);
              double dailyWeightLossCaloriesD = NutritionCalculator.calculateTotalWithWeightLoss(dailyKCaloriesD, weightLossKg);
              double dailyCarbohydrateD = NutritionCalculator.calculateCarbohydrateDemandByKCalories(dailyWeightLossCaloriesD);
              double dailyProteinD = NutritionCalculator.calculateProteinDemandByKCalories(dailyWeightLossCaloriesD);
              double dailyFatD = NutritionCalculator.calculateFatDemandByKCalories(dailyWeightLossCaloriesD);

              dailyKCalories =  dailyKCaloriesD.round();
              dailyWeightLossCalories = dailyWeightLossCaloriesD.round();
              dailyCarbohydrate = dailyCarbohydrateD.round();
              dailyProtein = dailyProteinD.round();
              dailyFat = dailyFatD.round();
            });
        },
          child: Text(AppLocalizations.of(context)!.finish))
      ]
    );
  }
}