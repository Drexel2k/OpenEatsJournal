import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_svg/svg.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";

class OnboardingScreenPage1 extends StatefulWidget {
  const OnboardingScreenPage1({super.key, required VoidCallback onDone, required bool darkMode, required OnboardingScreenViewModel onboardingScreenViewModel})
    : _onDone = onDone,
      _darkMode = darkMode,
      _onboardingScreenViewModel = onboardingScreenViewModel;

  final OnboardingScreenViewModel _onboardingScreenViewModel;
  final VoidCallback _onDone;
  final bool _darkMode;

  @override
  State<OnboardingScreenPage1> createState() => _OnboardingScreenPage1State();
}

class _OnboardingScreenPage1State extends State<OnboardingScreenPage1> {
  bool _licenseAgreed = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    String logoPath = "assets/openeatsjournal_logo_lightmode.svg";
    if (widget._darkMode) {
      logoPath = "assets/openeatsjournal_logo_darkmode.svg";
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SvgPicture.asset(logoPath, semanticsLabel: "App Logo", height: 150, width: 150),
                  Text(style: textTheme.headlineMedium, OpenEatsJournalStrings.openEatsJournal),
                  SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context)!.welcome, style: textTheme.headlineSmall),
                      Icon(Icons.waving_hand_outlined),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.welcome_message_welcome, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  Spacer(),
                  RichText(
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
                                    title: Text(AppLocalizations.of(context)!.agplv3_license),
                                    content: SingleChildScrollView(child: Text(licenseText)),
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
                        ),
                        TextSpan(text: "${widget._onboardingScreenViewModel.languageCode == OpenEatsJournalStrings.en ? "" : " "}${AppLocalizations.of(context)!.welcome_message_license_2} ", style: textTheme.bodyLarge),
                        TextSpan(
                          text: AppLocalizations.of(context)!.privacy_statement,
                          style: TextStyle(color: colorScheme.primary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              String privacyText = await rootBundle.loadString("assets/privacy.txt");
                              privacyText = privacyText.replaceAll(OpenEatsJournalStrings.contactDataPlaceholder, widget._onboardingScreenViewModel.contactData);

                              await showDialog(
                                context: AppGlobal.navigatorKey.currentContext!,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.privacy_statement),
                                    content: SingleChildScrollView(child: Text(privacyText)),
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
                        ),
                        TextSpan(text: "${widget._onboardingScreenViewModel.languageCode == OpenEatsJournalStrings.en ? "" : " "}${AppLocalizations.of(context)!.welcome_message_license_3}", style: textTheme.bodyLarge),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(AppLocalizations.of(context)!.license_agree, style: textTheme.labelLarge, textAlign: TextAlign.center),
                    value: _licenseAgreed,
                    onChanged: (value) {
                      setState(() {
                        _licenseAgreed = value ?? false;
                      });
                    },
                  ),
                  FilledButton(
                    onPressed: () {
                      if (!_licenseAgreed) {
                        SnackBar snackBar = SnackBar(
                          content: Text(AppLocalizations.of(context)!.license_must_agree),
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)!.close,
                            onPressed: () {
                              //Click on SnackbarAction closes the SnackBar,
                              //nothing else to do here...
                            },
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        return;
                      }

                      widget._onDone();
                    },
                    child: Text(AppLocalizations.of(context)!.agree_proceed),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
