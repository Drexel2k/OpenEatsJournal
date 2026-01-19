import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";

class SettingsScreenPageApp extends StatelessWidget {
  const SettingsScreenPageApp({super.key, required SettingsScreenViewModel settingsViewModel}) : _settingsViewModel = settingsViewModel;

  final SettingsScreenViewModel _settingsViewModel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.dark_mode, style: textTheme.titleSmall)),
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
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.language, style: textTheme.titleSmall)),
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
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.export_import),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: Duration(seconds: 60),
                      message: AppLocalizations.of(context)!.database_import_hint,
                      child: Icon(Icons.help_outline),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await _settingsViewModel.exportDatabase();
                      },
                      child: Text(AppLocalizations.of(context)!.export_data),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        bool import = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!.warning),
                              content: Text(AppLocalizations.of(context)!.importing_data),
                              actions: <Widget>[
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
                            );
                          },
                        );

                        if (import) {
                          bool result = await _settingsViewModel.importDatabase();
                          if (!result) {
                            await showDialog(
                              context: AppGlobal.navigatorKey.currentContext!,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.file_not_found),
                                  content: Text(AppLocalizations.of(context)!.no_file_to_import),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(AppLocalizations.of(context)!.ok),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            await showDialog(
                              context: AppGlobal.navigatorKey.currentContext!,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.import_succeeded),
                                  content: Text(AppLocalizations.of(context)!.database_imported),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(AppLocalizations.of(context)!.ok),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                          }
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.import_data),
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
