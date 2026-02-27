import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/weight_row.dart";
import "package:openeatsjournal/ui/widgets/weight_row_viewmodel.dart";
import "package:provider/provider.dart";

class WeightJournalEditScreen extends StatefulWidget {
  const WeightJournalEditScreen({super.key});

  @override
  State<WeightJournalEditScreen> createState() => _WeightJournalEditScreenState();
}

class _WeightJournalEditScreenState extends State<WeightJournalEditScreen> {
  @override
  void initState() {
    super.initState();

    WeightJournalEditScreenViewModel weightEditScreenViewModel = Provider.of<WeightJournalEditScreenViewModel>(context, listen: false);
    weightEditScreenViewModel.getWeightJournalEntries();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Consumer<WeightJournalEditScreenViewModel>(
      builder: (context, weightJournalEditScreenViewModel, _) => Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 0, 10),

        child: Column(
          children: [
            AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.weight_journal)),
            Expanded(
              child: ListenableBuilder(
                listenable: weightJournalEditScreenViewModel.weightEntriesChanged,
                builder: (_, _) {
                  return ListView.builder(
                    itemCount: weightJournalEditScreenViewModel.hasMore
                        ? weightJournalEditScreenViewModel.weightEntriesResult.length + 1
                        : weightJournalEditScreenViewModel.weightEntriesResult.length,
                    itemBuilder: (context, listViewItemIndex) {
                      if (listViewItemIndex >= weightJournalEditScreenViewModel.weightEntriesResult.length) {
                        if (!weightJournalEditScreenViewModel.isLoading) {
                          weightJournalEditScreenViewModel.getWeightJournalEntriesLoadMore();
                        }
                        return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                      }

                      return ChangeNotifierProvider(
                        create: (context) => WeightRowViewModel(
                          weight: weightJournalEditScreenViewModel.weightEntriesResult[listViewItemIndex].weight,
                          date: weightJournalEditScreenViewModel.weightEntriesResult[listViewItemIndex].date,
                          onWeightChange: ({required DateTime date, required double weight}) async {
                            await weightJournalEditScreenViewModel.setWeightJournalEntry(date: date, weight: weight);
                          },
                        ),
                        child: WeightRow(
                          //Without this key it sometimes happens that the old state is reused after call of
                          //weightJournalEditScreenViewModel.getWeightJournalEntries();. This may enable the user to delete the last weight journal entry...
                          key: UniqueKey(),
                          deleteEnabled: weightJournalEditScreenViewModel.weightEntriesResult.length > 1,
                          onDeletePressed: ({required DateTime date}) async {
                            bool deleted = await weightJournalEditScreenViewModel.deleteWeightJournalEntry(date: date);

                            if (deleted) {
                              weightJournalEditScreenViewModel.getWeightJournalEntries();
                            }
                          },
                          deleteIconColor: colorScheme.primary,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
