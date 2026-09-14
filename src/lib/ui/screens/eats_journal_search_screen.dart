import "package:flutter/material.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/copy_target_screen.dart";
import "package:openeatsjournal/ui/screens/copy_target_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_search_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/eats_journal_enty_search_result_entry.dart";
import "package:openeatsjournal/ui/utils/eats_journal_enty_search_result_status_code.dart";
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/utils/overlay_info.dart";
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
    final OverlayDisplay overlayDisplay = Provider.of<OverlayDisplay>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;
    double overlaySpacer = 170;

    return Consumer<EatsJournalSearchScreenViewModel>(
      builder: (contextBuilder1, eatsJournalSearchScreenViewModel, _) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: BackButton(
            onPressed: () {
              Navigator.pop(contextBuilder1, false);
            },
          ),
          title: Text(AppLocalizations.of(contextBuilder1)!.search),
          actions: [
            Builder(
              builder: (contextBuilder2) => IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  Scaffold.of(contextBuilder2).openEndDrawer();
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
              builder: (BuildContext contextBuilder3) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Row(
                    children: [
                      BackButton(
                        style: IconButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: () {
                          Scaffold.of(contextBuilder3).closeEndDrawer();
                        },
                      ),
                      Text(AppLocalizations.of(contextBuilder3)!.filter, style: textTheme.titleMedium),
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
                            Expanded(child: Text(AppLocalizations.of(contextBuilder3)!.search_from, style: textTheme.titleSmall)),
                            Flexible(
                              child: SettingsTextField(
                                controller: _searchFromController,
                                onTap: () async {
                                  DateTime? dateSelected = await showDatePicker(
                                    context: contextBuilder3,
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
                            Expanded(child: Text(AppLocalizations.of(contextBuilder3)!.entry_type, style: textTheme.titleSmall)),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ValueListenableBuilder(
                                    valueListenable: eatsJournalSearchScreenViewModel.quickEntrySelected,
                                    builder: (contextBuilder4, _, _) {
                                      return TransparentChoiceChip(
                                        label: AppLocalizations.of(contextBuilder4)!.quick_entry,
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
                                    builder: (contextBuilder5, _, _) {
                                      return TransparentChoiceChip(
                                        label: AppLocalizations.of(contextBuilder5)!.food_entry,
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
                      hintText: AppLocalizations.of(contextBuilder1)!.search_food,
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
              ValueListenableBuilder(
                valueListenable: eatsJournalSearchScreenViewModel.errorCode,
                builder: (_, _, _) {
                  if (eatsJournalSearchScreenViewModel.errorCode.value != null) {
                    TextStyle? style = _getRedText(textTheme);

                    if (eatsJournalSearchScreenViewModel.errorCode.value == 1) {
                      return Text(AppLocalizations.of(contextBuilder1)!.enter_search_criteria, style: style);
                    } else {
                      return Text(AppLocalizations.of(contextBuilder1)!.search_unexpected_error, style: style);
                    }
                  } else {
                    return SizedBox();
                  }
                },
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: eatsJournalSearchScreenViewModel.searchResultChanged,
                  builder: (_, _) {
                    return ListView.separated(
                      separatorBuilder: (_, index) => SizedBox(height: 5),
                      itemCount: eatsJournalSearchScreenViewModel.searchResults.length,
                      itemBuilder: (contextBuilder6, index) {
                        final EatsJournalEntrySearchResultEntry entry = eatsJournalSearchScreenViewModel.searchResults[index];

                        if (entry.eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.offlineNoResult) {
                          return Center(child: Text(AppLocalizations.of(contextBuilder6)!.no_search_result));
                        }

                        if (entry.eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.dateHeader) {
                          return Text(convert.dateFormatterDisplayLongDateOnly.format(entry.date!));
                        }

                        if (entry.eatsJournalEntrySearchResultStatusCode == EatsJournalEntrySearchResultStatusCode.searchResult) {
                          return EatsJournalEntrySearchResultRow(
                            key: UniqueKey(),
                            eatsJournalEntry: entry.eatsJournalEntry!,
                            onPressed: ({required EatsJournalEntry eatsJournalEntry}) async {
                              if (eatsJournalEntry.food != null) {
                                await Navigator.pushNamed(contextBuilder6, OpenEatsJournalStrings.navigatorRouteFoodEntryEdit, arguments: eatsJournalEntry);
                              } else {
                                await Navigator.pushNamed(contextBuilder6, OpenEatsJournalStrings.navigatorRouteQuickEntryEdit, arguments: eatsJournalEntry);
                              }

                              eatsJournalSearchScreenViewModel.search();
                            },
                            onCopyPressed: ({required EatsJournalEntry eatsJournalEntry}) async {
                              CopyTargetScreenViewModel copyTargetScreenViewModel = CopyTargetScreenViewModel(
                                currentDate: eatsJournalSearchScreenViewModel.currentJournalDate,
                                currentMeal: eatsJournalSearchScreenViewModel.meal,
                              );

                              bool copy = await showDialog(
                                useSafeArea: true,
                                barrierDismissible: false,
                                context: AppGlobal.navigatorKey.currentContext!,
                                builder: (BuildContext contextBuilder) {
                                  double dialogHorizontalPadding = MediaQuery.sizeOf(contextBuilder).width * 0.075;
                                  double dialogVerticalPadding = MediaQuery.sizeOf(contextBuilder).height * 0.045;

                                  return Dialog(
                                    insetPadding: EdgeInsets.fromLTRB(
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                    ),
                                    child: ChangeNotifierProvider<CopyTargetScreenViewModel>.value(value: copyTargetScreenViewModel, child: CopyTargetScreen()),
                                  );
                                },
                              );

                              if (copy) {
                                await eatsJournalSearchScreenViewModel.copyEatsJournalEntry(
                                  eatsJournalEntry: eatsJournalEntry,
                                  toDate: copyTargetScreenViewModel.currentDate.value,
                                  toMeal: copyTargetScreenViewModel.currentMeal.value,
                                );

                                overlayDisplay.enqueue(
                                  overlayInfo: OverlayInfo(
                                    message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.eats_journal_entry_copied,
                                    spacer: overlaySpacer,
                                  ),
                                );
                              }

                              eatsJournalSearchScreenViewModel.currentDate = copyTargetScreenViewModel.currentDate.value;
                              await Navigator.pushNamedAndRemoveUntil(
                                AppGlobal.navigatorKey.currentContext!,
                                OpenEatsJournalStrings.navigatorRouteEatsJournal,
                                (Route<dynamic> route) => false,
                              );
                            },

                            onGotoPressed: ({required DateTime date}) async {
                              eatsJournalSearchScreenViewModel.currentDate = date;

                              await Navigator.pushNamedAndRemoveUntil(
                                AppGlobal.navigatorKey.currentContext!,
                                OpenEatsJournalStrings.navigatorRouteEatsJournal,
                                (Route<dynamic> route) => false,
                              );
                            },
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

  TextStyle? _getRedText(TextTheme textTheme) {
    TextStyle? style = textTheme.bodyMedium;
    if (style != null) {
      style = style.copyWith(color: Colors.red);
    } else {
      style = TextStyle(color: Colors.red);
    }
    return style;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
