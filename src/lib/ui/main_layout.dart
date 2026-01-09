import 'package:flutter/material.dart';
import 'package:openeatsjournal/l10n/app_localizations.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required String route, required Widget body, required String title, Widget? floatingActionButton})
    : _route = route,
      _body = body,
      _title = title,
      _floatingActionButton = floatingActionButton;

  final Widget _body;
  final String _title;
  final String _route;
  final Widget? _floatingActionButton;

  @override
  Widget build(BuildContext context) {
    int currentNavigationIndex = 1; //home
    if (_route == OpenEatsJournalStrings.navigatorRouteFood) {
      currentNavigationIndex = 0;
    } else if (_route == OpenEatsJournalStrings.navigatorRouteStatistics) {
      currentNavigationIndex = 2;
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 5), child: _body),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int targetNavigationIndex) {
          if (targetNavigationIndex == 0) {
            Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
          } else if (targetNavigationIndex == 1) {
            Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteEatsJournal);
          } else if (targetNavigationIndex == 2) {
            Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteStatistics);
          }
        },
        selectedIndex: currentNavigationIndex,
        destinations: <Widget>[
          NavigationDestination(icon: Icon(Icons.lunch_dining), label: AppLocalizations.of(context)!.food),
          NavigationDestination(icon: Icon(Icons.menu_book), label: AppLocalizations.of(context)!.eats_journal),
          NavigationDestination(icon: Icon(Icons.assessment), label: AppLocalizations.of(context)!.statistics),
        ],
      ),
      floatingActionButton: _floatingActionButton,
      resizeToAvoidBottomInset: false,
    );
  }
}
