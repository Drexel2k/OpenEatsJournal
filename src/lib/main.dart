import "package:flutter/material.dart";
//import "package:flutter/rendering.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";
import "package:openeatsjournal/service/oej_database_service.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding.dart";
import "package:openeatsjournal/ui/screens/home.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";

Future<void> main() async {
  final OejDatabaseService oejDatabase = OejDatabaseService.instance;
  final SettingsRepositoy settingsRepositoy = SettingsRepositoy.instance;
  final WeightRepositoy weightRepository = WeightRepositoy.instance;

  settingsRepositoy.setOejDatabase(oejDatabase);
  weightRepository.setOejDatabase(oejDatabase);

  WidgetsFlutterBinding.ensureInitialized();
  //debugPaintSizeEnabled=true;
  bool initialized = await settingsRepositoy.initSettings();

  runApp(
    OpenEatsJournalApp(
      initialized: initialized,
      settingsRepositoy: settingsRepositoy,
      weightRepository: weightRepository
    ),
  );
}

class OpenEatsJournalApp extends StatelessWidget {
  const OpenEatsJournalApp({
      super.key,
      required initialized,
      required settingsRepositoy,
      required weightRepository,
    }
  ) : 
    _initialized = initialized,
    _settingsRepositoy = settingsRepositoy,
    _weightRepository = weightRepository;

  final bool _initialized;
  final SettingsRepositoy _settingsRepositoy;
  final WeightRepositoy _weightRepository;  

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = ThemeMode.light;
    if (_initialized) {
      if(_settingsRepositoy.darkMode.value) {
        themeMode = ThemeMode.dark;
      }
    }
    else {
      Brightness brightness = MediaQuery.of(context).platformBrightness;
      if (brightness == Brightness.dark) {
        themeMode = ThemeMode.dark;
      }
    }

    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          if (_initialized) {
              return HomeScreen();
            }
          else {
            return OnboardingScreen(
              onboardingViewModel: OnboardingViewModel(
                themeMode == ThemeMode.dark,
                _settingsRepositoy,
                _weightRepository,
              ),
            );
          }
        }
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale("de"),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant)),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant, brightness: Brightness.dark)),
      themeMode: themeMode
    );
  }
}