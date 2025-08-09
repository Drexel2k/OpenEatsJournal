import "package:flutter/material.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(route: NavigatorRoutes.statistics, body: Text("Stats"), title: "STATS");
  }
}