import "package:flutter/material.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/onboarding/onboarding.dart";

void main() {
  runApp(const OpenEatsJournalApp());
}

class OpenEatsJournalApp extends StatelessWidget {
  const OpenEatsJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:   UiRoot(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale("de"),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700, dynamicSchemeVariant: DynamicSchemeVariant.vibrant)
      ),
    );
  }
}

class UiRoot extends StatefulWidget {
  const UiRoot({super.key});

  @override
  State<UiRoot> createState() => _UiRootState();
}

class _UiRootState extends State<UiRoot> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.welcome_to_openeatsjournal),
      ),
      body:const OnboardingPageView(),
    );
  }
}