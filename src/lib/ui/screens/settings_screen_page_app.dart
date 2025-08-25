import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_viewmodel.dart";
import "package:openeatsjournal/ui/utils/oej_strings.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class SettingsScreenPageApp extends StatelessWidget {
  const SettingsScreenPageApp({super.key, required SettingsViewModel settingsViewModel})
    : _settingsViewModel = settingsViewModel;

  final SettingsViewModel _settingsViewModel;

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
                          selected: _settingsViewModel.languageCode.value == OejStrings.en,
                          onSelected: (bool selected) {
                            _settingsViewModel.languageCode.value = OejStrings.en;
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
                          selected: _settingsViewModel.languageCode.value == OejStrings.de,
                          onSelected: (bool selected) {
                            _settingsViewModel.languageCode.value = OejStrings.de;
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
