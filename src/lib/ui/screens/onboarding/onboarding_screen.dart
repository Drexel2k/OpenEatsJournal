import "package:flutter/material.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_1.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_2.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_3.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_4.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_5.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:provider/provider.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required VoidCallback onboardingFinishedCallback}) : _onboardingFinishedCallback = onboardingFinishedCallback;

  final VoidCallback _onboardingFinishedCallback;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageViewController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingScreenViewModel>(
      builder: (context, onboardingScreenViewModel, _) => ValueListenableBuilder(
        valueListenable: onboardingScreenViewModel.currentPageIndex,
        builder: (_, _, _) {
          String pageTitle = OpenEatsJournalStrings.emptyString;
          if (onboardingScreenViewModel.currentPageIndex.value == 1) {
            pageTitle = AppLocalizations.of(context)!.about_this_app;
          } else if (onboardingScreenViewModel.currentPageIndex.value == 2) {
            pageTitle = AppLocalizations.of(context)!.tell_about_yourself;
          } else if (onboardingScreenViewModel.currentPageIndex.value == 3) {
            pageTitle = AppLocalizations.of(context)!.your_targets;
          } else if (onboardingScreenViewModel.currentPageIndex.value == 4) {
            pageTitle = AppLocalizations.of(context)!.support_this_app;
          }

          return Scaffold(
            appBar: onboardingScreenViewModel.currentPageIndex.value > 0
                ? AppBar(
                    leading: IconButton(
                      icon: BackButtonIcon(),
                      onPressed: () {
                        _movePageIndex(onboardingScreenViewModel: onboardingScreenViewModel, steps: -1);
                      },
                    ),
                    title: Text(pageTitle),
                  )
                : null,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: PageView(
                  controller: _pageViewController,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    OnboardingScreenPage1(
                      onDone: () {
                        _movePageIndex(onboardingScreenViewModel: onboardingScreenViewModel, steps: 1);
                      },
                      darkMode: onboardingScreenViewModel.darkMode,
                      onboardingScreenViewModel: onboardingScreenViewModel,
                    ),
                    OnboardingScreenPage2(
                      onDone: () {
                        _movePageIndex(onboardingScreenViewModel: onboardingScreenViewModel, steps: 1);
                      },
                    ),
                    OnboardingScreenPage3(
                      onDone: () {
                        _movePageIndex(onboardingScreenViewModel: onboardingScreenViewModel, steps: 1);
                      },
                      onboardingScreenViewModel: onboardingScreenViewModel,
                    ),
                    OnboardingScreenPage4(
                      onDone: () {
                        _movePageIndex(onboardingScreenViewModel: onboardingScreenViewModel, steps: 1);
                      },
                      onboardingScreenViewModel: onboardingScreenViewModel,
                    ),
                    OnboardingScreenPage5(
                      onDone: () async {
                        await onboardingScreenViewModel.saveOnboardingData();
                        widget._onboardingFinishedCallback();
                        Navigator.pushReplacementNamed(AppGlobal.navigatorKey.currentContext!, OpenEatsJournalStrings.navigatorRouteEatsJournal);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _movePageIndex({required OnboardingScreenViewModel onboardingScreenViewModel, required int steps}) {
    onboardingScreenViewModel.currentPageIndex.value = onboardingScreenViewModel.currentPageIndex.value + steps;
    _pageViewController.animateToPage(onboardingScreenViewModel.currentPageIndex.value, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageViewController.dispose();

    super.dispose();
  }
}
