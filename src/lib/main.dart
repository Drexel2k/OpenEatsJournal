import "package:flutter/material.dart";
//import "package:flutter/rendering.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";
import "package:openeatsjournal/service/oej_database_service.dart";
import "package:openeatsjournal/ui/future_builder_nullable_result.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding.dart";
import "package:openeatsjournal/ui/screens/home.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";

void main() {
  //debugPaintSizeEnabled=true;
  runApp(OpenEatsJournalApp());
}

class OpenEatsJournalApp extends StatelessWidget {
  const OpenEatsJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UiRoot(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale("de"),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant)
      ),
    );
  }
}

class UiRoot extends StatelessWidget {
  UiRoot({super.key});

  final OejDatabaseService _oejDatabase = OejDatabaseService.instance;
  final SettingsRepositoy _settingsRepositoy = SettingsRepositoy.instance;
  final WeightRepositoy _weightRepository = WeightRepositoy.instance;
  
  @override
  Widget build(BuildContext context)  {
    _settingsRepositoy.setOejDatabase(_oejDatabase);
    _weightRepository.setOejDatabase(_oejDatabase);

    FutureBuilderNullableResult<DateTime?> birthdayFuture = FutureBuilderNullableResult<DateTime?>(computation: () => _settingsRepositoy.getBirthday());

    return FutureBuilder<FutureBuilderNullableResult<DateTime?>>(
      future: birthdayFuture.getFutureBuilderResult(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<FutureBuilderNullableResult<DateTime?>> snapshot) {
        if (snapshot.hasData) {
          if(snapshot.data!.result != null) {
            return HomeScreen();
          }
          else {
            return OnboardingScreen(onboardingViewModel:OnboardingViewModel(_settingsRepositoy, _weightRepository));
          }
        } else if (snapshot.hasError) {
          return Icon(Icons.error_outline, color: const Color.fromARGB(255, 199, 175, 173), size: 60);
        } else {
          return Scaffold(
            body: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(),
              )
            )
          ); 
        }
      }
    );
  }
}