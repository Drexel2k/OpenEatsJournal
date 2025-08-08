import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";

class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({super.key, required this.onDone, required this.darkMode});

  final VoidCallback onDone;
  final bool darkMode;

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1> {
  bool _licenseAgreed = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    
    String logoPath = "assets/openeatsjournal_logo_lightmode.svg";
    if (widget.darkMode) {
      logoPath = "assets/openeatsjournal_logo_darkmode.svg";
    }

    return Column(
      children: [
        SvgPicture.asset(
          logoPath,
          semanticsLabel: "App Logo",
          height: 150,
          width: 150,
          ),
        Text(
          style: textTheme.headlineMedium,
          "Open Eats Journal"),
        SizedBox(height: 10.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.welcome, style: textTheme.headlineSmall),
            Icon(Icons.waving_hand_outlined)
          ],
        ),
        SizedBox(height: 12.0),
        Text(AppLocalizations.of(context)!.welcome_message_1,
          style: textTheme.bodyLarge, textAlign: TextAlign.center
        ),
        Spacer(),
        Text(AppLocalizations.of(context)!.welcome_message_7,
          style: textTheme.bodyLarge, textAlign: TextAlign.center
        ),
        SizedBox(height: 12.0),
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            AppLocalizations.of(context)!.license_agree,
            style: textTheme.labelLarge,
            textAlign: TextAlign.center,
            ),
          value: _licenseAgreed, onChanged:  (value) { setState(() {
                _licenseAgreed = value ?? false;
              }
            ); 
          }
        ),
        FilledButton (onPressed: () {
            if(!_licenseAgreed) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.license_must_agree),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.close,
                  onPressed: () {
                    //Click on SnackbarAction closes the SnackBar,
                    //nothing else to do here...
                  },            
                )
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              return;
            }

            widget.onDone();
          },
          child: Text(AppLocalizations.of(context)!.agree_proceed))
      ]
    );
  }
}