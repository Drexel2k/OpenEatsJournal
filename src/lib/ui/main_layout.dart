import "package:flutter/material.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required String route,
    required Widget body,
    required String title,
    Widget? floatingActionButton,
    VoidCallback? mainNavigationCallback,
  }) : _route = route,
       _body = body,
       _title = title,
       _floatingActionButton = floatingActionButton,
       _mainNavigationCallback = mainNavigationCallback;

  final Widget _body;
  final String _title;
  final String _route;
  final Widget? _floatingActionButton;
  final VoidCallback? _mainNavigationCallback;

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
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: AppGlobal.safeHeigtWithAppbar),
            child: _body,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int targetNavigationIndex) async {
          if (targetNavigationIndex == 0) {
            await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteFood);
            if (_mainNavigationCallback != null) {
              _mainNavigationCallback();
            }
          } else if (targetNavigationIndex == 1) {
            await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteEatsJournal);
            if (_mainNavigationCallback != null) {
              _mainNavigationCallback();
            }
          } else if (targetNavigationIndex == 2) {
            await Navigator.pushNamed(context, OpenEatsJournalStrings.navigatorRouteStatistics);
            if (_mainNavigationCallback != null) {
              _mainNavigationCallback();
            }
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
    );
  }
}
