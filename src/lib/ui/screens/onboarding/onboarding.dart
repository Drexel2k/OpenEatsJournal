import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_1.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_2.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_3.dart";
import "package:openeatsjournal/ui/widgets/onboarding/onboarding_page_4.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required OnboardingViewModel onboardingViewModel}) : _onboardingViewModel = onboardingViewModel;
  final OnboardingViewModel _onboardingViewModel;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPageIndex = 0;
  late PageController _pageViewController;
  Map? pageTitles;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    pageTitles ??= {
      0: "",
      1: AppLocalizations.of(context)!.about_this_app,
      2: AppLocalizations.of(context)!.tell_about_yourself,
      3: AppLocalizations.of(context)!.your_targets
    };

    return Scaffold(
      appBar: _currentPageIndex > 0 ? 
        AppBar(
          leading: IconButton(icon: BackButtonIcon(), onPressed: () {
            _movePageIndex(-1, pageTitles!);
          }),
          title: Text(pageTitles![_currentPageIndex])
        ) :
        null,
      body: SafeArea( 
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0), 
          child:  PageView(
            controller: _pageViewController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              OnboardingPage1(onDone: () { _movePageIndex(1, pageTitles!); }, darkMode: widget._onboardingViewModel.darkMode),
              OnboardingPage2(onDone: () { _movePageIndex(1, pageTitles!); }),
              OnboardingPage3(onDone: () { _movePageIndex(1, pageTitles!); }, onboardingViewModel:widget._onboardingViewModel),
              OnboardingPage4(onDone: () { }, onboardingViewModel:widget._onboardingViewModel),  
            ]
          )
        )
      )
    );
  }

  void _movePageIndex(int steps, Map pageTitles) {
    setState(() {
      _currentPageIndex = _currentPageIndex + steps;
        _pageViewController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
    });
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    widget._onboardingViewModel.dispose();

    super.dispose();
  }
}