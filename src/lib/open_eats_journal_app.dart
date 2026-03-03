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
import "package:openeatsjournal/repository/food_repository.dart";
import "package:openeatsjournal/repository/journal_repository.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/ui/utils/open_eats_journal_colors.dart";
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
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:provider/provider.dart";

class OpenEatsJournalApp extends StatefulWidget {
  const OpenEatsJournalApp({super.key});

  @override
  State<OpenEatsJournalApp> createState() => _OpenEatsJournalAppState();
}

class _OpenEatsJournalAppState extends State<OpenEatsJournalApp> with SingleTickerProviderStateMixin {
  late AnimationController _overlayAnimationController;

  @override
  void initState() {
    super.initState();

    _overlayAnimationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OpenEatsJournalAppViewModel>(
      builder: (context, openEatsJournalAppViewModel, _) => ListenableBuilder(
        listenable: openEatsJournalAppViewModel.appWideSettingChanged,
        builder: (contextBuilder, _) {
          return FutureBuilder<void>(
            future: openEatsJournalAppViewModel.settingsLoaded,
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

                if (openEatsJournalAppViewModel.onboarded) {
                  openEatsJournalAppViewModel.startListening();
                  if (openEatsJournalAppViewModel.darkMode) {
                    themeMode = ThemeMode.dark;
                  }

                  languageCode = openEatsJournalAppViewModel.languageCode;
                  energyUnit = openEatsJournalAppViewModel.energyUnit;
                  heightUnit = openEatsJournalAppViewModel.heightUnit;
                  weightUnit = openEatsJournalAppViewModel.weightUnit;
                  volumeUnit = openEatsJournalAppViewModel.volumeUnit;
                } else {
                  Brightness brightness = MediaQuery.platformBrightnessOf(context);
                  if (brightness == Brightness.dark) {
                    themeMode = ThemeMode.dark;
                  }

                  String platformLanguageCode = PlatformDispatcher.instance.locale.languageCode;
                  if (AppLocalizations.supportedLocales.any((locale) => locale.languageCode == platformLanguageCode)) {
                    languageCode = platformLanguageCode;
                  }

                  initialRoute = OpenEatsJournalStrings.navigatorRouteOnboarding;
                }

                final ConvertValidate convert = ConvertValidate(
                  languageCode: languageCode,
                  energyUnit: energyUnit,
                  heightUnit: heightUnit,
                  weightUnit: weightUnit,
                  volumeUnit: volumeUnit,
                );

                openEatsJournalAppViewModel.initStandardFoodData(languageCode: languageCode);

                //we need a second future to ensure sequence of loading settings and loading standard food data that changes settings.
                return FutureBuilder<void>(
                  future: openEatsJournalAppViewModel.dataInitialized,
                  builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      throw StateError("Something went wrong: ${snapshot.error}");
                    } else if (snapshot.hasData) {
                      openEatsJournalAppViewModel.saveLastProcessedStandardFoodDataDate(snapshot.data as DateTime);

                      SettingsRepository settingsRepository = Provider.of<SettingsRepository>(context, listen: false);
                      FoodRepository foodRepository = Provider.of<FoodRepository>(context, listen: false);
                      JournalRepository journalRepository = Provider.of<JournalRepository>(context, listen: false);
                      
                      OverlayDisplay overlayDisplay = OverlayDisplay(
                        animationController: _overlayAnimationController,
                      );

                      return MultiProvider(
                        providers: [
                          Provider.value(value: convert),
                          Provider.value(value: overlayDisplay),
                        ],
                        child: MaterialApp(
                          builder: (context, child) {
                            return Overlay(
                              initialEntries: [
                                OverlayEntry(
                                  builder: (context) {
                                    return child!;
                                  },
                                ),
                              ],
                            );
                          },
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
                                shadowColor: Color.fromARGB(255, 0, 0, 0),
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
                                shadowColor: Color.fromARGB(255, 78, 78, 78),
                              ),
                            ],
                          ),
                          themeMode: themeMode,
                          initialRoute: initialRoute,
                          routes: {
                            OpenEatsJournalStrings.navigatorRouteEatsJournal: (contextBuilder) {
                              return ChangeNotifierProvider<EatsJournalScreenViewModel>(
                                create: (context) => EatsJournalScreenViewModel(journalRepository: journalRepository, settingsRepository: settingsRepository),
                                child: EatsJournalScreen(),
                              );
                            },
                            OpenEatsJournalStrings.navigatorRouteStatistics: (contextBuilder) {
                              return ChangeNotifierProvider<StatisticsScreenViewModel>(
                                create: (context) => StatisticsScreenViewModel(settingsRepository: settingsRepository, journalRepository: journalRepository),
                                child: StatisticsScreen(),
                              );
                            },
                            OpenEatsJournalStrings.navigatorRouteFood: (contextBuilder) {
                              return ChangeNotifierProvider<FoodSearchScreenViewModel>(
                                create: (context) => FoodSearchScreenViewModel(
                                  foodRepository: foodRepository,
                                  journalRepository: journalRepository,
                                  settingsRepository: settingsRepository,
                                ),
                                child: FoodSearchScreen(),
                              );
                            },
                            OpenEatsJournalStrings.navigatorRouteOnboarding: (contextBuilder) {
                              return ChangeNotifierProvider<OnboardingScreenViewModel>(
                                create: (context) => OnboardingScreenViewModel(
                                  journalRepository: journalRepository,
                                  settingsRepository: settingsRepository,
                                  convert: convert,
                                  darkMode: themeMode == ThemeMode.dark,
                                  languageCode: languageCode,
                                ),
                                child: OnboardingScreen(onboardingFinishedCallback: _onboardingFinished),
                              );
                            },
                            OpenEatsJournalStrings.navigatorRouteBarcodeScanner: (contextBuilder) => BarcodeScannerScreen(
                              iconBackGroundColor: openEatsJournalAppViewModel.darkMode ? Color.fromARGB(255, 83, 83, 83) : Color.fromARGB(255, 255, 255, 255),
                            ),
                            OpenEatsJournalStrings.navigatorRouteFoodEntryEdit: (contextBuilder) {
                              EatsJournalEntry eatsJournalEntry = ModalRoute.of(contextBuilder)!.settings.arguments as EatsJournalEntry;
                              return ChangeNotifierProvider<EatsJournalFoodEntryEditScreenViewModel>(
                                create: (context) => EatsJournalFoodEntryEditScreenViewModel(
                                  foodEntry: eatsJournalEntry,
                                  journalRepository: journalRepository,
                                  foodRepository: foodRepository,
                                  settingsRepository: settingsRepository,
                                  convert: convert,
                                ),
                                child: EatsJournalFoodEntryEditScreen(),
                              );
                            },
                            OpenEatsJournalStrings.navigatorRouteFoodEdit: (contextBuilder) {
                              Food food = ModalRoute.of(contextBuilder)!.settings.arguments as Food;
                              return ChangeNotifierProvider<FoodEditScreenViewModel>(
                                create: (context) => FoodEditScreenViewModel(food: food, foodRepository: foodRepository, convert: convert),
                                child: FoodEditScreen(),
                              );
                            },
                            OpenEatsJournalStrings.navigatorRouteQuickEntryEdit: (contextBuilder) {
                              EatsJournalEntry eatsJournalEntry = ModalRoute.of(contextBuilder)!.settings.arguments as EatsJournalEntry;
                              return ChangeNotifierProvider<EatsJournalQuickEntryEditScreenViewModel>(
                                create: (context) => EatsJournalQuickEntryEditScreenViewModel(
                                  quickEntry: eatsJournalEntry,
                                  journalRepository: journalRepository,
                                  settingsRepository: settingsRepository,
                                  convert: convert,
                                ),
                                child: EatsJournalQuickEntryEditScreen(),
                              );
                            },
                          },
                          navigatorKey: AppGlobal.navigatorKey,
                        ),
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
      ),
    );
  }

  void _onboardingFinished() {
    Provider.of<OpenEatsJournalAppViewModel>(context, listen: false).startListening();
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();

    super.dispose();
  }
}
