import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class SettingsPageApp extends StatelessWidget {
  const SettingsPageApp({super.key, required SettingsViewModel settingsViewModel, required VoidCallback onDone})
    : _settingsViewModel = settingsViewModel,
      _onDone = onDone;

  final SettingsViewModel _settingsViewModel;
  final VoidCallback _onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Color.fromARGB(0, 0, 0, 123),
            title: Text(AppLocalizations.of(context)!.app_settings),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: _onDone,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new),
                        Text(AppLocalizations.of(context)!.personal_settings_linebreak),
                      ],
                    ),
                  ),
                  SizedBox(width: 5),
                  FilledButton(
                    onPressed: null,
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.app_settings_linebreak),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
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
                              selected: _settingsViewModel.languageCode.value == "en",
                              onSelected: (bool selected) {
                                _settingsViewModel.languageCode.value = "en";
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
                              selected: _settingsViewModel.languageCode.value == "de",
                              onSelected: (bool selected) {
                                _settingsViewModel.languageCode.value = "de";
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
        ],
      ),
    );
  }
}
