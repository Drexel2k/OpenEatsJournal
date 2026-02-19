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
      _settingsRepository = settingsRepository,
      _eatsJournalEntriesResult = journalRepository.getEatsJournalEntries(date: settingsRepository.currentJournalDate.value, meal: meal);

  final JournalRepository _journalRepository;
  final SettingsRepository _settingsRepository;
  final Meal? _meal;
  final ExternalTriggerChangedNotifier _eatsJournalEntriesChanged = ExternalTriggerChangedNotifier();

  Future<List<EatsJournalEntry>?> _eatsJournalEntriesResult;

  DateTime get currentJournalDate => _settingsRepository.currentJournalDate.value;
  Meal? get meal => _meal;
  ExternalTriggerChangedNotifier get eatsJournalEntriesChanged => _eatsJournalEntriesChanged;

  Future<List<EatsJournalEntry>?> get eatsJournalEntriesResult => _eatsJournalEntriesResult;

  Future<bool> deleteEatsJournalEntry({required int id}) async {
    return await _journalRepository.deleteEatsJournalEntry(id: id);
  }

  Future<void> duplicateEatsJournalEntry({required EatsJournalEntry eatsJournalEntry}) async {
    await _journalRepository.duplicateEatsJournalEntry(eatsJournalEntry: eatsJournalEntry);
  }

  Future<void> copyEatsJournalEntries({required List<EatsJournalEntry> eatsJournalEntries, required DateTime toDate, required int toMeal}) async {
    if (eatsJournalEntries.isNotEmpty) {
      await _journalRepository.saveOnceDayNutritionTarget(
        entryDate: toDate,
        dayTargetKJoule: _settingsRepository.getTargetKJouleForDay(day: toDate),
      );

      await _journalRepository.copyEatsJournalEntries(eatsJournalEntries: eatsJournalEntries, toDate: toDate, toMeal: toMeal);
    }
  }

  void getEatsJournalEntries() {
    _eatsJournalEntriesResult = _journalRepository.getEatsJournalEntries(date: _settingsRepository.currentJournalDate.value, meal: _meal);
    _eatsJournalEntriesChanged.notify();
  }

  @override
  void dispose() {
    _eatsJournalEntriesChanged.dispose();

    super.dispose();
  }
}
