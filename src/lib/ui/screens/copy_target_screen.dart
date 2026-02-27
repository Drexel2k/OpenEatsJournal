import "package:flutter/material.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/copy_target_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:provider/provider.dart";

class CopyTargetScreen extends StatefulWidget {
  const CopyTargetScreen({super.key});

  @override
  State<CopyTargetScreen> createState() => _CopyTargetScreenScreenState();
}

class _CopyTargetScreenScreenState extends State<CopyTargetScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<CopyTargetScreenViewModel>(
      builder: (context, copyTargetScreenViewModel, _) => Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.copy_target_title)),
            Text(AppLocalizations.of(context)!.copy_target_text),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(AppLocalizations.of(context)!.date, style: textTheme.titleSmall)),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: copyTargetScreenViewModel.currentDate,
                    builder: (_, _, _) {
                      return OutlinedButton(
                        onPressed: () async {
                          DateTime? date = await _selectDate(initialDate: copyTargetScreenViewModel.currentDate.value, context: context);
                          if (date != null) {
                            _changeDate(copyTargetScreenViewModel: copyTargetScreenViewModel, date: date);
                          }
                        },
                        style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          ConvertValidate.dateFormatterDisplayLongDateOnly.format(copyTargetScreenViewModel.currentDate.value),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(AppLocalizations.of(context)!.meal, style: textTheme.titleSmall)),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: copyTargetScreenViewModel.currentMeal,
                    builder: (_, _, _) {
                      return OpenEatsJournalDropdownMenu<int>(
                        onSelected: (int? mealValue) {
                          _changeMealValue(copyTargetScreenViewModel: copyTargetScreenViewModel, mealValue: mealValue!);
                        },
                        dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(
                          context: context,
                          addOnTop: copyTargetScreenViewModel.originalMeal == null ? AppLocalizations.of(context)!.as_is : null,
                        ),
                        initialSelection: copyTargetScreenViewModel.currentMeal.value,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Spacer(),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.ok),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeMealValue({required CopyTargetScreenViewModel copyTargetScreenViewModel, required int mealValue}) {
    copyTargetScreenViewModel.currentMeal.value = mealValue;
  }

  Future<DateTime?> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    return await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));
  }

  void _changeDate({required CopyTargetScreenViewModel copyTargetScreenViewModel, required DateTime date}) {
    copyTargetScreenViewModel.currentDate.value = date;
  }
}
