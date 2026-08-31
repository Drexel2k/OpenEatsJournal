import "package:flutter/material.dart";
import "package:gauge_indicator/gauge_indicator.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/gauge_data.dart";
import "package:openeatsjournal/ui/widgets/gauge_nutrition_fact_small.dart";
import "package:provider/provider.dart";

class EatsJournalMainButton extends StatelessWidget {
  const EatsJournalMainButton({
    super.key,
    required GaugeData kJouleGaugeData,
    required GaugeData fatGaugeData,
    required GaugeData carbohydratesGaugeData,
    required GaugeData proteinGaugeData,
    required EatsJournalScreenViewModel eatsJournalScreenViewModel,
    required JournalRepository journalRepository,
    required SettingsRepository settingsRepository,
  }) : _kJouleGaugeData = kJouleGaugeData,
       _fatGaugeData = fatGaugeData,
       _carbohydratesGaugeData = carbohydratesGaugeData,
       _proteinGaugeData = proteinGaugeData,
       _eatsJournalScreenViewModel = eatsJournalScreenViewModel,
       _journalRepository = journalRepository,
       _settingsRepository = settingsRepository;

  final GaugeData _kJouleGaugeData;
  final GaugeData _fatGaugeData;
  final GaugeData _carbohydratesGaugeData;
  final GaugeData _proteinGaugeData;
  final EatsJournalScreenViewModel _eatsJournalScreenViewModel;
  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 225,
      //main nutrition button
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29.0))),
        onPressed: () async {
          await showDialog<void>(
            useSafeArea: true,
            barrierDismissible: false,
            context: context,
            builder: (BuildContext contextBuilder) {
              double horizontalPadding = MediaQuery.sizeOf(contextBuilder).width * 0.05;
              double verticalPadding = MediaQuery.sizeOf(contextBuilder).height * 0.03;

              return Dialog(
                insetPadding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding),
                child: ChangeNotifierProvider(
                  create: (context) => EatsJournalEditScreenViewModel(journalRepository: _journalRepository, settingsRepository: _settingsRepository),
                  child: EatsJournalEditScreen(),
                ),
              );
            },
          );

          _eatsJournalScreenViewModel.refreshNutritionData();
        },
        child: Column(
          children: [
            SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 145,
                  child: RadialGauge(
                    radius: 150.0,
                    value: _kJouleGaugeData.percentageFilled.toDouble(),
                    axis: GaugeAxis(
                      pointer: null,
                      min: 0,
                      max: 100,
                      sweepDegrees: 260.0,
                      progressBar: GaugeProgressBar.rounded(
                        color: _kJouleGaugeData.currentValue < _kJouleGaugeData.maxValue ? colorScheme.primary : colorScheme.error,
                        placement: GaugeProgressPlacement.inside,
                      ),
                      style: GaugeAxisStyle(
                        thickness: 14,
                        background: _kJouleGaugeData.currentValue < _kJouleGaugeData.maxValue ? colorScheme.inversePrimary : colorScheme.primary,
                        cornerRadius: Radius.circular(8.0),
                      ),
                    ),
                  ),
                ),

                ListenableBuilder(
                  listenable: _eatsJournalScreenViewModel.settingsChanged,
                  builder: (_, _) {
                    return Column(
                      children: [
                        Text(
                          convert.getLocalizedEnergyUnit(context: context),
                          style: textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant, size: 15, color: colorScheme.primary),
                            Text(
                              " ${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: (_kJouleGaugeData.maxValue - _kJouleGaugeData.currentValue).toDouble()))}",
                              style: textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Text(
                          "${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: _kJouleGaugeData.currentValue.toDouble()))}/${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: _kJouleGaugeData.maxValue.toDouble()))}",
                          style: textTheme.titleSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.fat, gaugeData: _fatGaugeData),
                Spacer(),
                GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.carbs, gaugeData: _carbohydratesGaugeData),
                Spacer(),
                GaugeNutritionFactSmall(factName: AppLocalizations.of(context)!.protein, gaugeData: _proteinGaugeData),
                SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
