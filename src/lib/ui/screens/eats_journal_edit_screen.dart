import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/eats_journal_entry_row.dart";

class EatsJournalEditScreen extends StatefulWidget {
  const EatsJournalEditScreen({super.key, required EatsJournalEditScreenViewModel eatsJournalEditScreenViewModel})
    : _eatsJournalEditScreenViewModel = eatsJournalEditScreenViewModel;

  final EatsJournalEditScreenViewModel _eatsJournalEditScreenViewModel;

  @override
  State<EatsJournalEditScreen> createState() => _EatsJournalEditScreenState();
}

class _EatsJournalEditScreenState extends State<EatsJournalEditScreen> {
  @override
  Widget build(BuildContext context) {
    widget._eatsJournalEditScreenViewModel.getEatsJournalEntries();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 7, 10),

      child: Column(
        children: [
          AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.eats_journal)),
          Row(
            children: [
              Text(
                ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._eatsJournalEditScreenViewModel.currentJournalDate),
                style: textTheme.titleMedium,
              ),
              Spacer(),
              Text(
                _getLocalizedMeal(meal: widget._eatsJournalEditScreenViewModel.meal, context: context),
                style: textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 5),
          Expanded(
            child: ListenableBuilder(
              listenable: widget._eatsJournalEditScreenViewModel.eatsJournalEntriesChanged,
              builder: (_, _) {
                return ListView.builder(
                  itemCount: widget._eatsJournalEditScreenViewModel.eatsJournalEntriesResult.length,
                  itemBuilder: (context, listViewItemIndex) {
                    if (listViewItemIndex >= widget._eatsJournalEditScreenViewModel.eatsJournalEntriesResult.length) {
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    }

                    return EatsJournalEntryRow(
                      eatsJournalEntry: widget._eatsJournalEditScreenViewModel.eatsJournalEntriesResult[listViewItemIndex],
                      onPressed: ({required EatsJournalEntry eatsJournalEntry}) async {
                        if (eatsJournalEntry.food != null) {
                          await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEntryEdit, arguments: eatsJournalEntry);
                        } else {
                          await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteQuickEntryEdit, arguments: eatsJournalEntry);
                        }

                        widget._eatsJournalEditScreenViewModel.getEatsJournalEntries();
                      },
                      onDeletePressed: ({required int eatsJournalEntryId}) async {
                        bool deleted = await widget._eatsJournalEditScreenViewModel.deleteEatsJournalEntry(id: eatsJournalEntryId);

                        if (deleted) {
                          widget._eatsJournalEditScreenViewModel.getEatsJournalEntries();
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

  @override
  void dispose() {
    widget._eatsJournalEditScreenViewModel.dispose();

    super.dispose();
  }
}
