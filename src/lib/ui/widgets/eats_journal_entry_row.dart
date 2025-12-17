import 'package:flutter/material.dart';
import 'package:openeatsjournal/domain/eats_journal_entry.dart';
import 'package:openeatsjournal/domain/nutrition_calculator.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/utils/food_source_format.dart';

class EatsJournalEntryRow extends StatelessWidget {
  const EatsJournalEntryRow({
    super.key,
    required EatsJournalEntry eatsJournalEntry,
    required Future<void> Function({required int eatsJournalEntryId}) onDeletePressed,
    required Color deleteIconColor,
  }) : _eatsJournalEntry = eatsJournalEntry,
       _onDeletePressed = onDeletePressed,
       _deleteIconColor = deleteIconColor;

  final EatsJournalEntry _eatsJournalEntry;
  final Future<void> Function({required int eatsJournalEntryId}) _onDeletePressed;
  final Color _deleteIconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_eatsJournalEntry.name),
                Spacer(),
                Column(
                  children: [
                    Text(
                      _eatsJournalEntry.amount != null
                          ? "${ConvertValidate.getCleanDoubleString(doubleValue: _eatsJournalEntry.amount!)}${_eatsJournalEntry.amountMeasurementUnit!.text}"
                          : AppLocalizations.of(context)!.na_amount,
                    ),
                    Text("${ConvertValidate.numberFomatterInt.format(NutritionCalculator.getKCalsFromKJoules(kJoules: _eatsJournalEntry.kJoule))} ${AppLocalizations.of(context)!.kcal}"),
                  ],
                ),
                SizedBox(width: 10),
                Badge(
                  label: Text(FoodSourceFormat.getFoodSourceLabel(food: _eatsJournalEntry.food, context: context)),
                  backgroundColor: FoodSourceFormat.getFoodSourceColor(food: _eatsJournalEntry.food, context: context),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: _deleteIconColor),
          onPressed: () async {
            await _onDeletePressed(eatsJournalEntryId: _eatsJournalEntry.id!);
          },
        ),
      ],
    );
  }
}
