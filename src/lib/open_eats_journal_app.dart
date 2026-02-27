import "dart:ui";
import "package:flutter/material.dart";
import "package:openeatsjournal/domain/eats_journal_entry.dart";
import "package:openeatsjournal/domain/food.dart";
import "package:openeatsjournal/domain/utils/convert_validate.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/open_eats_journal_app_viewmodel.dart";
import "package:openeatsjournal/app_global.dart";
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
import "package:provider/provider.dart";

class OpenEatsJournalApp extends StatefulWidget {
  const OpenEatsJournalApp({super.key, required OpenEatsJournalAppViewModel openEatsJournalAppViewModel, required Repositories repositories})
    : _repositories = repositories,
      _openEatsJournalAppViewModel = openEatsJournalAppViewModel;

  final OpenEatsJournalAppViewModel _openEatsJournalAppViewModel;
  final Repositories _repositories;
  @override
  State<OpenEatsJournalApp> createState() => _OpenEatsJournalAppState();
}

class _OpenEatsJournalAppState extends State<OpenEatsJournalApp> {
  late OpenEatsJournalAppViewModel _openEatsJournalAppViewModel;
  late Repositories _repositories;

  @override
  void initState() {
    super.initState();

    _openEatsJournalAppViewModel = widget._openEatsJournalAppViewModel;
    _repositories = widget._repositories;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _openEatsJournalAppViewModel.appWideSettingChanged,
      builder: (contextBuilder, _) {
        return FutureBuilder<void>(
          future: _openEatsJournalAppViewModel.settingsLoaded,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              throw StateError("Something went wrong: ${snapshot.error}");
            } else {
              ThemeMode themeMode = ThemeMode.light;
              String languageCode = OpenEatsJournalStrings.en;
              EnergyUnit energyUnit = EnergyUnit.kcal;
              HeightUnit heightUnit = HeightUnit.cm;
              WeightUnit weightUnit = WeightUnit.g;
              VolumeUnit volumeUnit = VolumeUnit.ml;
              String initialRoute = OpenEatsJournalStrings.navigatorRouteEatsJournal;

              if (_openEatsJournalAppViewModel.onboarded) {
                _openEatsJournalAppViewModel.startListening();
                if (_openEatsJournalAppViewModel.darkMode) {
                  themeMode = ThemeMode.dark;
                }

                languageCode = _openEatsJournalAppViewModel.languageCode;
                energyUnit = _openEatsJournalAppViewModel.energyUnit;
                heightUnit = _openEatsJournalAppViewModel.heightUnit;
                weightUnit = _openEatsJournalAppViewModel.weightUnit;
                volumeUnit = _openEatsJournalAppViewModel.volumeUnit;
              } else {
                Brightness brightness = MediaQuery.platformBrightnessOf(context);
                if (brightness == Brightness.dark) {
                  themeMode = ThemeMode.dark;
                }

                String platformLanguageCode = PlatformDispatcher.instance.locale.languageCode;
                if (AppLocalizations.supportedLocales.any((locale) => locale.languageCode == platformLanguageCode)) {
                  languageCode = platformLanguageCode;
                }

                if (languageCode == OpenEatsJournalStrings.de) {
                  heightUnit = HeightUnit.cm;
                  weightUnit = WeightUnit.g;
                  volumeUnit = VolumeUnit.ml;
                }

                initialRoute = OpenEatsJournalStrings.navigatorRouteOnboarding;
              }

              ConvertValidate.init(languageCode: languageCode, energyUnit: energyUnit, heightUnit: heightUnit, weightUnit: weightUnit, volumeUnit: volumeUnit);

              _openEatsJournalAppViewModel.initStandardFoodData(languageCode: languageCode);

              //we need a second future to ensure sequence of loading settings and loading standard food data that changes settings.
              return FutureBuilder<void>(
                future: _openEatsJournalAppViewModel.dataInitialized,
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                  } else if (snapshot.hasError) {
                    throw StateError("Something went wrong: ${snapshot.error}");
                  } else if (snapshot.hasData) {
                    _openEatsJournalAppViewModel.saveLastProcessedStandardFoodDataDate(snapshot.data as DateTime);

                    return MaterialApp(
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      locale: Locale(languageCode),
                      theme: ThemeData(
                        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant),
                        pageTransitionsTheme: PageTransitionsTheme(
                          builders: {TargetPlatform.android: NoPageTransitionsBuilder(), TargetPlatform.iOS: NoPageTransitionsBuilder()},
                        ),
                        extensions: const <ThemeExtension<dynamic>>[
                          OpenEatsJournalColors(
                            userFoodColor: Color.fromARGB(255, 26, 65, 255),
                            standardFoodColor: Color.fromARGB(255, 5, 112, 89),
                            openFoodFactsFoodColor: Color.fromARGB(255, 255, 135, 20),
                            quickEntryColor: Color.fromARGB(255, 255, 0, 233),
                            cacheFoodColor: Color.fromARGB(255, 83, 83, 83),
                            confirmationBackgroundColor: Color.fromARGB(255, 207, 207, 207),
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
                            standardFoodColor: Color.fromARGB(255, 51, 145, 124),
                            openFoodFactsFoodColor: Color.fromARGB(255, 202, 136, 73),
                            quickEntryColor: Color.fromARGB(255, 198, 57, 186),
                            cacheFoodColor: Color.fromARGB(255, 158, 158, 158),
                            confirmationBackgroundColor: Color.fromARGB(255, 68, 68, 68),
                          ),
                        ],
                      ),
                      themeMode: themeMode,
                      initialRoute: initialRoute,
                      routes: {
                        OpenEatsJournalStrings.navigatorRouteEatsJournal: (contextBuilder) {
                          return ChangeNotifierProvider<EatsJournalScreenViewModel>(
                            create: (context) => EatsJournalScreenViewModel(
                              journalRepository: _repositories.journalRepository,
                              settingsRepository: _repositories.settingsRepository,
                            ),
                            child: EatsJournalScreen(),
                          );
                        },
                        OpenEatsJournalStrings.navigatorRouteStatistics: (contextBuilder) {
                          return ChangeNotifierProvider<StatisticsScreenViewModel>(
                            create: (context) => StatisticsScreenViewModel(journalRepository: _repositories.journalRepository),
                            child: StatisticsScreen(),
                          );
                        },
                        OpenEatsJournalStrings.navigatorRouteFood: (contextBuilder) {
                          return ChangeNotifierProvider<FoodSearchScreenViewModel>(
                            create: (context) => FoodSearchScreenViewModel(
                              foodRepository: _repositories.foodRepository,
                              journalRepository: _repositories.journalRepository,
                              settingsRepository: _repositories.settingsRepository,
                            ),
                            child: FoodSearchScreen(),
                          );
                        },
                        OpenEatsJournalStrings.navigatorRouteOnboarding: (contextBuilder) {
                          return ChangeNotifierProvider<OnboardingScreenViewModel>(
                            create: (context) => OnboardingScreenViewModel(
                              settingsRepository: _repositories.settingsRepository,
                              journalRepository: _repositories.journalRepository,
                              darkMode: themeMode == ThemeMode.dark,
                              languageCode: languageCode,
                            ),
                            child: OnboardingScreen(onboardingFinishedCallback: _onboardingFinished),
                          );
                        },
                        OpenEatsJournalStrings.navigatorRouteBarcodeScanner: (contextBuilder) => BarcodeScannerScreen(
                          iconBackGroundColor: _openEatsJournalAppViewModel.darkMode ? Color.fromARGB(255, 83, 83, 83) : Color.fromARGB(255, 255, 255, 255),
                        ),
                        OpenEatsJournalStrings.navigatorRouteFoodEntryEdit: (contextBuilder) {
                          EatsJournalEntry eatsJournalEntry = ModalRoute.of(contextBuilder)!.settings.arguments as EatsJournalEntry;
                          return ChangeNotifierProvider<EatsJournalFoodEntryEditScreenViewModel>(
                            create: (context) => EatsJournalFoodEntryEditScreenViewModel(
                              foodEntry: eatsJournalEntry,
                              journalRepository: _repositories.journalRepository,
                              foodRepository: _repositories.foodRepository,
                              settingsRepository: _repositories.settingsRepository,
                            ),
                            child: EatsJournalFoodEntryEditScreen(),
                          );
                        },
                        OpenEatsJournalStrings.navigatorRouteFoodEdit: (contextBuilder) {
                          Food food = ModalRoute.of(contextBuilder)!.settings.arguments as Food;
                          return ChangeNotifierProvider<FoodEditScreenViewModel>(
                            create: (context) => FoodEditScreenViewModel(food: food, foodRepository: _repositories.foodRepository),
                            child: FoodEditScreen(),
                          );
                        },
                        OpenEatsJournalStrings.navigatorRouteQuickEntryEdit: (contextBuilder) {
                          EatsJournalEntry eatsJournalEntry = ModalRoute.of(contextBuilder)!.settings.arguments as EatsJournalEntry;
                          return ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
                            create: (context) => EatsJournalQuickEntryEditScreenViewModel(
                              quickEntry: eatsJournalEntry,
                              journalRepository: _repositories.journalRepository,
                              settingsRepository: _repositories.settingsRepository,
                            ),
                            child: EatsJournalQuickEntryEditScreen(),
                          );
                        },
                      },
                      navigatorKey: AppGlobal.navigatorKey,
                    );
                  } else {
                    throw StateError("Something went wrong: standard foods not loaded.");
                  }
                },
              );
            }
          },
        );
      },
    );
  }

  void _onboardingFinished() {
    _openEatsJournalAppViewModel.startListening();
  }

  @override
  Future<void> dispose() async {
    await _repositories.settingsRepository.closeDatabase();
    _repositories.settingsRepository.dispose();

    super.dispose();
  }
}
