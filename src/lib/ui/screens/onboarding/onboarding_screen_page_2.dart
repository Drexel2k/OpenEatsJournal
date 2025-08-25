import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";

class OnboardingScreenPage2 extends StatefulWidget {
  const OnboardingScreenPage2({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreenPage2> createState() => _OnboardingScreenPage2State();
}

class _OnboardingScreenPage2State extends State<OnboardingScreenPage2> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(AppLocalizations.of(context)!.welcome_message_2, style: textTheme.bodyLarge, textAlign: TextAlign.center),
        SizedBox(height: 10),
        Text(AppLocalizations.of(context)!.welcome_message_3, style: textTheme.bodyLarge, textAlign: TextAlign.center),
        SizedBox(height: 10),
        Text(AppLocalizations.of(context)!.welcome_message_4, style: textTheme.bodyLarge, textAlign: TextAlign.center),
        SizedBox(height: 10),
        Text(AppLocalizations.of(context)!.welcome_message_5, style: textTheme.bodyLarge, textAlign: TextAlign.center),
        SizedBox(height: 10),
        Text(AppLocalizations.of(context)!.welcome_message_6, style: textTheme.bodyLarge, textAlign: TextAlign.center),
        Spacer(),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            AppLocalizations.of(context)!.understood,
            style: textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          value: _understood,
          onChanged: (value) {
            setState(() {
              _understood = value ?? false;
            });
          },
        ),
        FilledButton(
          onPressed: () {
            if (!_understood) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.must_understood),
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

            widget.onDone();
          },
          child: Text(AppLocalizations.of(context)!.agree_proceed),
        ),
      ],
    );
  }
}
