import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class SettingsScreenPageApp extends StatelessWidget {
  const SettingsScreenPageApp({super.key, required SettingsScreenViewModel settingsViewModel})
    : _settingsViewModel = settingsViewModel;

  final SettingsScreenViewModel _settingsViewModel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.dark_mode, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: ValueListenableBuilder(
                  valueListenable: _settingsViewModel.darkMode,
                  builder: (_, _, _) {
                    return Switch(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: _settingsViewModel.darkMode.value,
                      onChanged: (value) => _settingsViewModel.darkMode.value = value,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.language, style: textTheme.titleMedium)),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _settingsViewModel.languageCode,
                      builder: (_, _, _) {
                        return TransparentChoiceChip(
                          label: AppLocalizations.of(context)!.english,
                          selected: _settingsViewModel.languageCode.value == OpenEatsJournalStrings.en,
                          onSelected: (bool selected) {
                            _settingsViewModel.languageCode.value = OpenEatsJournalStrings.en;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    ValueListenableBuilder(
                      valueListenable: _settingsViewModel.languageCode,
                      builder: (_, _, _) {
                        return TransparentChoiceChip(
                          label: AppLocalizations.of(context)!.german,
                          selected: _settingsViewModel.languageCode.value == OpenEatsJournalStrings.de,
                          onSelected: (bool selected) {
                            _settingsViewModel.languageCode.value = OpenEatsJournalStrings.de;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
