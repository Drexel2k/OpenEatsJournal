import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/error_handlers.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";

class WeightJournalEntryAddScreen extends StatelessWidget {
  WeightJournalEntryAddScreen({super.key, required WeightJournalEntryAddScreenViewModel weightJournalEntryAddScreenViewModel, required DateTime date})
    : _weightJournalEntryAddScreenViewModel = weightJournalEntryAddScreenViewModel,
      _date = date;

  final WeightJournalEntryAddScreenViewModel _weightJournalEntryAddScreenViewModel;
  final DateTime _date;
  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    _weightController.text = ConvertValidate.getCleanDoubleString(doubleValue: _weightJournalEntryAddScreenViewModel.lastValidWeight);

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.add_weight_journal_entry)),
          Row(
            children: [
              Expanded(flex: 3, child: Text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(_date), style: textTheme.titleSmall)),
              Expanded(
                flex: 2,
                child: ValueListenableBuilder(
                  valueListenable: _weightJournalEntryAddScreenViewModel.weight,
                  builder: (_, _, _) {
                    return OpenEatsJournalTextField(
                      controller: _weightController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final String text = newValue.text.trim();
                          if (text.isEmpty) {
                            return newValue;
                          }

                          num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(text);
                          if (doubleValue != null) {
                            return newValue;
                          } else {
                            return oldValue;
                          }
                        }),
                      ],
                      onChanged: (value) {
                        num? doubleValue = ConvertValidate.numberFomatterDouble.tryParse(value);
                        _weightJournalEntryAddScreenViewModel.weight.value = doubleValue as double?;

                        if (doubleValue != null) {
                          _weightController.text = ConvertValidate.getCleanDoubleEditString(doubleValue: doubleValue, doubleValueString: value);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: _weightJournalEntryAddScreenViewModel.weightValid,
            builder: (_, _, _) {
              if (!_weightJournalEntryAddScreenViewModel.weightValid.value) {
                return Text(
                  AppLocalizations.of(context)!.input_invalid(AppLocalizations.of(context)!.weight, _weightJournalEntryAddScreenViewModel.lastValidWeight),
                  style: textTheme.labelSmall!.copyWith(color: Colors.red),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          Row(
            children: [
              Spacer(),
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () async {
                  try {
                    Navigator.pop(context, false);
                  } on Exception catch (exc, stack) {
                    await ErrorHandlers.showException(context: context, exception: exc, stackTrace: stack);
                  } on Error catch (error, stack) {
                    await ErrorHandlers.showException(context: context, error: error, stackTrace: stack);
                  }
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () async {
                  try {
                    Navigator.pop(context, true);
                  } on Exception catch (exc, stack) {
                    await ErrorHandlers.showException(context: context, exception: exc, stackTrace: stack);
                  } on Error catch (error, stack) {
                    await ErrorHandlers.showException(context: context, error: error, stackTrace: stack);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
