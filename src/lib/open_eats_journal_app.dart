import "dart:ui";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/global_navigator_key.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_colors.dart";
import "package:openeatsjournal/ui/repositories.dart";
import "package:openeatsjournal/ui/screens/barcode_scanner_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_food_entry_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_food_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen.dart";
import "package:openeatsjournal/ui/screens/eats_journal_quick_entry_edit_screen_viewmodel.dart";
import "package:openeatsjournal/ui/screens/food_edit_screen.dart";
import "package:openeatsjournal/ui/screens/food_edit_screen_viewmodel.dart";
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
            extensions: const <ThemeExtension<dynamic>>[
              OpenEatsJournalColors(
                userFoodColor: Color.fromARGB(255, 26, 65, 255),
                standardFoodColor: Color.fromARGB(255, 12, 255, 0),
                openFoodFactsFoodColor: Color.fromARGB(255, 255, 135, 20),
                quickEntryColor: Color.fromARGB(255, 255, 0, 233),
              ),
            ],
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
            extensions: const <ThemeExtension<dynamic>>[
              OpenEatsJournalColors(
                userFoodColor: Color.fromARGB(255, 77, 99, 203),
                standardFoodColor: Color.fromARGB(255, 64, 198, 57),
                openFoodFactsFoodColor: Color.fromARGB(255, 202, 136, 73),
                quickEntryColor: Color.fromARGB(255, 198, 57, 186),
              ),
            ],
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
                journalRepository: _repositories.journalRepository,
              ),
            ),
            OpenEatsJournalStrings.navigatorRouteBarcodeScanner: (contextBuilder) => BarcodeScannerScreen(),
            OpenEatsJournalStrings.navigatorRouteFoodEntryEdit: (contextBuilder) => EatsJournalFoodEntryEditScreen(
              eatsJournalFoodAddScreenViewModel: EatsJournalFoodEntryEditScreenViewModel(
                foodEntry: (ModalRoute.of(contextBuilder)!.settings.arguments as EatsJournalEntry),
                journalRepository: _repositories.journalRepository,
                foodRepository: _repositories.foodRepository,
                settingsRepository: _repositories.settingsRepository,
              ),
            ),
            OpenEatsJournalStrings.navigatorRouteFoodEdit: (contextBuilder) => FoodEditScreen(
              foodEditScreenViewModel: FoodEditScreenViewModel(
                food: (ModalRoute.of(contextBuilder)!.settings.arguments as Food),
                foodRepository: _repositories.foodRepository,
              ),
            ),
            OpenEatsJournalStrings.navigatorRouteQuickEntryEdit: (contextBuilder) => EatsJournalQuickEntryEditScreen(
              eatsJournalQuickEntryAddScreenViewModel: EatsJournalQuickEntryEditScreenViewModel(
                quickEntry: (ModalRoute.of(contextBuilder)!.settings.arguments as EatsJournalEntry),
                journalRepository: _repositories.journalRepository,
                settingsRepository: _repositories.settingsRepository,
              ),
            ),
          },
          navigatorKey: navigatorKey
        );
      },
    );
  }
}
