import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/weight_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/weight_row.dart";
import "package:openeatsjournal/ui/widgets/weight_row_viewmodel.dart";

class WeightJournalEditScreen extends StatelessWidget {
  const WeightJournalEditScreen({super.key, required WeightJournalEditScreenViewModel weightEditScreenViewModel}) : _weightEditScreenViewModel = weightEditScreenViewModel;

  final WeightJournalEditScreenViewModel _weightEditScreenViewModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    _weightEditScreenViewModel.getWeightJournalEntries();
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 10),

      child: Column(
        children: [
          AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.weight_journal)),
          Expanded(
            child: ListenableBuilder(
              listenable: _weightEditScreenViewModel.weightEntriesChanged,
              builder: (_, _) {
                return ListView.builder(
                  itemCount: _weightEditScreenViewModel.hasMore
                      ? _weightEditScreenViewModel.weightEntriesResult.length + 1
                      : _weightEditScreenViewModel.weightEntriesResult.length,
                  itemBuilder: (context, listViewItemIndex) {
                    if (listViewItemIndex >= _weightEditScreenViewModel.weightEntriesResult.length) {
                      if (!_weightEditScreenViewModel.isLoading) {
                        _weightEditScreenViewModel.getWeightJournalEntriesLoadMore();
                      }
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    }

                    return WeightRow(
                      weightRowViewModel: WeightRowViewModel(weight: _weightEditScreenViewModel.weightEntriesResult[listViewItemIndex].weight),
                      date: _weightEditScreenViewModel.weightEntriesResult[listViewItemIndex].date,
                      onWeightEdit: ({required DateTime date, required double weight}) async {
                        await _weightEditScreenViewModel.setWeightJournalEntry(date: date, weight: weight);
                      },
                      deleteEnabled: _weightEditScreenViewModel.weightEntriesResult.length > 1,
                      onDeletePressed: ({required DateTime date}) async {
                        bool deleted = await _weightEditScreenViewModel.deleteWeightJournalEntry(date: date);

                        if (deleted) {
                          _weightEditScreenViewModel.getWeightJournalEntries();
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
}
