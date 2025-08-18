import 'package:flutter/material.dart';
import 'package:openeatsjournal/ui/utils/navigator_routes.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required String route, required Widget body, required String title})
    : _route = route,
      _body = body,
      _title = title;

  final Widget _body;
  final String _title;
  final String _route;

  @override
  Widget build(BuildContext context) {
    int currentNavigationIndex = 1; //home
    if (_route == NavigatorRoutes.food) {
      currentNavigationIndex = 0;
    } else if (_route == NavigatorRoutes.statistics) {
      currentNavigationIndex = 2;
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0), child: _body),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int targetNavigationIndex) {
          if (targetNavigationIndex == 0) {
            Navigator.pushNamed(context, NavigatorRoutes.food);
          } else if (targetNavigationIndex == 1) {
            Navigator.pushNamed(context, NavigatorRoutes.home);
          } else if (targetNavigationIndex == 2) {
            Navigator.pushNamed(context, NavigatorRoutes.statistics);
          }
        },
        selectedIndex: currentNavigationIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.lunch_dining), label: "Food"),
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.insights), label: "Statistics"),
        ],
      ),
    );
  }
}
