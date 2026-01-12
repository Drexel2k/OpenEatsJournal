import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_app.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_personal.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required SettingsScreenViewModel settingsScreenViewModel}) : _settingsScreenViewModel = settingsScreenViewModel;

  final SettingsScreenViewModel _settingsScreenViewModel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsScreenViewModel _settingsScreenViewModel;

  //only called once even if the widget is recreated on opening the virtual keyboard e.g.
  @override
  void initState() {
    _settingsScreenViewModel = widget._settingsScreenViewModel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          AppBar(backgroundColor: Color.fromARGB(0, 0, 0, 0), title: Text(AppLocalizations.of(context)!.settings)),
          TabBar(
            tabs: [
              Tab(child: Text(AppLocalizations.of(context)!.personal)),
              Tab(child: Text(AppLocalizations.of(context)!.app)),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                SettingsScreenPagePersonal(settingsScreenViewModel: _settingsScreenViewModel),
                SettingsScreenPageApp(settingsViewModel: _settingsScreenViewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget._settingsScreenViewModel.dispose();
    if (widget._settingsScreenViewModel != _settingsScreenViewModel) {
      _settingsScreenViewModel.dispose();
    }

    super.dispose();
  }
}
