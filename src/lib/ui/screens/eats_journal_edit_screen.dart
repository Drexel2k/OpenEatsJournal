import "package:flutter/material.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/copy_target_screen.dart";
import "package:openeatsjournal/ui/screens/copy_target_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/entity_edited.dart";
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/utils/overlay_info.dart";
import "package:openeatsjournal/ui/widgets/eats_journal_entry_row.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";
import "package:provider/provider.dart";

class EatsJournalEditScreen extends StatefulWidget {
  const EatsJournalEditScreen({super.key});

  @override
  State<EatsJournalEditScreen> createState() => _EatsJournalEditScreenState();
}

class _EatsJournalEditScreenState extends State<EatsJournalEditScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final OverlayDisplay overlayDisplay = Provider.of<OverlayDisplay>(context, listen: false);

    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final double overlaySpacer = 170;

    return Consumer<EatsJournalEditScreenViewModel>(
      builder: (context, eatsJournalEditScreenViewModel, _) => Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 7, 10),

        child: ListenableBuilder(
          listenable: eatsJournalEditScreenViewModel.eatsJournalEntriesChanged,
          builder: (_, _) {
            return FutureBuilder<List<EatsJournalEntry>?>(
              future: eatsJournalEditScreenViewModel.eatsJournalEntriesResult,
              builder: (BuildContext context, AsyncSnapshot<List<EatsJournalEntry>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  throw StateError("Something went wrong: ${snapshot.error}");
                } else {
                  return Column(
                    children: [
                      AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.eats_journal)),
                      Row(
                        children: [
                          Text(
                            convert.dateFormatterDisplayLongDateOnly.format(eatsJournalEditScreenViewModel.currentJournalDate),
                            style: textTheme.titleMedium,
                          ),
                          Spacer(),
                          Text(
                            _getLocalizedMeal(meal: eatsJournalEditScreenViewModel.meal, context: context),
                            style: textTheme.titleMedium,
                          ),
                          SizedBox(width: 5),
                          snapshot.data != null
                              ? RoundOutlinedButton(
                                  onPressed: () async {
                                    CopyTargetScreenViewModel copyTargetScreenViewModel = CopyTargetScreenViewModel(
                                      currentDate: eatsJournalEditScreenViewModel.currentJournalDate,
                                      currentMeal: eatsJournalEditScreenViewModel.meal,
                                    );

                                    bool copy = await showDialog(
                                      useSafeArea: true,
                                      barrierDismissible: false,
                                      context: AppGlobal.navigatorKey.currentContext!,
                                      builder: (BuildContext contextBuilder) {
                                        double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.075;
                                        double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.045;

                                        return Dialog(
                                          insetPadding: EdgeInsets.fromLTRB(
                                            dialogHorizontalPadding,
                                            dialogVerticalPadding,
                                            dialogHorizontalPadding,
                                            dialogVerticalPadding,
                                          ),
                                          child: ChangeNotifierProvider<CopyTargetScreenViewModel>.value(
                                            value: copyTargetScreenViewModel,
                                            child: CopyTargetScreen(),
                                          ),
                                        );
                                      },
                                    );

                                    if (copy) {
                                      await eatsJournalEditScreenViewModel.copyEatsJournalEntries(
                                        eatsJournalEntries: snapshot.data!,
                                        toDate: copyTargetScreenViewModel.currentDate.value,
                                        toMeal: copyTargetScreenViewModel.currentMeal.value,
                                      );

                                      overlayDisplay.enqueue(
                                        overlayInfo: OverlayInfo(
                                          message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.eats_journal_entries_copied,
                                          spacer: overlaySpacer,
                                        ),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.copy),
                                )
                              : SizedBox(),
                        ],
                      ),
                      SizedBox(height: 5),
                      snapshot.data != null
                          ? Expanded(
                              child: ListView(
                                children: _getEatsJournalEntries(
                                  eatsJournalEntries: snapshot.data!,
                                  eatsJournalEditScreenViewModel: eatsJournalEditScreenViewModel,
                                  colorScheme: colorScheme,
                                  overlayDisplay: overlayDisplay,
                                  overlaySpacer: overlaySpacer,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  );
                }
              },
            );
          },
        ),
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
    super.dispose();
  }

  List<Widget> _getEatsJournalEntries({
    required List<EatsJournalEntry> eatsJournalEntries,
    required EatsJournalEditScreenViewModel eatsJournalEditScreenViewModel,
    required ColorScheme colorScheme,
    required OverlayDisplay overlayDisplay,
    required double overlaySpacer,
  }) {
    List<Widget> result = List.empty(growable: true);

    for (EatsJournalEntry entry in eatsJournalEntries) {
      result.add(
        EatsJournalEntryRow(
          key: UniqueKey(),
          eatsJournalEntry: entry,
          onPressed: ({required EatsJournalEntry eatsJournalEntry}) async {
            if (eatsJournalEntry.food != null) {
              EntityEdited? eatsJournalEntryEdited =
                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEntryEdit, arguments: eatsJournalEntry) as EntityEdited?;

              if (eatsJournalEntryEdited != null) {
                overlayDisplay.enqueue(
                  overlayInfo: OverlayInfo(
                    message: eatsJournalEntryEdited.originalId == null
                        ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_added
                        : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_updated,
                    spacer: overlaySpacer,
                  ),
                );
              }
            } else {
              EntityEdited? eatsJournalEntryEdited =
                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteQuickEntryEdit, arguments: eatsJournalEntry) as EntityEdited?;

              if (eatsJournalEntryEdited != null) {
                overlayDisplay.enqueue(
                  overlayInfo: OverlayInfo(
                    message: eatsJournalEntryEdited.originalId == null
                        ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                        : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                    spacer: overlaySpacer,
                  ),
                );
              }
            }

            eatsJournalEditScreenViewModel.getEatsJournalEntries();
          },
          onDeletePressed: ({required int eatsJournalEntryId}) async {
            bool deleted = await eatsJournalEditScreenViewModel.deleteEatsJournalEntry(id: eatsJournalEntryId);

            if (deleted) {
              overlayDisplay.enqueue(
                overlayInfo: OverlayInfo(
                  message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.eats_journal_entry_deleted,
                  spacer: overlaySpacer,
                ),
              );

              eatsJournalEditScreenViewModel.getEatsJournalEntries();
            } else {
              overlayDisplay.enqueue(
                overlayInfo: OverlayInfo(
                  message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.eats_journal_entry_to_delete,
                  spacer: overlaySpacer,
                ),
              );
            }
          },

          onDuplicatePressed: ({required EatsJournalEntry eatsJournalEntry}) async {
            await eatsJournalEditScreenViewModel.duplicateEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);

            overlayDisplay.enqueue(
              overlayInfo: OverlayInfo(
                message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.eats_journal_entry_duplicated,
                spacer: overlaySpacer,
              ),
            );

            eatsJournalEditScreenViewModel.getEatsJournalEntries();
          },
          deleteIconColor: colorScheme.primary,
        ),
      );

      result.add(SizedBox(height: 5));
    }

    return result;
  }
}
