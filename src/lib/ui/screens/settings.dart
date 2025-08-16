import "package:flutter/material.dart";
import "package:openeatsjournal/ui/screens/settings_viewmodel.dart";
import "package:openeatsjournal/ui/widgets/settings_page_personal.dart";
import "package:openeatsjournal/ui/widgets/settings_page_app.dart";

class Settings extends StatefulWidget {
  const Settings({super.key, required SettingsViewModel settingsViewModel})
    : _settingsViewModel = settingsViewModel;

  final SettingsViewModel _settingsViewModel;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _currentPageIndex = 0;
  final PageController _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageViewController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        SettingsPagePersonal(settingsViewModel:  widget._settingsViewModel, onDone: () { _movePageIndex(1); }),
        SettingsPageApp(settingsViewModel: widget._settingsViewModel, onDone: () { _movePageIndex(-1); }),
      ]
    );
  }

  void _movePageIndex(int steps) {
    setState(() {
      _currentPageIndex = _currentPageIndex + steps;
        _pageViewController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
    });
  }
}
