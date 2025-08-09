import "dart:ui";

import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";
import "package:openeatsjournal/ui/screens/food.dart";
import "package:openeatsjournal/ui/screens/home.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";
import "package:openeatsjournal/ui/screens/settings.dart";
import "package:openeatsjournal/ui/screens/statistics.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";
import "package:openeatsjournal/ui/utils/no_page_transitions_builder.dart";

class OpenEatsJournalApp extends StatefulWidget {
  const OpenEatsJournalApp({
      super.key,
      required OpenEatsJournalAppViewModel openEatsJournalAppViewModel,
      required settingsRepositoy,
      required weightRepository,
    }
  ) :
    _openEatsJournalAppViewModel = openEatsJournalAppViewModel,
    _settingsRepositoy = settingsRepositoy,
    _weightRepository = weightRepository;

  final OpenEatsJournalAppViewModel _openEatsJournalAppViewModel;
  final SettingsRepositoy _settingsRepositoy;
  final WeightRepositoy _weightRepository;

  @override
  State<OpenEatsJournalApp> createState() => _OpenEatsJournalAppState();
}

class _OpenEatsJournalAppState extends State<OpenEatsJournalApp> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = ThemeMode.light;
    if (widget._settingsRepositoy.initialized.value) {
      if(widget._settingsRepositoy.darkMode.value) {
        themeMode = ThemeMode.dark;
      }
    }
    else {
      Brightness brightness = MediaQuery.of(context).platformBrightness;
      if (brightness == Brightness.dark) {
        widget._settingsRepositoy.darkMode.value = true;
        themeMode = ThemeMode.dark;
      }
      
      String platformLanguageCode = PlatformDispatcher.instance.locale.languageCode;
      if(AppLocalizations.supportedLocales.any((locale) => locale.languageCode == platformLanguageCode)) {
         widget._settingsRepositoy.languageCode.value = platformLanguageCode;
      }
    }

    String initialRoute = "/";
    if (!widget._settingsRepositoy.initialized.value) {
      initialRoute = "/onboarding";
    }

    return ValueListenableBuilder(
      valueListenable: widget._openEatsJournalAppViewModel.darkMode,
      builder: (_, _, _) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(widget._openEatsJournalAppViewModel.locale.value),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: NoPageTransitionsBuilder(),
                TargetPlatform.iOS: NoPageTransitionsBuilder()
              }
            )
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant, brightness: Brightness.dark),
            pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: NoPageTransitionsBuilder(),
              TargetPlatform.iOS: NoPageTransitionsBuilder()
            }
            )
          ),
          themeMode: themeMode,
          initialRoute: initialRoute,
          routes: {
           NavigatorRoutes.home: (context) => const HomeScreen(),
           NavigatorRoutes.statistics: (context) => const StatisticsScreen(),
           NavigatorRoutes.food: (context) => const FoodScreen(),
           NavigatorRoutes.settings: (context) => const SettingsScreen(),
           NavigatorRoutes.onboarding: (context) => OnboardingScreen(
              onboardingViewModel: OnboardingViewModel(
                settingsRepositoy: widget._settingsRepositoy,
                weightRepository: widget._weightRepository))
          },
        );
      },
    );
  }
}