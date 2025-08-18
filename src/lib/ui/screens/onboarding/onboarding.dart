import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_1.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_2.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_3.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_4.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key, required OnboardingViewModel onboardingViewModel})
    : _onboardingViewModel = onboardingViewModel;
  final OnboardingViewModel _onboardingViewModel;
  final PageController _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _onboardingViewModel.currentPageIndex,
      builder: (_, _, _) {
        String pageTitle = "";
        if (_onboardingViewModel.currentPageIndex.value == 1) {
          pageTitle = AppLocalizations.of(context)!.about_this_app;
        } else if (_onboardingViewModel.currentPageIndex.value == 2) {
          pageTitle = AppLocalizations.of(context)!.tell_about_yourself;
        } else if (_onboardingViewModel.currentPageIndex.value == 3) {
          pageTitle = AppLocalizations.of(context)!.your_targets;
        }

        return Scaffold(
          appBar: _onboardingViewModel.currentPageIndex.value > 0
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
                  OnboardingPage1(
                    onDone: () {
                      _movePageIndex(1);
                    },
                    darkMode: _onboardingViewModel.darkMode,
                  ),
                  OnboardingPage2(
                    onDone: () {
                      _movePageIndex(1);
                    },
                  ),
                  OnboardingPage3(
                    onDone: () {
                      _movePageIndex(1);
                    },
                    onboardingViewModel: _onboardingViewModel,
                  ),
                  OnboardingPage4(onDone: () {}, onboardingViewModel: _onboardingViewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _movePageIndex(int steps) {
    _onboardingViewModel.currentPageIndex.value = _onboardingViewModel.currentPageIndex.value + steps;
    _pageViewController.animateToPage(
      _onboardingViewModel.currentPageIndex.value,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
