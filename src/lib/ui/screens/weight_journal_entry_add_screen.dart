import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/weight_journal_entry_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";

class WeightJournalEntryAddScreen extends StatefulWidget {
  const WeightJournalEntryAddScreen({super.key, required WeightJournalEntryAddScreenViewModel weightJournalEntryAddScreenViewModel, required DateTime date})
    : _weightJournalEntryAddScreenViewModel = weightJournalEntryAddScreenViewModel,
      _date = date;

  final WeightJournalEntryAddScreenViewModel _weightJournalEntryAddScreenViewModel;
  final DateTime _date;

  @override
  State<WeightJournalEntryAddScreen> createState() => _WeightJournalEntryAddScreenState();
}

class _WeightJournalEntryAddScreenState extends State<WeightJournalEntryAddScreen> {
  late WeightJournalEntryAddScreenViewModel _weightJournalEntryAddScreenViewModel;

  final TextEditingController _weightController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _weightJournalEntryAddScreenViewModel = widget._weightJournalEntryAddScreenViewModel;
    _weightController.text = ConvertValidate.getCleanDoubleString(doubleValue: _weightJournalEntryAddScreenViewModel.lastValidWeightDisplay);

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
          AppBar(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            automaticallyImplyLeading: false,
            title: Text(AppLocalizations.of(context)!.add_weight_journal_entry),
          ),
          Row(
            children: [
              Expanded(flex: 3, child: Text(ConvertValidate.dateFormatterDisplayLongDateOnly.format(widget._date), style: textTheme.titleSmall)),
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
                            if (ConvertValidate.decimalHasMoreThan1Fraction(decimalstring: text)) {
                              return oldValue;
                            }

                            return newValue;
                          } else {
                            return oldValue;
                          }
                        }),
                      ],
                      focusNode: _weightFocusNode,
                      onTap: () {
                        //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                        //effect.
                        if (!_weightFocusNode.hasFocus) {
                          _weightController.selection = TextSelection(baseOffset: 0, extentOffset: _weightController.text.length);
                        }
                      },
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
          SizedBox(height: 10),
          Text(AppLocalizations.of(context)!.weight_impact),
          ValueListenableBuilder(
            valueListenable: _weightJournalEntryAddScreenViewModel.weightValid,
            builder: (_, _, _) {
              if (!_weightJournalEntryAddScreenViewModel.weightValid.value) {
                return Text(
                  "${AppLocalizations.of(context)!.input_invalid_value(AppLocalizations.of(context)!.weight_capital, _weightJournalEntryAddScreenViewModel.lastValidWeightDisplay)} ${AppLocalizations.of(context)!.valid_weight} (1-${ConvertValidate.getCleanDoubleString(doubleValue: ConvertValidate.getDisplayWeightKg(weightKg: ConvertValidate.maxWeightKg.toDouble()))}).",
                  style: textTheme.labelSmall!.copyWith(color: Colors.red),
                );
              } else {
                return SizedBox();
              }
            },
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

  @override
  void dispose() {
    widget._weightJournalEntryAddScreenViewModel.dispose();
    if (widget._weightJournalEntryAddScreenViewModel != _weightJournalEntryAddScreenViewModel) {
      _weightJournalEntryAddScreenViewModel.dispose();
    }

    _weightController.dispose();
    _weightFocusNode.dispose();

    super.dispose();
  }
}
