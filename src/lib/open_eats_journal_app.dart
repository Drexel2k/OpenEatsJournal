import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/open_eats_journal_viewmodel.dart";
import "package:openeatsjournal/repository/settings_repository.dart";
import "package:openeatsjournal/repository/weight_repository.dart";
import "package:openeatsjournal/ui/screens/home.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding.dart";
import "package:openeatsjournal/ui/screens/onboarding/onboarding_viewmodel.dart";

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
    }

    return ValueListenableBuilder(
      valueListenable: widget._openEatsJournalAppViewModel.darkMode,
      builder: (_, _, _) {
        return MaterialApp(
          home: Scaffold(
            appBar: PreferredSize(
              //needs to be adjusted if a bottom tab bar is needed e.g.
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: ValueListenableBuilder(
                valueListenable: widget._openEatsJournalAppViewModel.scaffoldTitle,
                builder: (_, _, _) {
                  return Visibility(
                    visible: widget._openEatsJournalAppViewModel.scaffoldTitle.value.trim().isNotEmpty,
                    child: AppBar(
                      leading: Visibility(
                        visible: widget._openEatsJournalAppViewModel.showScaffoldLeadingAction,
                        child: IconButton(icon: BackButtonIcon(), onPressed: widget._openEatsJournalAppViewModel.scaffoldLeadingAction!)
                      ),
                      title: Text(widget._openEatsJournalAppViewModel.scaffoldTitle.value)
                    )
                  );
                }
              )
            ),
            body: widget._openEatsJournalAppViewModel.initialized.value ? 
            HomeScreen() :
            OnboardingScreen(
              onboardingViewModel: OnboardingViewModel(
                darkMode: themeMode == ThemeMode.dark,
                settingsRepositoy: widget._settingsRepositoy,
                weighRepository: widget._weightRepository,
              ),
            ),
            bottomNavigationBar: ValueListenableBuilder(
              valueListenable: widget._openEatsJournalAppViewModel.initialized,
              builder: (_, initialized, _) {
                return Visibility(
                  visible: widget._openEatsJournalAppViewModel.initialized.value,
                  child: NavigationBar(
                    onDestinationSelected: (int index) {
                      setState(() {
                        currentPageIndex = index;
                      });                      
                    },
                    selectedIndex: 0,
                    destinations: const <Widget>[
                      NavigationDestination(
                        icon: Icon(Icons.lunch_dining),
                        label: "Food",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.home),
                        label: "Home",
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.insights),
                        label: "Statistics",
                      ),
                    ],
                  ) 
                );
              }
            )
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale("de"),
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant)),
          darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant, brightness: Brightness.dark)),
          themeMode: themeMode
        );
      },
    );
  }
}
