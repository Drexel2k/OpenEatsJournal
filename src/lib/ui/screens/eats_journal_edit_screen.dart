import "package:flutter/material.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/eats_journal_entry_row.dart";

class EatsJournalEditScreen extends StatelessWidget {
  const EatsJournalEditScreen({super.key, required EatsJournalEditScreenViewModel eatsJournalEditScreenViewModel})
    : _eatsJournalEditScreenViewModel = eatsJournalEditScreenViewModel;

  final EatsJournalEditScreenViewModel _eatsJournalEditScreenViewModel;

  @override
  Widget build(BuildContext context) {
    _eatsJournalEditScreenViewModel.getEatsJournalEntries();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 7, 10),

      child: Column(
        children: [
          AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.weight_journal)),
          Row(
            children: [
              Text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalEditScreenViewModel.currentJournalDate), style: textTheme.titleMedium),
              Spacer(),
              Text(
                _getLocalizedMeal(meal: _eatsJournalEditScreenViewModel.meal, context: context),
                style: textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
            child: ListenableBuilder(
              listenable: _eatsJournalEditScreenViewModel.eatsJournalEntriesChanged,
              builder: (_, _) {
                return ListView.builder(
                  itemCount: _eatsJournalEditScreenViewModel.eatsJournalEntriesResult.length,
                  itemBuilder: (context, listViewItemIndex) {
                    if (listViewItemIndex >= _eatsJournalEditScreenViewModel.eatsJournalEntriesResult.length) {
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    }

                    return EatsJournalEntryRow(
                      eatsJournalEntry: _eatsJournalEditScreenViewModel.eatsJournalEntriesResult[listViewItemIndex],
                      onDeletePressed: ({required int eatsJournalEntryId}) async {
                        bool deleted = await _eatsJournalEditScreenViewModel.deleteEatsJournalEntry(id: eatsJournalEntryId);

                        if (deleted) {
                          _eatsJournalEditScreenViewModel.getEatsJournalEntries();
                        }
                      },
                      deleteIconColor: colorScheme.primary,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _getLocalizedMeal({required Meal? meal, required BuildContext context}) {
    String localized = OpenEatsJournalStrings.emptyString;

    if (meal == null) {
      localized = AppLocalizations.of(context)!.whole_day;
    } else if (meal == Meal.breakfast) {
      localized = AppLocalizations.of(context)!.breakfast_capital;
    } else if (meal == Meal.lunch) {
      localized = AppLocalizations.of(context)!.lunch_capital;
    } else if (meal == Meal.dinner) {
      localized = AppLocalizations.of(context)!.dinner_capital;
    } else if (meal == Meal.snacks) {
      localized = AppLocalizations.of(context)!.snacks_capital;
    }

    return localized;
  }
}
