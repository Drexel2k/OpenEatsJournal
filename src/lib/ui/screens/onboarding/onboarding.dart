import 'package:flutter/material.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/ui/widgets/onboarding/onboarding_page_1.dart';
import 'package:openeatsjournal/ui/widgets/onboarding/onboarding_page_2.dart';
import 'package:openeatsjournal/ui/widgets/onboarding/onboarding_page_3.dart';
import 'package:openeatsjournal/ui/widgets/onboarding/onboarding_page_4.dart';
import 'package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required OnboardingViewModel onboardingViewModel}) : _onboardingViewModel = onboardingViewModel;
  final OnboardingViewModel _onboardingViewModel;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPageIndex = 0;
  bool _showAppBar = false;
  String _appBarTitle = "";
  late PageController _pageViewController;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    Map pageTitles = {
      0: "",
      1: AppLocalizations.of(context)!.about_this_app,
      2: AppLocalizations.of(context)!.tell_about_yourself,
      3: AppLocalizations.of(context)!.your_targets
    };

    return Scaffold(
      appBar: _showAppBar ? 
        AppBar(
          leading: IconButton(icon: BackButtonIcon(), onPressed: () { _movePageIndex(-1, pageTitles);}),
          title: Text(_appBarTitle))
        : null,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0), 
        child: ListenableBuilder(
          listenable: widget._onboardingViewModel,
          builder: (context, _) {
            return PageView(
            controller: _pageViewController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              OnboardingPage1(onDone: () { _movePageIndex(1, pageTitles); }, darkMode: widget._onboardingViewModel.darkMode),
              OnboardingPage2(onDone: () { _movePageIndex(1, pageTitles); }),
              OnboardingPage3(onDone: () { _movePageIndex(1, pageTitles); }, onboardingViewModel:widget._onboardingViewModel),
              OnboardingPage4(onDone: () { }, onboardingViewModel:widget._onboardingViewModel),  
              ],
            );
          }
        ),
      ),
    );
  }

  void _movePageIndex(int steps, Map pageTitles) {
  _currentPageIndex = _currentPageIndex + steps;
    _pageViewController.animateToPage(
      _currentPageIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    _setScaffoldAppBarTitle(pageTitles[_currentPageIndex]);
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

  @override
  void dispose() {
    _pageViewController.dispose();
    widget._onboardingViewModel.dispose();

    super.dispose();
  }
}