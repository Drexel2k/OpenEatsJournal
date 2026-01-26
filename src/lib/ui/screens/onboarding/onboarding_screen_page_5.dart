import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:url_launcher/url_launcher.dart";

class OnboardingScreenPage5 extends StatelessWidget {
  const OnboardingScreenPage5({super.key, required onDone, required OnboardingScreenViewModel onboardingScreenViewModel})
    : _onDone = onDone,
      _onboardingScreenViewModel = onboardingScreenViewModel;

  final OnboardingScreenViewModel _onboardingScreenViewModel;
  final VoidCallback _onDone;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyLarge,
                      children: [
                        TextSpan(text: "${AppLocalizations.of(context)!.welcome_message_contribute_1} ", style: textTheme.bodyLarge),
                        TextSpan(
                          text: "github",
                          style: TextStyle(color: colorScheme.primary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(Uri.parse(_onboardingScreenViewModel.githubUrl), mode: LaunchMode.platformDefault);
                            },
                        ),
                        TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.localeName == OpenEatsJournalStrings.de ? " " : ""}${AppLocalizations.of(context)!.welcome_message_contribute_2}",
                          style: textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.welcome_message_donation, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyLarge,
                      children: [
                        TextSpan(text: AppLocalizations.of(context)!.welcome_message_onetime, style: textTheme.bodyLarge),
                        TextSpan(
                          text: "paypal",
                          style: TextStyle(color: colorScheme.primary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(Uri.parse(_onboardingScreenViewModel.paypalUrl), mode: LaunchMode.platformDefault);
                            },
                        ),
                        TextSpan(text: ".", style: textTheme.bodyLarge),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyLarge,
                      children: [
                        TextSpan(text: AppLocalizations.of(context)!.welcome_message_reoccuring, style: textTheme.bodyLarge),
                        TextSpan(
                          text: OpenEatsJournalStrings.donationPlatform,
                          style: TextStyle(color: colorScheme.primary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(Uri.parse(_onboardingScreenViewModel.donateUrl), mode: LaunchMode.platformDefault);
                            },
                        ),
                        TextSpan(text: ".", style: textTheme.bodyLarge),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(AppLocalizations.of(context)!.welcome_message_donation_voluntary, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text("Don't be evil.", style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  Spacer(),
                  FilledButton(
                    onPressed: () {
                      _onDone();
                    },
                    child: Text(AppLocalizations.of(context)!.finish),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
