import "package:flutter/material.dart";
import "package:openeatsjournal/domain/nutrition_calculator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class OnboardingScreenPage4 extends StatelessWidget {
  const OnboardingScreenPage4({super.key, required onDone, required OnboardingScreenViewModel onboardingScreenViewModel})
    : _onDone = onDone,
      _onboardingScreenViewModel = onboardingScreenViewModel;

  final OnboardingScreenViewModel _onboardingScreenViewModel;
  final VoidCallback _onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(AppLocalizations.of(context)!.your_weight_target, style: textTheme.titleSmall)),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _onboardingScreenViewModel.weightTarget,
                              builder: (contextBuilder, _, _) {
                                return TransparentChoiceChip(
                                  label: AppLocalizations.of(contextBuilder)!.keep_weight,
                                  selected: _onboardingScreenViewModel.weightTarget.value == WeightTarget.keep,
                                  onSelected: (bool selected) {
                                    _onboardingScreenViewModel.weightTarget.value = WeightTarget.keep;
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            ValueListenableBuilder(
                              valueListenable: _onboardingScreenViewModel.weightTarget,
                              builder: (contextBuilder, _, _) {
                                return TransparentChoiceChip(
                                  label: AppLocalizations.of(contextBuilder)!.lose025,
                                  selected: _onboardingScreenViewModel.weightTarget.value == WeightTarget.lose025,
                                  onSelected: (bool selected) {
                                    _onboardingScreenViewModel.weightTarget.value = WeightTarget.lose025;
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            ValueListenableBuilder(
                              valueListenable: _onboardingScreenViewModel.weightTarget,
                              builder: (contextBuilder, _, _) {
                                return TransparentChoiceChip(
                                  label: AppLocalizations.of(contextBuilder)!.lose05,
                                  selected: _onboardingScreenViewModel.weightTarget.value == WeightTarget.lose05,
                                  onSelected: (bool selected) {
                                    _onboardingScreenViewModel.weightTarget.value = WeightTarget.lose05;
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            ValueListenableBuilder(
                              valueListenable: _onboardingScreenViewModel.weightTarget,
                              builder: (contextBuilder, _, _) {
                                return TransparentChoiceChip(
                                  label: AppLocalizations.of(contextBuilder)!.lose075,
                                  selected: _onboardingScreenViewModel.weightTarget.value == WeightTarget.lose075,
                                  onSelected: (bool selected) {
                                    _onboardingScreenViewModel.weightTarget.value = WeightTarget.lose075;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.weightTarget,
                    builder: (contextBuilder, _, _) {
                      return Text(
                        AppLocalizations.of(contextBuilder)!.your_daily_calories_need(
                          _onboardingScreenViewModel.dailyNeedKJoule.value != null
                              ? ConvertValidate.numberFomatterInt.format(
                                  NutritionCalculator.getKCalsFromKJoules(kJoules: _onboardingScreenViewModel.dailyNeedKJoule.value!),
                                )
                              : AppLocalizations.of(contextBuilder)!.na,
                        ),
                        style: textTheme.titleMedium,
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.weightTarget,
                    builder: (contextBuilder, _, _) {
                      return Text(
                        AppLocalizations.of(contextBuilder)!.your_daily_calories_target(
                          _onboardingScreenViewModel.dailyTargetKJoule.value != null
                              ? ConvertValidate.numberFomatterInt.format(
                                  NutritionCalculator.getKCalsFromKJoules(kJoules: _onboardingScreenViewModel.dailyTargetKJoule.value!),
                                )
                              : AppLocalizations.of(contextBuilder)!.na,
                        ),
                        style: textTheme.titleMedium,
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.proposed_values, style: textTheme.bodyLarge),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.in_doubt_consult_doctor, style: textTheme.bodyLarge),
                  Spacer(),
                  Center(
                    child: FilledButton(onPressed: _onDone, child: Text(AppLocalizations.of(context)!.finish)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
