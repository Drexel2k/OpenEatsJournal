import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openeatsjournal/domain/measurement_unit.dart';
import 'package:openeatsjournal/domain/utils/convert_validate.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/widgets/food_unit_editor_viewmodel.dart';
import 'package:openeatsjournal/ui/widgets/open_eats_journal_textfield.dart';
import 'package:openeatsjournal/ui/widgets/round_outlined_button.dart';

class FoodUnitEditor extends StatelessWidget {
  FoodUnitEditor({super.key, required FoodUnitEditorViewModel foodUnitEditorViewModel, required int index})
    : _foodUnitEditorViewModel = foodUnitEditorViewModel,
      _index = index;

  final FoodUnitEditorViewModel _foodUnitEditorViewModel;

  final int _index;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    _nameController.text = _foodUnitEditorViewModel.name.value;
    _amountController.text = _foodUnitEditorViewModel.amount.value != null
        ? ConvertValidate.numberFomatterInt.format(_foodUnitEditorViewModel.amount.value)
        : OpenEatsJournalStrings.emptyString;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: ReorderableDragStartListener(
            index: _index,
            child: const Padding(padding: EdgeInsets.fromLTRB(0, 6, 0, 0), child: Icon(Icons.drag_handle)),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: OpenEatsJournalTextField(
              controller: _nameController,
              onChanged: (value) {
                _foodUnitEditorViewModel.name.value = value;
              },
            ),
          ),
        ),
        Column(
          children: [
            SizedBox(
              width: 60,
              child: OpenEatsJournalTextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(signed: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  int? intValue = int.tryParse(value);
                  _foodUnitEditorViewModel.amount.value = intValue;
                  if (intValue != null) {
                    _amountController.text = ConvertValidate.numberFomatterInt.format(intValue);
                  }
                },
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _foodUnitEditorViewModel.amountValid,
              builder: (_, _, _) {
                if (!_foodUnitEditorViewModel.amountValid.value) {
                  return SizedBox(
                    width: 60,
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.input_invalid(AppLocalizations.of(context)!.kjoule, ConvertValidate.numberFomatterInt.format(_foodUnitEditorViewModel.foodUnitAmount)),
                      style: textTheme.labelMedium!.copyWith(color: Colors.red),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ],
        ),
        SizedBox(
          width: 50,
          child: ListenableBuilder(
            listenable: _foodUnitEditorViewModel.measurementUnitSwitchButtonChanged,
            builder: (_, _) {
              return RoundOutlinedButton(
                onPressed: _foodUnitEditorViewModel.measurementUnitSwitchButtonEnabled.value
                    ? () {
                        _foodUnitEditorViewModel.currentMeasurementUnit.value = _foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                            ? MeasurementUnit.milliliter
                            : MeasurementUnit.gram;
                      }
                    : null,
                child: Text(
                  _foodUnitEditorViewModel.currentMeasurementUnit.value == MeasurementUnit.gram
                      ? AppLocalizations.of(context)!.gram_abbreviated
                      : AppLocalizations.of(context)!.milliliter_abbreviated,
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: 52,
          child: ValueListenableBuilder(
            valueListenable: _foodUnitEditorViewModel.defaultFoodUnit,
            builder: (_, _, _) {
              return Switch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: _foodUnitEditorViewModel.defaultFoodUnit.value,
                onChanged: (value) => _foodUnitEditorViewModel.defaultFoodUnit.value = value,
              );
            },
          ),
        ),
        SizedBox(
          width: 50,
          child: RoundOutlinedButton(
            onPressed: () {
              _foodUnitEditorViewModel.removeFoodUnit();
            },
            child: Icon(Icons.delete),
          ),
        ),
      ],
    );
  }
}
