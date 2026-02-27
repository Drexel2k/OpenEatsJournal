import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/ui/utils/layout_mode.dart";

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required String route,
    required Widget body,
    required String title,
    Widget? floatingActionButton,
    LayoutMode layoutMode = LayoutMode.scroll,
  }) : _route = route,
       _body = body,
       _title = title,
       _floatingActionButton = floatingActionButton,
       _layoutMode = layoutMode;

  final Widget _body;
  final String _title;
  final String _route;
  final Widget? _floatingActionButton;
  final LayoutMode _layoutMode;

  @override
  Widget build(BuildContext context) {
    int currentNavigationIndex = 1; //home
    if (_route == OpenEatsJournalStrings.navigatorRouteFood) {
      currentNavigationIndex = 0;
    } else if (_route == OpenEatsJournalStrings.navigatorRouteStatistics) {
      currentNavigationIndex = 2;
    }

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: Text(_title)),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                  //constraints enable SingleChildScrollview on fix height large screen-widgets for small display phones, exception: pages with lazy loaders like
                  //ListView.builder()...
                  child: Builder(
                    builder: (BuildContext context) {
                      //for content with fixed height (no spacers, expands e.g. on vertical directions ) that just scroll if there is too less space
                      if (_layoutMode == LayoutMode.scroll) {
                        return LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints viewportConstraints) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: viewportConstraints.maxHeight),
                              child: SingleChildScrollView(child: _body),
                            );
                          },
                        );
                      }

                      //for content with spacers to fill larger screens (for buttons at the bottom e.g.), but that just scroll if there is too lees space
                      if (_layoutMode == LayoutMode.intrinsicHeightMinHeight) {
                        return LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints viewportConstraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                                child: IntrinsicHeight(child: _body),
                              ),
                            );
                          },
                        );
                      }
                      
                      return _body;
                    },
                  ),
                ),
              ),
              bottomNavigationBar: NavigationBar(
                onDestinationSelected: (int targetNavigationIndex) async {
                  if (targetNavigationIndex == 0) {
                    await Navigator.pushNamedAndRemoveUntil(context, OpenEatsJournalStrings.navigatorRouteFood, (Route<dynamic> route) => false);
                  } else if (targetNavigationIndex == 1) {
                    await Navigator.pushNamedAndRemoveUntil(context, OpenEatsJournalStrings.navigatorRouteEatsJournal, (Route<dynamic> route) => false);
                  } else if (targetNavigationIndex == 2) {
                    await Navigator.pushNamedAndRemoveUntil(context, OpenEatsJournalStrings.navigatorRouteStatistics, (Route<dynamic> route) => false);
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
          },
        ),
      ],
    );
  }
}
