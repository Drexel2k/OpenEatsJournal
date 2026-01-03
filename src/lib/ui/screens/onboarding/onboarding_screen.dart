import "package:flutter/material.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_1.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_2.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_3.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_4.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required OnboardingScreenViewModel onboardingScreenViewModel}) : _onboardingScreenViewModel = onboardingScreenViewModel;

  final OnboardingScreenViewModel _onboardingScreenViewModel;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget._onboardingScreenViewModel.currentPageIndex,
      builder: (_, _, _) {
        String pageTitle = OpenEatsJournalStrings.emptyString;
        if (widget._onboardingScreenViewModel.currentPageIndex.value == 1) {
          pageTitle = AppLocalizations.of(context)!.about_this_app;
        } else if (widget._onboardingScreenViewModel.currentPageIndex.value == 2) {
          pageTitle = AppLocalizations.of(context)!.tell_about_yourself;
        } else if (widget._onboardingScreenViewModel.currentPageIndex.value == 3) {
          pageTitle = AppLocalizations.of(context)!.your_targets;
        }

        return Scaffold(
          appBar: widget._onboardingScreenViewModel.currentPageIndex.value > 0
              ? AppBar(
                  leading: IconButton(
                    icon: BackButtonIcon(),
                    onPressed: () {
                      _movePageIndex(-1);
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
                      _movePageIndex(1);
                    },
                    darkMode: widget._onboardingScreenViewModel.darkMode,
                  ),
                  OnboardingScreenPage2(
                    onDone: () {
                      _movePageIndex(1);
                    },
                  ),
                  OnboardingScreenPage3(
                    onDone: () {
                      _movePageIndex(1);
                    },
                    onboardingScreenViewModel: widget._onboardingScreenViewModel,
                  ),
                  OnboardingScreenPage4(
                    onDone: () async {
                      await widget._onboardingScreenViewModel.saveOnboardingData();
                      Navigator.pushReplacementNamed(navigatorKey.currentContext!, OpenEatsJournalStrings.navigatorRouteEatsJournal);
                    },
                    onboardingScreenViewModel: widget._onboardingScreenViewModel,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _movePageIndex(int steps) {
    widget._onboardingScreenViewModel.currentPageIndex.value = widget._onboardingScreenViewModel.currentPageIndex.value + steps;
    _pageViewController.animateToPage(
      widget._onboardingScreenViewModel.currentPageIndex.value,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    widget._onboardingScreenViewModel.dispose();
    _pageViewController.dispose();
    
    super.dispose();
  }
}
