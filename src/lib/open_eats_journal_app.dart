import "dart:ui";

import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/screens/barcode_scanner_screen.dart";
import "package:openeatsjournal/ui/screens/food_screen.dart";
import "package:openeatsjournal/ui/screens/daily_overview_screen.dart";
import "package:openeatsjournal/ui/screens/daily_overview_viewmodel.dart";
import "package:openeatsjournal/ui/screens/food_viewmodel.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";
import "package:openeatsjournal/ui/screens/statistics_screen.dart";
import "package:openeatsjournal/ui/utils/navigator_routes.dart";
import "package:openeatsjournal/ui/utils/no_page_transitions_builder.dart";

class OpenEatsJournalApp extends StatelessWidget {
  const OpenEatsJournalApp({
    super.key,
    required OpenEatsJournalAppViewModel openEatsJournalAppViewModel,
    required Repositories repositories,
  }) : _repositories = repositories,
       _openEatsJournalAppViewModel = openEatsJournalAppViewModel;

  final OpenEatsJournalAppViewModel _openEatsJournalAppViewModel;
  final Repositories _repositories;

  @override
  Widget build(BuildContext context) {
    if (_openEatsJournalAppViewModel.initialized) {
      if (_openEatsJournalAppViewModel.darkMode) {}
    } else {
      Brightness brightness = MediaQuery.of(context).platformBrightness;
      if (brightness == Brightness.dark) {
        _openEatsJournalAppViewModel.darkMode = true;
      }

      String platformLanguageCode = PlatformDispatcher.instance.locale.languageCode;
      if (AppLocalizations.supportedLocales.any((locale) => locale.languageCode == platformLanguageCode)) {
        _openEatsJournalAppViewModel.languageCode = platformLanguageCode;
      }
    }

    String initialRoute = NavigatorRoutes.home;
    if (!_openEatsJournalAppViewModel.initialized) {
      initialRoute = NavigatorRoutes.onboarding;
    }

    return ListenableBuilder(
      listenable: _openEatsJournalAppViewModel.darkModeOrLanguageCodeChanged,
      builder: (contextBuilder, _) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(_openEatsJournalAppViewModel.languageCode),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigoAccent.shade700,
              dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: NoPageTransitionsBuilder(),
                TargetPlatform.iOS: NoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigoAccent.shade700,
              dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
              brightness: Brightness.dark,
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: NoPageTransitionsBuilder(),
                TargetPlatform.iOS: NoPageTransitionsBuilder(),
              },
            ),
          ),
          themeMode: _openEatsJournalAppViewModel.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: initialRoute,
          routes: {
            NavigatorRoutes.home: (contextBuilder) => DailyOverviewScreen(
              homeViewModel: DailyOverviewViewModel(settingsRepository: _repositories.settingsRepository),
              settingsRepository: _repositories.settingsRepository,
            ),
            NavigatorRoutes.statistics: (contextBuilder) => const StatisticsScreen(),
            NavigatorRoutes.food: (contextBuilder) =>
                FoodScreen(foodViewModel: FoodViewModel(settingsRepository: _repositories.settingsRepository)),
            NavigatorRoutes.onboarding: (contextBuilder) => OnboardingScreen(
              onboardingViewModel: OnboardingViewModel(
                settingsRepository: _repositories.settingsRepository,
                weightRepository: _repositories.weightRepository,
              ),
            ),
            NavigatorRoutes.barcodeScanner: (contextBuilder) => BarcodeScannerScreen(),
          },
        );
      },
    );
  }
}
