import "package:flutter/material.dart";
import "package:openeatsjournal/ui/screens/settings_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/settings_page_personal.dart";
import "package:openeatsjournal/ui/widgets/settings_page_app.dart";

class Settings extends StatelessWidget {
  Settings({super.key, required SettingsViewModel settingsViewModel})
    : _settingsViewModel = settingsViewModel;

  final SettingsViewModel _settingsViewModel;
  final _pageViewController  = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageViewController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        SettingsPagePersonal(settingsViewModel:  _settingsViewModel, onDone: () { _movePageIndex(1); }),
        SettingsPageApp(settingsViewModel: _settingsViewModel, onDone: () { _movePageIndex(-1); }),
      ]
    );
  }

  void _movePageIndex(int steps) {
    _settingsViewModel.currentPageIndex = _settingsViewModel.currentPageIndex + steps;
    _pageViewController.animateToPage(
      _settingsViewModel.currentPageIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
