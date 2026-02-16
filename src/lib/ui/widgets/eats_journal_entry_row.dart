import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/measurement_unit.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class EatsJournalEntryRow extends StatelessWidget {
  const EatsJournalEntryRow({
    super.key,
    required EatsJournalEntry eatsJournalEntry,
    required void Function({required EatsJournalEntry eatsJournalEntry}) onPressed,
    required Future<void> Function({required int eatsJournalEntryId}) onDeletePressed,
    required Future<void> Function({required EatsJournalEntry eatsJournalEntry}) onDuplicatePressed,
    required Color deleteIconColor,
  }) : _eatsJournalEntry = eatsJournalEntry,
       _onPressed = onPressed,
       _onDeletePressed = onDeletePressed,
       _onDuplicatePressed = onDuplicatePressed,
       _deleteIconColor = deleteIconColor;

  final EatsJournalEntry _eatsJournalEntry;
  final void Function({required EatsJournalEntry eatsJournalEntry}) _onPressed;
  final Future<void> Function({required int eatsJournalEntryId}) _onDeletePressed;
  final Future<void> Function({required EatsJournalEntry eatsJournalEntry}) _onDuplicatePressed;
  final Color _deleteIconColor;

  @override
  Widget build(BuildContext context) {
    String amountInformation = AppLocalizations.of(context)!.na;
    if (_eatsJournalEntry.amount != null) {
      amountInformation = _eatsJournalEntry.amountMeasurementUnit == MeasurementUnit.gram
          ? "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightG(weightG: _eatsJournalEntry.amount!))}${ConvertValidate.getLocalizedWeightUnitGAbbreviated(context: context)}"
          : "${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayVolume(volumeMl: _eatsJournalEntry.amount!))}${ConvertValidate.getLocalizedVolumeUnitAbbreviated(context: context)}";
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
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
                            "${ConvertValidate.numberFomatterInt.format(ConvertValidate.getDisplayEnergy(energyKJ: _eatsJournalEntry.kJoule))}${ConvertValidate.getLocalizedEnergyUnitAbbreviated(context: context)}",
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
            await _onDuplicatePressed(eatsJournalEntry: _eatsJournalEntry);
          },
          child: Icon(Icons.control_point_duplicate, color: _deleteIconColor),
        ),
        SizedBox(width: 5),
        RoundOutlinedButton(
          onPressed: () async {
            await _onDeletePressed(eatsJournalEntryId: _eatsJournalEntry.id!);
          },
          child: Icon(Icons.delete, color: _deleteIconColor),
        ),
      ],
    );
  }
}
