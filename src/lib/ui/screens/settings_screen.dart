import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_viewmodel.dart";
import "package:openeatsjournal/ui/utils/oej_strings.dart";
import "package:openeatsjournal/ui/utils/setting_type.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_personal.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_app.dart";

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key, required SettingsViewModel settingsViewModel}) : _settingsViewModel = settingsViewModel;

  final SettingsViewModel _settingsViewModel;
  final _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _settingsViewModel.currentPageIndex,
          builder: (_, _, _) {
            String pageTitle = OejStrings.emptyString;
            if (_settingsViewModel.currentPageIndex.value == 0) {
              pageTitle = AppLocalizations.of(context)!.personal_settings;
            } else if (_settingsViewModel.currentPageIndex.value == 1) {
              pageTitle = AppLocalizations.of(context)!.app_settings;
            }
            
            return AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(pageTitle));
          },
        ),
        ValueListenableBuilder(
          valueListenable: _settingsViewModel.currentPageIndex,
          builder: (_, _, _) {
            return SegmentedButton<SettingType>(
              selected: <SettingType>{SettingType.getByValue(_settingsViewModel.currentPageIndex.value + 1)},
              showSelectedIcon: false,
              segments: [
                ButtonSegment<SettingType>(
                  value: SettingType.personal,
                  label: Text(AppLocalizations.of(context)!.personal_settings),
                ),
                ButtonSegment<SettingType>(
                  value: SettingType.app,
                  label: Text(AppLocalizations.of(context)!.app_settings),
                ),
              ],
              onSelectionChanged: (Set<SettingType> newSelection) {
                if (newSelection.single == SettingType.app) {
                  if (_settingsViewModel.currentPageIndex.value == 0) {
                    _movePageIndex(1);
                  }
                } else {
                  if (_settingsViewModel.currentPageIndex.value == 1) {
                    _movePageIndex(0);
                  }
                }
              },
            );
          },
        ),
        SizedBox(height: 10),
        Expanded(
          child: PageView(
            controller: _pageViewController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              SettingsScreenPagePersonal(settingsViewModel: _settingsViewModel),
              SettingsScreenPageApp(settingsViewModel: _settingsViewModel),
            ],
          ),
        ),
      ],
    );
  }

  void _movePageIndex(int page) {
    _settingsViewModel.currentPageIndex.value = page;
    _pageViewController.animateToPage(
      _settingsViewModel.currentPageIndex.value,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
