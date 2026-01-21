import "package:flutter/material.dart";

class AppGlobal {
  AppGlobal._();

  //used to access current context after async calls (open dialogs after async e.g.) functions
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
