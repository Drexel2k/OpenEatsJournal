import "package:flutter/material.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/home.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";

class OnboardingPage4 extends StatefulWidget {
  const OnboardingPage4({
    super.key,
    required this.onDone,
    required OnboardingViewModel onboardingViewModel,
  }) : _onboardingViewModel = onboardingViewModel;
  final OnboardingViewModel _onboardingViewModel;

  final VoidCallback onDone;

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  int? dailyKCalories;
  int? dailyWeightLossCalories;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    _calculateKCalories();

    return ListenableBuilder(
      listenable: widget._onboardingViewModel,
      builder: (context, _) {
        return Column(
          children: [
            Text(
              AppLocalizations.of(context)!.your_weight_target,
              style: textTheme.titleMedium,
            ),
            ValueListenableBuilder(
              valueListenable: widget._onboardingViewModel.weightTarget,
              builder: (context, value, _) {
                return ChoiceChip(
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(AppLocalizations.of(context)!.keep_weight),
                  selected: widget._onboardingViewModel.weightTarget.value == WeightTarget.keep,
                  onSelected: (bool selected) {
                    widget._onboardingViewModel.weightTarget.value = WeightTarget.keep;
                    setState(() {
                        _calculateKCalories();                     
                      }
                    );
                  },
                );
              },
            ),
            SizedBox(height: 10.0),
            ValueListenableBuilder(
              valueListenable: widget._onboardingViewModel.weightTarget,
              builder: (context, value, _) {
                return ChoiceChip(
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(AppLocalizations.of(context)!.lose025),
                  selected: widget._onboardingViewModel.weightTarget.value == WeightTarget.lose025,
                  onSelected: (bool selected) {
                    widget._onboardingViewModel.weightTarget.value = WeightTarget.lose025;
                    setState(() {
                        _calculateKCalories();                     
                      }
                    );
                  },
                );
              },
            ),
            SizedBox(height: 10.0),
            ValueListenableBuilder(
              valueListenable: widget._onboardingViewModel.weightTarget,
              builder: (context, value, _) {
                return ChoiceChip(
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(AppLocalizations.of(context)!.lose05),
                  selected: widget._onboardingViewModel.weightTarget.value == WeightTarget.lose05,
                  onSelected: (bool selected) {
                    widget._onboardingViewModel.weightTarget.value = WeightTarget.lose05;
                    setState(() {
                        _calculateKCalories();                     
                      }
                    );
                  },
                );
              },
            ),
            SizedBox(height: 10.0),
            ValueListenableBuilder(
              valueListenable: widget._onboardingViewModel.weightTarget,
              builder: (context, value, _) {
                return ChoiceChip(
                  padding: EdgeInsets.symmetric(vertical: 13.0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(AppLocalizations.of(context)!.lose075),
                  selected: widget._onboardingViewModel.weightTarget.value == WeightTarget.lose075,
                  onSelected: (bool selected) {
                    widget._onboardingViewModel.weightTarget.value = WeightTarget.lose075;
                    setState(() {
                        _calculateKCalories();                     
                      }
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.your_calories_values,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center
            ),
            Text("${AppLocalizations.of(context)!.daily_calories} ${dailyKCalories == null ? "" : dailyKCalories!.toString()}",
              style: textTheme.bodyLarge),
            Text("${AppLocalizations.of(context)!.daily_weightloss_calories} ${dailyWeightLossCalories == null ? "" : dailyWeightLossCalories!.toString()}",
              style: textTheme.bodyLarge),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.proposed_values,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge),
            Text(AppLocalizations.of(context)!.in_doubt_consult_doctor,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge),
            Spacer(),
            FilledButton(
              onPressed: () async {
                await widget._onboardingViewModel.saveOnboardingData();
                if(context.mounted) {
                  //home (route "/") is always on top of the MaterialApp's navigations stack.
                  Navigator.pop(context);
                }    
              },
              child: Text(AppLocalizations.of(context)!.finish),
            ),
          ],
        );
      },
    );
  }

  void _calculateKCalories() {
    int age = 0;
    final DateTime today = DateTime.now();
    age = today.year - widget._onboardingViewModel.birthday.value!.year;
    final month = today.month - widget._onboardingViewModel.birthday.value!.month;

    if (month < 0) {
      age = age - 1;
    }

    double weightLossKg = 0;
    if (widget._onboardingViewModel.weightTarget.value == WeightTarget.lose025) {
      weightLossKg = 0.25;
    }

    if (widget._onboardingViewModel.weightTarget.value == WeightTarget.lose05) {
      weightLossKg = 0.5;
    }

    if (widget._onboardingViewModel.weightTarget.value == WeightTarget.lose075) {
      weightLossKg = 0.75;
    }

    double dailyKCaloriesD =
        NutritionCalculator.calculateTotalKCaloriesPerDay(
          NutritionCalculator.calculateBasalMetabolicRate(
            widget._onboardingViewModel.weight.value!,
            widget._onboardingViewModel.height.value!,
            age,
            widget._onboardingViewModel.gender.value!,
          ),
          widget._onboardingViewModel.activityFactor.value!,
        );
    double dailyWeightLossCaloriesD =
        NutritionCalculator.calculateTotalWithWeightLoss(
          dailyKCaloriesD,
          weightLossKg,
        );

    dailyKCalories = dailyKCaloriesD.round();
    dailyWeightLossCalories = dailyWeightLossCaloriesD.round(); 
  }
}
