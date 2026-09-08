import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/eats_journal_entry_type.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/eats_journal_search_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:provider/provider.dart";

class EatsJournalSearchScreen extends StatefulWidget {
  const EatsJournalSearchScreen({super.key});

  @override
  State<EatsJournalSearchScreen> createState() => _EatsJournalSearchScreen();
}

class _EatsJournalSearchScreen extends State<EatsJournalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<EatsJournalSearchScreenViewModel>(
      builder: (context, viewModel, _) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          title: Text(AppLocalizations.of(context)!.search),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: SafeArea(
            child: Builder(
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Row(
                    children: [
                      BackButton(
                        style: IconButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: () {
                          Scaffold.of(context).closeEndDrawer();
                        },
                      ),
                      Text("Filter", style: textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: viewModel.dateFrom,
                          builder: (_, DateTime from, _) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text("From"),
                              subtitle: Text(convert.dateFormatterDisplayLongDateOnly.format(from)),
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: from,
                                  firstDate: DateTime.utc(1900),
                                  lastDate: DateTime.utc(9999),
                                );
                                if (picked != null) {
                                  viewModel.dateFrom.value = picked;
                                }
                              },
                            );
                          },
                        ),
                        Divider(height: 32),
                        Text("Entry Type", style: Theme.of(context).textTheme.titleSmall),
                        ValueListenableBuilder(
                          valueListenable: viewModel.selectedTypes,
                          builder: (_, Set<EatsJournalEntryType> selected, _) {
                            return Column(
                              children: [
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(AppLocalizations.of(context)!.quick_entry),
                                  value: selected.contains(EatsJournalEntryType.quickEntry),
                                  onChanged: (_) {
                                    viewModel.toggleType(EatsJournalEntryType.quickEntry);
                                  },
                                ),
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(AppLocalizations.of(context)!.food),
                                  value: selected.contains(EatsJournalEntryType.foodEntry),
                                  onChanged: (_) {
                                    viewModel.toggleType(EatsJournalEntryType.foodEntry);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OpenEatsJournalTextField(
                      controller: _searchController,
                      hintText: AppLocalizations.of(context)!.search_food,
                      decorationSuffixIcon: IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: Icon(Icons.clear),
                        padding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) async {
                        viewModel.searchQuery.value = value;
                      },
                    ),
                  ),
                  SizedBox(width: 5),
                  RoundOutlinedButton(
                    onPressed: () async {
                      viewModel.searchQuery.value = _searchController.text;
                    },
                    child: Icon(Icons.search),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListenableBuilder(
                  listenable: viewModel.searchResultsChanged,
                  builder: (_, _) {
                    if (viewModel.isSearching) {
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    }

                    if (viewModel.searchResults.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context)!.no_data));
                    }

                    return ListView.builder(
                      itemCount: viewModel.searchResults.length,
                      itemBuilder: (context, index) {
                        final EatsJournalEntry entry = viewModel.searchResults[index];
                        return ListTile(
                          leading: Icon(entry.food == null ? Icons.speed : Icons.lunch_dining),
                          title: Text(entry.name),
                          subtitle: Text(convert.dateFormatterDisplayLongDateOnly.format(entry.entryDate)),
                          onTap: () {
                            Navigator.pop(context, true);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
