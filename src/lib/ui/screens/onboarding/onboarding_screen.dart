import "package:flutter/material.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_1.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_2.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_3.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_page_4.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required OnboardingScreenViewModel onboardingScreenViewModel, required VoidCallback onboardingFinishedCallback})
    : _onboardingScreenViewModel = onboardingScreenViewModel,
      _onboardingFinishedCallback = onboardingFinishedCallback;

  final OnboardingScreenViewModel _onboardingScreenViewModel;
  final VoidCallback _onboardingFinishedCallback;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingScreenViewModel _onboardingScreenViewModel;
  late VoidCallback _onboardingFinishedCallback;

  final PageController _pageViewController = PageController();

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _onboardingScreenViewModel = widget._onboardingScreenViewModel;
    _onboardingFinishedCallback = widget._onboardingFinishedCallback;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _onboardingScreenViewModel.currentPageIndex,
      builder: (_, _, _) {
        String pageTitle = OpenEatsJournalStrings.emptyString;
        if (_onboardingScreenViewModel.currentPageIndex.value == 1) {
          pageTitle = AppLocalizations.of(context)!.about_this_app;
        } else if (_onboardingScreenViewModel.currentPageIndex.value == 2) {
          pageTitle = AppLocalizations.of(context)!.tell_about_yourself;
        } else if (_onboardingScreenViewModel.currentPageIndex.value == 3) {
          pageTitle = AppLocalizations.of(context)!.your_targets;
        }

        return Scaffold(
          appBar: _onboardingScreenViewModel.currentPageIndex.value > 0
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
                    darkMode: _onboardingScreenViewModel.darkMode,
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
                    onboardingScreenViewModel: _onboardingScreenViewModel,
                  ),
                  OnboardingScreenPage4(
                    onDone: () async {
                      await _onboardingScreenViewModel.saveOnboardingData();
                      _onboardingFinishedCallback();
                      Navigator.pushReplacementNamed(AppGlobal.navigatorKey.currentContext!, OpenEatsJournalStrings.navigatorRouteEatsJournal);
                    },
                    onboardingScreenViewModel: _onboardingScreenViewModel,
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
    _onboardingScreenViewModel.currentPageIndex.value = _onboardingScreenViewModel.currentPageIndex.value + steps;
    _pageViewController.animateToPage(_onboardingScreenViewModel.currentPageIndex.value, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    widget._onboardingScreenViewModel.dispose();
    if (widget._onboardingScreenViewModel != _onboardingScreenViewModel) {
      _onboardingScreenViewModel.dispose();
    }

    _pageViewController.dispose();

    super.dispose();
  }
}
