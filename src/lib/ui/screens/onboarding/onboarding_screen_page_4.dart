import "package:flutter/material.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/weight_target.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class OnboardingScreenPage4 extends StatelessWidget {
  OnboardingScreenPage4({super.key, required onDone, required OnboardingScreenViewModel onboardingScreenViewModel})
    : _onDone = onDone,
      _onboardingScreenViewModel = onboardingScreenViewModel {
    onboardingScreenViewModel.calculateKJoule();
  }

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
                                  label: "-${ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: ConvertValidate.getDisplayWeightKg(weightKg: 0.25))}${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)} ${AppLocalizations.of(contextBuilder)!.per_week}",
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
                                  label: "-${ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: ConvertValidate.getDisplayWeightKg(weightKg: 0.5))}${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)} ${AppLocalizations.of(contextBuilder)!.per_week}",
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
                                  label: "-${ConvertValidate.getCleanDoubleString3DecimalDigits(doubleValue: ConvertValidate.getDisplayWeightKg(weightKg: 0.75))}${ConvertValidate.getLocalizedWeightUnitKgAbbreviated(context: context)} ${AppLocalizations.of(contextBuilder)!.per_week}",
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
                  Spacer(),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.weightTarget,
                    builder: (contextBuilder, _, _) {
                      return Center(
                        child: Text(
                          _onboardingScreenViewModel.dailyNeedEnergy.value != null
                              ? ConvertValidate.numberFomatterInt.format(_onboardingScreenViewModel.dailyNeedEnergy.value)
                              : AppLocalizations.of(contextBuilder)!.na,

                          style: textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Text(AppLocalizations.of(context)!.daily_calories_need, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _onboardingScreenViewModel.weightTarget,
                    builder: (contextBuilder, _, _) {
                      return Center(
                        child: Text(
                          _onboardingScreenViewModel.dailyTargetEnergy.value != null
                              ? ConvertValidate.numberFomatterInt.format(_onboardingScreenViewModel.dailyTargetEnergy.value)
                              : AppLocalizations.of(contextBuilder)!.na,
                          style: textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Text(AppLocalizations.of(context)!.daily_calories_target, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.proposed_values, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.in_doubt_consult_doctor, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Center(
                    child: FilledButton(
                      onPressed: () {
                        if (_onboardingScreenViewModel.weightTarget.value == null) {
                          SnackBar snackBar = SnackBar(
                            content: Text(AppLocalizations.of(context)!.select_target),
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

                        _onDone();
                      },
                      child: Text(AppLocalizations.of(context)!.proceed),
                    ),
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
