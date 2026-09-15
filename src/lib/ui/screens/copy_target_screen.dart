import "package:flutter/material.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/copy_target_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/localized_drop_down_entries.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_dropdown_menu.dart";
import "package:openeatsjournal/ui/widgets/settings_textfield.dart";
import "package:provider/provider.dart";

class CopyTargetScreen extends StatefulWidget {
  const CopyTargetScreen({super.key});

  @override
  State<CopyTargetScreen> createState() => _CopyTargetScreenScreenState();
}

class _CopyTargetScreenScreenState extends State<CopyTargetScreen> {
  final TextEditingController _targetDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final CopyTargetScreenViewModel copyTargetScreenViewModel = Provider.of<CopyTargetScreenViewModel>(context, listen: false);

    _targetDateController.text = convert.dateFormatterDisplayMediumDateOnly.format(copyTargetScreenViewModel.targetDate.value);
  }

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
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
                    valueListenable: copyTargetScreenViewModel.targetDate,
                    builder: (_, _, _) {
                      return SettingsTextField(
                        controller: _targetDateController,
                        onTap: () async {
                          DateTime? date = await _selectDate(initialDate: copyTargetScreenViewModel.targetDate.value, context: context);
                          if (date != null) {
                            _changeTargetDate(convert, date, copyTargetScreenViewModel);
                          }
                        },
                        readOnly: true,
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
                    valueListenable: copyTargetScreenViewModel.targetMeal,
                    builder: (_, _, _) {
                      return OpenEatsJournalDropdownMenu<int>(
                        onSelected: (int? mealValue) {
                          _changeTargetMeal(copyTargetScreenViewModel: copyTargetScreenViewModel, mealValue: mealValue!);
                        },
                        dropdownMenuEntries: LocalizedDropDownEntries.getMealDropDownMenuEntries(
                          context: context,
                          addOnTop: copyTargetScreenViewModel.originalMeal == null ? AppLocalizations.of(context)!.as_is : null,
                        ),
                        initialSelection: copyTargetScreenViewModel.targetMeal.value,
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

  void _changeTargetDate(ConvertValidate convert, DateTime date, CopyTargetScreenViewModel copyTargetScreenViewModel) {
    _targetDateController.text = convert.dateFormatterDisplayMediumDateOnly.format(date);
    copyTargetScreenViewModel.targetDate.value = date;
  }

  void _changeTargetMeal({required CopyTargetScreenViewModel copyTargetScreenViewModel, required int mealValue}) {
    copyTargetScreenViewModel.targetMeal.value = mealValue;
  }

  Future<DateTime?> _selectDate({required DateTime initialDate, required BuildContext context}) async {
    return await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime.utc(1900), lastDate: DateTime.utc(9999));
  }
}
