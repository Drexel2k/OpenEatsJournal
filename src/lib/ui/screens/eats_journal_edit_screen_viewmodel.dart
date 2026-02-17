import "package:flutter/foundation.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/meal.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/external_trigger_change_notifier.dart";

class EatsJournalEditScreenViewModel extends ChangeNotifier {
  EatsJournalEditScreenViewModel({Meal? meal, required JournalRepository journalRepository, required SettingsRepository settingsRepository})
    : _meal = meal,
      _journalRepository = journalRepository,
      _settingsRepository = settingsRepository;

  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;
  final Meal? _meal;

  final List<EatsJournalEntry> _eatsJournalEntriesResult = [];
  bool _isLoading = false;
  final ValueNotifier<bool> _showInitialLoading = ValueNotifier(false);

  final ExternalTriggerChangedNotifier _eatsJournalEntriesChanged = ExternalTriggerChangedNotifier();

  ExternalTriggerChangedNotifier get eatsJournalEntriesChanged => _eatsJournalEntriesChanged;

  List<EatsJournalEntry> get eatsJournalEntriesResult => _eatsJournalEntriesResult;
  bool get isLoading => _isLoading;
  ValueNotifier<bool> get showInitialLoading => _showInitialLoading;

  DateTime get currentJournalDate => _settingsRepository.currentJournalDate.value;
  Meal? get meal => _meal;

  Future<void> getEatsJournalEntries() async {
    _initDataLoad();
    await _journalRepository.getEatsJournalEntries(date: _settingsRepository.currentJournalDate.value, meal: _meal).then((List<EatsJournalEntry>? result) {
      _loadFinished();

      if (result != null) {
        _eatsJournalEntriesResult.addAll(result);
      }
    });

    _eatsJournalEntriesChanged.notify();
  }

  void _initDataLoad() {
    _isLoading = true;
    _eatsJournalEntriesResult.clear();
    _showInitialLoading.value = true;
    _eatsJournalEntriesChanged.notify();
  }

  void _loadFinished() {
    _isLoading = false;
    _showInitialLoading.value = false;
  }

  Future<bool> deleteEatsJournalEntry({required int id}) async {
    return await _journalRepository.deleteEatsJournalEntry(id: id);
  }

  Future<void> duplicateEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await _journalRepository.duplicateEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);
  }

  Future<void> copyEatsJournalEntries({required DateTime toDate, required int toMeal}) async {
    await _journalRepository.saveOnceDayNutritionTarget(
      entryDate: toDate,
      dayTargetKJoule: _settingsRepository.getTargetKJouleForDay(day: toDate),
    );
    await _journalRepository.copyEatsJournalEntries(eatsJournalEntries: _eatsJournalEntriesResult, toDate: toDate, toMeal: toMeal);
  }

  @override
  void dispose() {
    _showInitialLoading.dispose();
    _eatsJournalEntriesChanged.dispose();

    super.dispose();
  }
}
