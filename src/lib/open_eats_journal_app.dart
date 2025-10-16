import "dart:ui";

import "package:flutter/material.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/screens/barcode_scanner_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_food_add_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_food_add_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/food_search_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/food_search_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/statistics_screen.dart";
import "package:openeatsjournal/ui/screens/statistics_screen_viewmodel.dart";
import "package:openeatsjournal/ui/utils/no_page_transitions_builder.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";

class OpenEatsJournalApp extends StatelessWidget {
  const OpenEatsJournalApp({super.key, required OpenEatsJournalAppViewModel openEatsJournalAppViewModel, required Repositories repositories})
    : _repositories = repositories,
      _openEatsJournalAppViewModel = openEatsJournalAppViewModel;

  final OpenEatsJournalAppViewModel _openEatsJournalAppViewModel;
  final Repositories _repositories;

  @override
  Widget build(BuildContext context) {
    if (!_openEatsJournalAppViewModel.initialized) {
      Brightness brightness = MediaQuery.of(context).platformBrightness;
      if (brightness == Brightness.dark) {
        _openEatsJournalAppViewModel.darkMode = true;
      }

      String platformLanguageCode = PlatformDispatcher.instance.locale.languageCode;
      if (AppLocalizations.supportedLocales.any((locale) => locale.languageCode == platformLanguageCode)) {
        _openEatsJournalAppViewModel.languageCode = platformLanguageCode;
      }
    }

    String initialRoute = OpenEatsJournalStrings.navigatorRouteEatsJournal;
    if (!_openEatsJournalAppViewModel.initialized) {
      initialRoute = OpenEatsJournalStrings.navigatorRouteOnboarding;
    }
    return ListenableBuilder(
      listenable: _openEatsJournalAppViewModel.darkModeOrLanguageCodeChanged,
      builder: (contextBuilder, _) {
        ConvertValidate.init(languageCode: _openEatsJournalAppViewModel.languageCode);
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(_openEatsJournalAppViewModel.languageCode),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {TargetPlatform.android: NoPageTransitionsBuilder(), TargetPlatform.iOS: NoPageTransitionsBuilder()},
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigoAccent.shade700,
              dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
              brightness: Brightness.dark,
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {TargetPlatform.android: NoPageTransitionsBuilder(), TargetPlatform.iOS: NoPageTransitionsBuilder()},
            ),
          ),
          themeMode: _openEatsJournalAppViewModel.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: initialRoute,
          routes: {
            OpenEatsJournalStrings.navigatorRouteEatsJournal: (contextBuilder) => EatsJournalScreen(
              eatsJournalScreenViewModel: EatsJournalScreenViewModel(
                journalRepository: _repositories.journalRepository,
                settingsRepository: _repositories.settingsRepository,
              ),
            ),
            OpenEatsJournalStrings.navigatorRouteStatistics: (contextBuilder) =>
                StatisticsScreen(statisticsScreenViewModel: StatisticsScreenViewModel(journalRepository: _repositories.journalRepository)),
            OpenEatsJournalStrings.navigatorRouteFood: (contextBuilder) => FoodSearchScreen(
              foodSearchScreenViewModel: FoodSearchScreenViewModel(
                foodRepository: _repositories.foodRepository,
                journalRepository: _repositories.journalRepository,
                settingsRepository: _repositories.settingsRepository,
              ),
            ),
            OpenEatsJournalStrings.navigatorRouteOnboarding: (contextBuilder) => OnboardingScreen(
              onboardingScreenViewModel: OnboardingScreenViewModel(
                settingsRepository: _repositories.settingsRepository,
                weightRepository: _repositories.weightRepository,
              ),
            ),
            OpenEatsJournalStrings.navigatorRouteBarcodeScanner: (contextBuilder) => BarcodeScannerScreen(),
            OpenEatsJournalStrings.navigatorRouteEatsAdd: (contextBuilder) => EatsJournalFoodAddScreen(
              eatsJournalFoodAddScreenViewModel: EatsJournalFoodAddScreenViewModel(
                food: (ModalRoute.of(contextBuilder)!.settings.arguments as Food),
                journalRepository: _repositories.journalRepository,
                foodRepository: _repositories.foodRepository,
                settingsRepository: _repositories.settingsRepository,
              ),
            ),
          },
          navigatorKey: navigatorKey,
        );
      },
    );
  }
}
