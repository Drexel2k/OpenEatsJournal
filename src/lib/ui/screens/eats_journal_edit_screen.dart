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
import "package:openeatsjournal/ui/utils/ui_helpers.dart";
import "package:openeatsjournal/ui/widgets/eats_journal_entry_row.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class EatsJournalEditScreen extends StatefulWidget {
  const EatsJournalEditScreen({super.key, required EatsJournalEditScreenViewModel eatsJournalEditScreenViewModel})
    : _eatsJournalEditScreenViewModel = eatsJournalEditScreenViewModel;

  final EatsJournalEditScreenViewModel _eatsJournalEditScreenViewModel;

  @override
  State<EatsJournalEditScreen> createState() => _EatsJournalEditScreenState();
}

class _EatsJournalEditScreenState extends State<EatsJournalEditScreen> with SingleTickerProviderStateMixin {
  late EatsJournalEditScreenViewModel _eatsJournalEditScreenViewModel;
  late AnimationController _animationController;

  @override
  void initState() {
    _eatsJournalEditScreenViewModel = widget._eatsJournalEditScreenViewModel;
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _eatsJournalEditScreenViewModel.getEatsJournalEntries();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 7, 10),

      child: Column(
        children: [
          AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.eats_journal)),
          Row(
            children: [
              Text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(_eatsJournalEditScreenViewModel.currentJournalDate), style: textTheme.titleMedium),
              Spacer(),
              Text(
                _getLocalizedMeal(meal: _eatsJournalEditScreenViewModel.meal, context: context),
                style: textTheme.titleMedium,
              ),
              SizedBox(width: 5),
              RoundOutlinedButton(
                onPressed: () async {
                  CopyTargetScreenViewModel copyTargetScreenViewModel = CopyTargetScreenViewModel(
                    currentDate: _eatsJournalEditScreenViewModel.currentJournalDate,
                    currentMeal: _eatsJournalEditScreenViewModel.meal,
                  );

                  bool copy = await showDialog(
                    useSafeArea: true,
                    barrierDismissible: false,
                    context: AppGlobal.navigatorKey.currentContext!,
                    builder: (BuildContext contextBuilder) {
                      double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.075;
                      double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.045;

                      return Dialog(
                        insetPadding: EdgeInsets.fromLTRB(dialogHorizontalPadding, dialogVerticalPadding, dialogHorizontalPadding, dialogVerticalPadding),
                        child: CopyTargetScreen(copyTargetScreenViewModel: copyTargetScreenViewModel),
                      );
                    },
                  );

                  if (copy) {
                    await _eatsJournalEditScreenViewModel.copyEatsJournalEntries(
                      toDate: copyTargetScreenViewModel.currentDate.value,
                      toMeal: copyTargetScreenViewModel.currentMeal.value,
                    );
                    
                    UiHelpers.showOverlay(
                      context: AppGlobal.navigatorKey.currentContext!,
                      displayText: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.eats_journal_entries_copied,
                      animationController: _animationController,
                    );
                  }
                },
                child: Icon(Icons.copy),
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

                    return Column(
                      children: [
                        EatsJournalEntryRow(
                          key: UniqueKey(),
                          eatsJournalEntry: _eatsJournalEditScreenViewModel.eatsJournalEntriesResult[listViewItemIndex],
                          onPressed: ({required EatsJournalEntry eatsJournalEntry}) async {
                            if (eatsJournalEntry.food != null) {
                              EntityEdited? eatsJournalEntryEdited =
                                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFoodEntryEdit, arguments: eatsJournalEntry)
                                      as EntityEdited?;

                              if (eatsJournalEntryEdited != null) {
                                UiHelpers.showOverlay(
                                  context: AppGlobal.navigatorKey.currentContext!,
                                  displayText: eatsJournalEntryEdited.originalId == null
                                      ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_added
                                      : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.food_entry_updated,
                                  animationController: _animationController,
                                );
                              }
                            } else {
                              EntityEdited? eatsJournalEntryEdited =
                                  await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteQuickEntryEdit, arguments: eatsJournalEntry)
                                      as EntityEdited?;

                              if (eatsJournalEntryEdited != null) {
                                UiHelpers.showOverlay(
                                  context: AppGlobal.navigatorKey.currentContext!,
                                  displayText: eatsJournalEntryEdited.originalId == null
                                      ? AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_added
                                      : AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.quick_entry_updated,
                                  animationController: _animationController,
                                );
                              }
                            }

                            _eatsJournalEditScreenViewModel.getEatsJournalEntries();
                          },
                          onDeletePressed: ({required int eatsJournalEntryId}) async {
                            bool deleted = await _eatsJournalEditScreenViewModel.deleteEatsJournalEntry(id: eatsJournalEntryId);

                            if (deleted) {
                              _eatsJournalEditScreenViewModel.getEatsJournalEntries();
                            }
                          },

                          onDuplicatePressed: ({required EatsJournalEntry eatsJournalEntry}) async {
                            await _eatsJournalEditScreenViewModel.duplicateEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);

                            _eatsJournalEditScreenViewModel.getEatsJournalEntries();
                          },
                          deleteIconColor: colorScheme.primary,
                        ),
                        SizedBox(height: 5),
                      ],
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
    if (widget._eatsJournalEditScreenViewModel != _eatsJournalEditScreenViewModel) {
      _eatsJournalEditScreenViewModel.dispose();
    }

    super.dispose();
  }
}
