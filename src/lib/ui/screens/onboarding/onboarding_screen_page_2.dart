import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";

class OnboardingScreenPage2 extends StatefulWidget {
  const OnboardingScreenPage2({super.key, required onDone}) : _onDone = onDone;

  final VoidCallback _onDone;

  @override
  State<OnboardingScreenPage2> createState() => _OnboardingScreenPage2State();
}

class _OnboardingScreenPage2State extends State<OnboardingScreenPage2> {
  bool _understood = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    double understandTextMaxWidth = MediaQuery.sizeOf(context).width - 75;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!.welcome_message_data, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.welcome_message_data_storage, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.welcome_message_local_database, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  SizedBox(height: 40),
                  Text(AppLocalizations.of(context)!.welcome_message_stay_healthy, style: textTheme.bodyLarge, textAlign: TextAlign.center),
                  Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Checkbox(
                        value: _understood,
                        onChanged: (value) {
                          setState(() {
                            _understood = value ?? false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Column(
                        children: [
                          SizedBox(height: 9),
                          Container(
                            constraints: BoxConstraints(maxWidth: understandTextMaxWidth),
                            child: Text(
                              AppLocalizations.of(context)!.understood,
                              style: textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                    ],
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
