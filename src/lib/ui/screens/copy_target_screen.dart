import "package:flutter/material.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/copy_target_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";

class CopyTargetScreen extends StatefulWidget {
  const CopyTargetScreen({super.key, required CopyTargetScreenViewModel copyTargetScreenViewModel}) : _copyTargetScreenViewModel = copyTargetScreenViewModel;

  final CopyTargetScreenViewModel _copyTargetScreenViewModel;

  @override
  State<CopyTargetScreen> createState() => _CopyTargetScreenScreenState();
}

class _CopyTargetScreenScreenState extends State<CopyTargetScreen> {
  late CopyTargetScreenViewModel _copyTargetScreenViewModel;
  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _copyTargetScreenViewModel = widget._copyTargetScreenViewModel;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
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
                  valueListenable: _copyTargetScreenViewModel.currentDate,
                  builder: (_, _, _) {
                    return OutlinedButton(
                      onPressed: () async {
                        DateTime? date = await _selectDate(initialDate: _copyTargetScreenViewModel.currentDate.value, context: context);
                        if (date != null) {
                          _changeDate(date: date);
                        }
                      },
                      style: OutlinedButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        ConvertValidate.dateFormatterDisplayLongDateOnly.format(_copyTargetScreenViewModel.currentDate.value),
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
                  valueListenable: _copyTargetScreenViewModel.currentMeal,
                  builder: (_, _, _) {
                    return OpenEatsJournalDropdownMenu<int>(
                      onSelected: (int? mealValue) {
                        _changeMealValue(mealValue: mealValue!);
                      },
                      dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(
                        context: context,
                        addOnTop: _copyTargetScreenViewModel.originalMeal == null ? AppLocalizations.of(context)!.as_is : null,
                      ),
                      initialSelection: _copyTargetScreenViewModel.currentMeal.value,
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
    );
  }

  void _changeMealValue({required int mealValue}) {
    _copyTargetScreenViewModel.currentMeal.value = mealValue;
  }

  Future<DateTime?> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    return await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime(1900), lastDate: DateTime(9999));
  }

  void _changeDate({required DateTime date}) {
    _copyTargetScreenViewModel.currentDate.value = date;
  }
}
