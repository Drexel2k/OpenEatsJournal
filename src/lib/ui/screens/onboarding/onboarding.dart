import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_page_1.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_page_2.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_page_3.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_page_4.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_state.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_state_data.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPageIndex = 0;
  bool _showAppBar = false;
  String _appBarTitle = "";
  final Map _pageTitles = {0: "", 1: "About This App", 2: "Tell About Yourself", 3: "You Targets"};
  OnboardingStateData onboardingData = OnboardingStateData();
  late PageController _pageViewController;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showAppBar ? 
        AppBar(
          leading: IconButton(icon: BackButtonIcon(), onPressed: () { _movePageIndex(-1);}),
          title: Text(_appBarTitle))
        : null,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0), 
        child: OnboardingState(
          data: onboardingData,
          child: PageView(
            controller: _pageViewController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              OnboardingPage1(onDone: () { _movePageIndex(1); }),
              OnboardingPage2(onDone: () { _movePageIndex(1); }),
              OnboardingPage3(onDone: () { _movePageIndex(1); }),
              OnboardingPage4(onDone: () { }),  
              ],
            ),
          ),
      ),
    );
  }

void _movePageIndex(int steps) {
  _currentPageIndex = _currentPageIndex + steps;
    _pageViewController.animateToPage(
      _currentPageIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    _setScaffoldAppBarTitle(_pageTitles[_currentPageIndex]);
  }

void _setScaffoldAppBarTitle(String title){
  setState(() {
      if(title.isEmpty) {
        _showAppBar = false;
      }
      else {
        _showAppBar = true;
      }

      _appBarTitle = title;
  });
}
}