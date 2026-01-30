import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/about_screen.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/widgets/transparent_choice_chip.dart";
import "package:url_launcher/url_launcher.dart";

class SettingsScreenPageApp extends StatelessWidget {
  const SettingsScreenPageApp({super.key, required SettingsScreenViewModel settingsViewModel}) : _settingsViewModel = settingsViewModel;

  final SettingsScreenViewModel _settingsViewModel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.about_label, style: textTheme.titleSmall)),
              Flexible(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () async {
                    await showDialog<void>(
                      useSafeArea: true,
                      barrierDismissible: false,
                      context: AppGlobal.navigatorKey.currentContext!,
                      builder: (BuildContext contextBuilder) {
                        double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.075;
                        double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.045;

                        return Dialog(
                          insetPadding: EdgeInsets.fromLTRB(dialogHorizontalPadding, dialogVerticalPadding, dialogHorizontalPadding, dialogVerticalPadding),
                          child: AboutScreen(contactData: _settingsViewModel.contactData, appVersion: _settingsViewModel.appVersion),
                        );
                      },
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.about),
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
                    Text(AppLocalizations.of(context)!.contribute, style: textTheme.titleSmall),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: Duration(seconds: 60),
                      message: AppLocalizations.of(context)!.contribute_tooltip,
                      child: Icon(Icons.help_outline),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: OpenEatsJournalStrings.github,
                            style: TextStyle(color: colorScheme.primary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(Uri.parse(_settingsViewModel.githubUrl), mode: LaunchMode.platformDefault);
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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
                    Text(AppLocalizations.of(context)!.donate, style: textTheme.titleSmall),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: Duration(seconds: 60),
                      message: AppLocalizations.of(context)!.welcome_message_donation_voluntary,
                      child: Icon(Icons.help_outline),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: OpenEatsJournalStrings.donationPlatform,
                            style: TextStyle(color: colorScheme.primary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(Uri.parse(_settingsViewModel.donateUrl), mode: LaunchMode.platformDefault);
                              },
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(thickness: 2, height: 20),
          SizedBox(height: 10),
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
                      onChanged: (value) {
                        _settingsViewModel.darkMode.value = value;
                      },
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
                        bool success = await _settingsViewModel.exportDatabase();

                        String title = AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.export_succeeded;
                        String content = AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.database_exported;

                        if (!success) {
                          title = AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.export_not_succeeded;
                          content = AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.database_not_exported;
                        }

                        await showDialog(
                          context: AppGlobal.navigatorKey.currentContext!,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(title),
                              content: Text(content),
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

                            //closes app
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
