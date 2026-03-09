class StandardFoodDataCsvHeaderInfo {
  StandardFoodDataCsvHeaderInfo({required DateTime lastStandardFoodDataChangeDate, required int firstDataRowIndex})
    : _lastStandardFoodDataChangeDate = lastStandardFoodDataChangeDate,
      _firstDataRowIndex = firstDataRowIndex;

  final DateTime _lastStandardFoodDataChangeDate;
  final int _firstDataRowIndex;

  DateTime get lastStandardFoodDataChangeDate => _lastStandardFoodDataChangeDate;
  int get firstDataRowIndex => _firstDataRowIndex;
}
