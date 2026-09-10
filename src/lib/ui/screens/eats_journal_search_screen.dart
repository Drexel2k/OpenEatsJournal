import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/eats_journal_search_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/eats_journal_enty_search_result_entry.dart";
import "package:openeatsjournal/ui/utils/eats_journal_enty_search_result_status_code.dart";
import "package:openeatsjournal/ui/widgets/eats_journal_entry_search_result_row.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";
import "package:provider/provider.dart";

class EatsJournalSearchScreen extends StatefulWidget {
  const EatsJournalSearchScreen({super.key});

  @override
  State<EatsJournalSearchScreen> createState() => _EatsJournalSearchScreen();
}

class _EatsJournalSearchScreen extends State<EatsJournalSearchScreen> {
  final TextEditingController _searchFromController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);

    final EatsJournalSearchScreenViewModel eatsJournalSearchScreenViewModel = Provider.of<EatsJournalSearchScreenViewModel>(context, listen: false);
    _searchFromController.text = convert.dateFormatterDisplayLongDateOnly.format(eatsJournalSearchScreenViewModel.searchFrom.value);
  }

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<EatsJournalSearchScreenViewModel>(
      builder: (context, eatsJournalSearchScreenViewModel, _) => Scaffold(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              bottomLeft: Radius.circular(28),
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
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
                      Text(AppLocalizations.of(context)!.filter, style: textTheme.titleMedium),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(AppLocalizations.of(context)!.search_from, style: textTheme.titleSmall)),
                            Flexible(
                              child: SettingsTextField(
                                controller: _searchFromController,
                                onTap: () async {
                                  DateTime? dateSelected = await showDatePicker(
                                    context: context,
                                    initialDate: eatsJournalSearchScreenViewModel.searchFrom.value,
                                    firstDate: DateTime.utc(1900),
                                    lastDate: DateTime.utc(9999),
                                  );

                                  if (dateSelected != null) {
                                    _searchFromController.text = convert.dateFormatterDisplayLongDateOnly.format(dateSelected);
                                    eatsJournalSearchScreenViewModel.searchFrom.value = dateSelected;
                                  }
                                },
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(AppLocalizations.of(context)!.entry_type, style: textTheme.titleSmall)),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: eatsJournalSearchScreenViewModel.quickEntrySelected,
                                    builder: (contextBuilder, _, _) {
                                      return TransparentChoiceChip(
                                        label: AppLocalizations.of(contextBuilder)!.quick_entry,
                                        selected: eatsJournalSearchScreenViewModel.quickEntrySelected.value,
                                        onSelected: (bool selected) {
                                          eatsJournalSearchScreenViewModel.quickEntrySelected.value = selected;
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  ValueListenableBuilder(
                                    valueListenable: eatsJournalSearchScreenViewModel.foodEntrySelected,
                                    builder: (contextBuilder, _, _) {
                                      return TransparentChoiceChip(
                                        label: AppLocalizations.of(contextBuilder)!.food_entry,
                                        selected: eatsJournalSearchScreenViewModel.foodEntrySelected.value,
                                        onSelected: (bool selected) {
                                          eatsJournalSearchScreenViewModel.foodEntrySelected.value = selected;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                      onChanged: (value) {
                        eatsJournalSearchScreenViewModel.searchText.value = value.trim();
                      },
                      onSubmitted: (value) async {
                        eatsJournalSearchScreenViewModel.search();
                      },
                    ),
                  ),
                  SizedBox(width: 5),
                  RoundOutlinedButton(
                    onPressed: () async {
                      eatsJournalSearchScreenViewModel.search();
                    },
                    child: Icon(Icons.search),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListenableBuilder(
                  listenable: eatsJournalSearchScreenViewModel.searchResultChanged,
                  builder: (_, _) {
                    return ListView.builder(
                      itemCount: eatsJournalSearchScreenViewModel.searchResults.length,
                      itemBuilder: (context, index) {
                        final EatsJournalEntrySearchResultEntry entry = eatsJournalSearchScreenViewModel.searchResults[index];

                        if (entry.eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.offlineNoResult) {
                          return Center(child: Text(AppLocalizations.of(context)!.no_search_result));
                        }

                        if (entry.eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.searchResult) {
                          return EatsJournalEntrySearchResultRow(
                            key: UniqueKey(),
                            eatsJournalEntry: entry.eatsJournalEntry!,
                            onPressed: ({required EatsJournalEntry eatsJournalEntry}) async {
                              if (eatsJournalEntry.food != null) {
                                await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEntryEdit, arguments: eatsJournalEntry);
                              } else {
                                await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteQuickEntryEdit, arguments: eatsJournalEntry);
                              }

                              eatsJournalSearchScreenViewModel.search();
                            },
                            onCopyPressed: ({required int eatsJournalEntryId}) async {},

                            onGotoPressed: ({required EatsJournalEntry eatsJournalEntry}) async {},
                          );
                        }

                        if (entry.eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.offlineMoreResults) {
                          if (!entry.moreRequested!) {
                            entry.moreRequested = true;
                            eatsJournalSearchScreenViewModel.getMoreResults();
                          }

                          return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                        }

                        //will never happen, but function must return a widget on all paths
                        return SizedBox();
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
