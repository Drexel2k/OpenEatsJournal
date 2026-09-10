import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:provider/provider.dart";

class EatsJournalEntrySearchResultRow extends StatelessWidget {
  const EatsJournalEntrySearchResultRow({
    super.key,
    required EatsJournalEntry eatsJournalEntry,
    required void Function({required EatsJournalEntry eatsJournalEntry}) onPressed,
    required Future<void> Function({required int eatsJournalEntryId}) onCopyPressed,
    required Future<void> Function({required EatsJournalEntry eatsJournalEntry}) onGotoPressed,
  }) : _eatsJournalEntry = eatsJournalEntry,
       _onPressed = onPressed,
       _onCopyPressed = onCopyPressed,
       _onGotoPressed = onGotoPressed;

  final EatsJournalEntry _eatsJournalEntry;
  final void Function({required EatsJournalEntry eatsJournalEntry}) _onPressed;
  final Future<void> Function({required int eatsJournalEntryId}) _onCopyPressed;
  final Future<void> Function({required EatsJournalEntry eatsJournalEntry}) _onGotoPressed;

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    String amountInformation = AppLocalizations.of(context)!.na;
    if (_eatsJournalEntry.amount != null) {
      amountInformation = _eatsJournalEntry.amountMeasurementUnit == MeasurementUnit.gram
          ? "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayWeightG(weightG: _eatsJournalEntry.amount!))}${convert.getLocalizedWeightUnitGAbbreviated(context: context)}"
          : "${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayVolume(volumeMl: _eatsJournalEntry.amount!))}${convert.getLocalizedVolumeUnitAbbreviated(context: context)}";
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              _onPressed(eatsJournalEntry: _eatsJournalEntry);
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_eatsJournalEntry.name),
                      Row(
                        children: [
                          Text(
                            "${convert.numberFomatterInt.format(convert.getDisplayEnergy(energyKJ: _eatsJournalEntry.kJoule))}${convert.getLocalizedEnergyUnitAbbreviated(context: context)}",
                          ),
                          Spacer(),
                          Text(amountInformation),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5),
                Badge(
                  label: Text(UiHelpers.getFoodSourceLabel(food: _eatsJournalEntry.food, context: context)),
                  backgroundColor: UiHelpers.getFoodSourceColor(food: _eatsJournalEntry.food, context: context),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 5),
        RoundOutlinedButton(
          onPressed: () async {
            await _onCopyPressed(eatsJournalEntryId: _eatsJournalEntry.id!);
          },
          child: Icon(Icons.content_copy),
        ),
        SizedBox(width: 5),
        RoundOutlinedButton(
          onPressed: () async {
            await _onGotoPressed(eatsJournalEntry: _eatsJournalEntry);
          },
          child: Icon(Icons.event),
        ),
      ],
    );
  }
}
