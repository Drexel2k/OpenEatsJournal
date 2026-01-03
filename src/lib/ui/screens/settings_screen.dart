import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/setting_type.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_personal.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_app.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required SettingsScreenViewModel settingsScreenViewModel}) : _settingsScreenViewModel = settingsScreenViewModel;

  final SettingsScreenViewModel _settingsScreenViewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: widget._settingsScreenViewModel.currentPageIndex,
          builder: (_, _, _) {
            String pageTitle = OpenEatsJournalStrings.emptyString;
            if (widget._settingsScreenViewModel.currentPageIndex.value == 0) {
              pageTitle = AppLocalizations.of(context)!.personal_settings;
            } else if (widget._settingsScreenViewModel.currentPageIndex.value == 1) {
              pageTitle = AppLocalizations.of(context)!.app_settings;
            }

            return AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(pageTitle));
          },
        ),
        ValueListenableBuilder(
          valueListenable: widget._settingsScreenViewModel.currentPageIndex,
          builder: (_, _, _) {
            return SegmentedButton<SettingType>(
              selected: <SettingType>{SettingType.getByValue(widget._settingsScreenViewModel.currentPageIndex.value + 1)},
              showSelectedIcon: false,
              segments: [
                ButtonSegment<SettingType>(value: SettingType.personal, label: Text(AppLocalizations.of(context)!.personal_settings_abbreviated)),
                ButtonSegment<SettingType>(value: SettingType.app, label: Text(AppLocalizations.of(context)!.app_settings)),
              ],
              onSelectionChanged: (Set<SettingType> newSelection) {
                if (newSelection.single == SettingType.app) {
                  if (widget._settingsScreenViewModel.currentPageIndex.value == 0) {
                    _movePageIndex(1);
                  }
                } else {
                  if (widget._settingsScreenViewModel.currentPageIndex.value == 1) {
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
              SettingsScreenPagePersonal(settingsScreenViewModel: widget._settingsScreenViewModel),
              SettingsScreenPageApp(settingsViewModel: widget._settingsScreenViewModel),
            ],
          ),
        ),
      ],
    );
  }

  void _movePageIndex(int page) {
    widget._settingsScreenViewModel.currentPageIndex.value = page;
    _pageViewController.animateToPage(
      widget._settingsScreenViewModel.currentPageIndex.value,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    widget._settingsScreenViewModel.dispose();
    _pageViewController.dispose();

    super.dispose();
  }
}
