import "package:flutter/material.dart";
import "package:openeatsjournal/ui/main_layout.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(route: NavigatorRoutes.food, body: Text("Food"), title: "FOOD");
  }
}
