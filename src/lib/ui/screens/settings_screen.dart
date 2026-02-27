import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_app.dart";
import "package:openeatsjournal/ui/screens/settings_screen_page_personal.dart";
import "package:openeatsjournal/ui/screens/settings_screen_viewmodel.dart";
import "package:provider/provider.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsScreenViewModel>(
      builder: (context, settingsScreenViewModel, _) => DefaultTabController(
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
                  SettingsScreenPagePersonal(settingsScreenViewModel: settingsScreenViewModel),
                  SettingsScreenPageApp(settingsViewModel: settingsScreenViewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
