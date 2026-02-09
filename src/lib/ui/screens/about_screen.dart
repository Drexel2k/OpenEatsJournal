import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required String languageCode, required String contactData, required String appVersion, required bool useStagingServices})
    : _languageCode = languageCode,
      _contactData = contactData,
      _appVersion = appVersion,
      _useStagingServices = useStagingServices;

  final String _languageCode;
  final String _contactData;
  final String _appVersion;
  final bool _useStagingServices;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    double dialogHorizontalPadding = MediaQuery.sizeOf(context).width * 0.1;
    double dialogVerticalPadding = MediaQuery.sizeOf(context).height * 0.06;

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.about)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("${OpenEatsJournalStrings.openEatsJournal} v$_appVersion", style: textTheme.headlineMedium),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.welcome_message_welcome, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: textTheme.bodyLarge,
                      children: [
                        TextSpan(text: "${AppLocalizations.of(context)!.welcome_message_license_1} ", style: textTheme.bodyLarge),
                        TextSpan(
                          text: AppLocalizations.of(context)!.agplv3_license,
                          style: TextStyle(color: colorScheme.primary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              String licenseText = await rootBundle.loadString("assets/agpl-3.0.txt");

                              await showDialog(
                                context: AppGlobal.navigatorKey.currentContext!,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.fromLTRB(
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                    ),
                                    title: Text(AppLocalizations.of(context)!.agplv3_license),
                                    content: SingleChildScrollView(child: Text(licenseText)),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(AppLocalizations.of(context)!.ok),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                        ),
                        TextSpan(
                          text: "${_languageCode == OpenEatsJournalStrings.en ? "" : " "}${AppLocalizations.of(context)!.welcome_message_license_2} ",
                          style: textTheme.bodyLarge,
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.privacy_statement,
                          style: TextStyle(color: colorScheme.primary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              String privacyText = await rootBundle.loadString("assets/privacy.txt");
                              privacyText = privacyText.replaceAll(OpenEatsJournalStrings.contactDataPlaceholder, _contactData);

                              await showDialog(
                                context: AppGlobal.navigatorKey.currentContext!,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.fromLTRB(
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                      dialogHorizontalPadding,
                                      dialogVerticalPadding,
                                    ),
                                    title: Text(AppLocalizations.of(context)!.privacy_statement_capital),
                                    content: SingleChildScrollView(child: Text(privacyText)),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(AppLocalizations.of(context)!.ok),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                        ),
                        TextSpan(
                          text: "${_languageCode == OpenEatsJournalStrings.en ? "" : " "}${AppLocalizations.of(context)!.welcome_message_license_3}",
                          style: textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.welcome_message_data, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.welcome_message_data_storage, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.welcome_message_local_database, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.welcome_message_stay_healthy, style: textTheme.bodyLarge, textAlign: TextAlign.center),

                  SizedBox(height: 30),
                  Row(children: [Text(AppLocalizations.of(context)!.debug_info, style: textTheme.bodySmall)]),
                  Row(children: [Text("useStagingServices: $_useStagingServices", style: textTheme.bodySmall)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
