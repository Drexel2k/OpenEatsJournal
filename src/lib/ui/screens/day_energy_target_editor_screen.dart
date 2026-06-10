import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/day_energy_target_editor_screen_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart";
import "package:provider/provider.dart";

class DayEnergyTargetEditorScreen extends StatefulWidget {
  const DayEnergyTargetEditorScreen({super.key, required DateTime date}) : _date = date;

  final DateTime _date;

  @override
  State<DayEnergyTargetEditorScreen> createState() => _DayEnergyTargetEditorScreen();
}

class _DayEnergyTargetEditorScreen extends State<DayEnergyTargetEditorScreen> {
  final TextEditingController _energyTargetController = TextEditingController();
  final FocusNode _energyTargetFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final DayEnergyTargetEditorScreenViewModel dayEnergyTargetEditorScreenViewModel = Provider.of<DayEnergyTargetEditorScreenViewModel>(context, listen: false);

    _energyTargetController.text = convert.numberFomatterInt.format(dayEnergyTargetEditorScreenViewModel.lastValidEnergyTargetDisplay);
  }

  @override
  Widget build(BuildContext context) {
    final ConvertValidate convert = Provider.of<ConvertValidate>(context, listen: false);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<DayEnergyTargetEditorScreenViewModel>(
      builder: (context, dayEnergyTargetEditorScreenViewModel, _) => Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Color.fromARGB(0, 0, 0, 0),
              automaticallyImplyLeading: false,
              title: Text(AppLocalizations.of(context)!.edit_day_energy_target(convert.getLocalizedEnergyUnit(context: context))),
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "${AppLocalizations.of(context)!.target} ${convert.dateFormatterDisplayLongDateOnly.format(widget._date)} (${convert.getLocalizedEnergyUnitAbbreviated(context: context)})",
                    style: textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ValueListenableBuilder(
                    valueListenable: dayEnergyTargetEditorScreenViewModel.energyTargetDisplay,
                    builder: (_, _, _) {
                      return OpenEatsJournalTextField(
                        controller: _energyTargetController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final String text = newValue.text.trim();
                            if (text.isEmpty) {
                              return newValue;
                            }

                            num? doubleValue = convert.numberFomatterDouble1DecimalDigit.tryParse(text);
                            if (doubleValue != null) {
                              if (convert.decimalHasMoreThan1DecimalDigit(decimalstring: text)) {
                                return oldValue;
                              }

                              return newValue;
                            } else {
                              return oldValue;
                            }
                          }),
                        ],
                        focusNode: _energyTargetFocusNode,
                        onTap: () {
                          //selectAllOnFocus works only when virtual keyboard comes up, changing textfields when keyboard is already on screen has no
                          //effect.
                          if (!_energyTargetFocusNode.hasFocus) {
                            _energyTargetController.selection = TextSelection(baseOffset: 0, extentOffset: _energyTargetController.text.length);
                          }
                        },
                        onChanged: (value) {
                          int? intValue = int.tryParse(value);
                          dayEnergyTargetEditorScreenViewModel.energyTargetDisplay.value = intValue;

                          if (intValue != null) {
                            _energyTargetController.text = convert.numberFomatterInt.format(intValue);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: dayEnergyTargetEditorScreenViewModel.energyTargetValid,
              builder: (_, _, _) {
                if (!dayEnergyTargetEditorScreenViewModel.energyTargetValid.value) {
                  return Text(
                    "${AppLocalizations.of(context)!.input_invalid_value(convert.getLocalizedEnergyUnit(context: context), convert.numberFomatterInt.format(dayEnergyTargetEditorScreenViewModel.lastValidEnergyTargetDisplay))} ${AppLocalizations.of(context)!.valid_energy_target(convert.getLocalizedEnergyUnit(context: context), "(1-${convert.getCleanDoubleString1DecimalDigit(doubleValue: convert.getDisplayEnergy(energyKJ: ConvertValidate.maxKJoulePerDay).toDouble())})")}",
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
      ),
    );
  }

  @override
  void dispose() {
    _energyTargetController.dispose();
    _energyTargetFocusNode.dispose();

    super.dispose();
  }
}
