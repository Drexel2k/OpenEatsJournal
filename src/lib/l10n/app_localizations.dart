import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @about_this_app.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get about_this_app;

  /// No description provided for @tell_about_yourself.
  ///
  /// In en, this message translates to:
  /// **'Tell about yourself'**
  String get tell_about_yourself;

  /// No description provided for @your_targets.
  ///
  /// In en, this message translates to:
  /// **'You targets'**
  String get your_targets;

  /// No description provided for @daily_overview.
  ///
  /// In en, this message translates to:
  /// **'Daily Overview'**
  String get daily_overview;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome! '**
  String get welcome;

  /// No description provided for @welcome_message_1.
  ///
  /// In en, this message translates to:
  /// **'Welccome to Open Eats Journal, a free and Open Source Eats Journal to track your food intake and nutritions.'**
  String get welcome_message_1;

  /// No description provided for @welcome_message_2.
  ///
  /// In en, this message translates to:
  /// **'The app needs to know some data from you to calculate nutrition target value proposals, this data is only stored on your device.'**
  String get welcome_message_2;

  /// No description provided for @welcome_message_3.
  ///
  /// In en, this message translates to:
  /// **'Please notice, that this is no medical advice and that the app was not made by a medic or nutrition expert.'**
  String get welcome_message_3;

  /// No description provided for @welcome_message_4.
  ///
  /// In en, this message translates to:
  /// **'The local standard groceries database was made by best effort and for barcode food Open Food Facts is used.'**
  String get welcome_message_4;

  /// No description provided for @welcome_message_5.
  ///
  /// In en, this message translates to:
  /// **'In any doubt consult a doctor.'**
  String get welcome_message_5;

  /// No description provided for @welcome_message_6.
  ///
  /// In en, this message translates to:
  /// **'Stay healthy!'**
  String get welcome_message_6;

  /// No description provided for @welcome_message_7.
  ///
  /// In en, this message translates to:
  /// **'The app comes with no warranties and is licensed under AGPLv3. Please visit https://github.com/Drexel2k/OpenEatsJournal to give feedback, report issues or contribute.'**
  String get welcome_message_7;

  /// No description provided for @agree_proceed.
  ///
  /// In en, this message translates to:
  /// **'Agree & Proceed'**
  String get agree_proceed;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @license_agree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the license and to the data privacy policy.'**
  String get license_agree;

  /// No description provided for @license_must_agree.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the license and privacy policy.'**
  String get license_must_agree;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'I understood.'**
  String get understood;

  /// No description provided for @must_understood.
  ///
  /// In en, this message translates to:
  /// **'You must confirm to understand the hints.'**
  String get must_understood;

  /// No description provided for @your_gender.
  ///
  /// In en, this message translates to:
  /// **'Your gender:'**
  String get your_gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'female'**
  String get female;

  /// No description provided for @your_birthday.
  ///
  /// In en, this message translates to:
  /// **'Your birthday:'**
  String get your_birthday;

  /// No description provided for @your_height.
  ///
  /// In en, this message translates to:
  /// **'Your height (cm):'**
  String get your_height;

  /// No description provided for @your_weight.
  ///
  /// In en, this message translates to:
  /// **'Your weight (kg):'**
  String get your_weight;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @your_acitivty_level.
  ///
  /// In en, this message translates to:
  /// **'Your activity level:'**
  String get your_acitivty_level;

  /// No description provided for @acitivity_level_explanation.
  ///
  /// In en, this message translates to:
  /// **'Very low: \nSitting, no activity\n\nLow: \nSitting, light sports (1-2 times / week)\n\nMedium: \nPredominantly sitting, some walking, moderate sports (2-3 times / week)\n\nHigh: \nPredominantly standing/walking, demanding sports (3-5 times / week)\n\nVery high: \nPhysical demanding, demanding sports (6-7 times / week)'**
  String get acitivity_level_explanation;

  /// No description provided for @very_low.
  ///
  /// In en, this message translates to:
  /// **'Very low'**
  String get very_low;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @very_high.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get very_high;

  /// No description provided for @professional_athlete.
  ///
  /// In en, this message translates to:
  /// **'Professional Athlete'**
  String get professional_athlete;

  /// No description provided for @select_gender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender.'**
  String get select_gender;

  /// No description provided for @select_birthday.
  ///
  /// In en, this message translates to:
  /// **'Please select your birth day.'**
  String get select_birthday;

  /// No description provided for @select_height.
  ///
  /// In en, this message translates to:
  /// **'Please enter your height.'**
  String get select_height;

  /// No description provided for @select_weight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight.'**
  String get select_weight;

  /// No description provided for @select_activity_level.
  ///
  /// In en, this message translates to:
  /// **'Please select your activity level.'**
  String get select_activity_level;

  /// No description provided for @your_weight_target.
  ///
  /// In en, this message translates to:
  /// **'Your weight target:'**
  String get your_weight_target;

  /// No description provided for @keep_weight.
  ///
  /// In en, this message translates to:
  /// **'Keep weight'**
  String get keep_weight;

  /// No description provided for @lose025.
  ///
  /// In en, this message translates to:
  /// **'Lose 0,25kg per week'**
  String get lose025;

  /// No description provided for @lose05.
  ///
  /// In en, this message translates to:
  /// **'Lose 0,5kg per week'**
  String get lose05;

  /// No description provided for @lose075.
  ///
  /// In en, this message translates to:
  /// **'Lose 0,75kg per week'**
  String get lose075;

  /// No description provided for @proposed_values.
  ///
  /// In en, this message translates to:
  /// **'These are proposed target values based on Mifflin-St Jeor Equation and the physical activity level factor by the Food and Agriculture Organization of the United Nations. These values can still be adjusted in the settings (even per weekday).'**
  String get proposed_values;

  /// No description provided for @in_doubt_consult_doctor.
  ///
  /// In en, this message translates to:
  /// **'Individual values may differ, losing weight too fast is unhealthy and may be dangerous. In doubt consult a nutrition expert or doctor.'**
  String get in_doubt_consult_doctor;

  /// No description provided for @select_target.
  ///
  /// In en, this message translates to:
  /// **'Please select a target.'**
  String get select_target;

  /// No description provided for @your_calories_values.
  ///
  /// In en, this message translates to:
  /// **'Your calories values:'**
  String get your_calories_values;

  /// No description provided for @daily_calories.
  ///
  /// In en, this message translates to:
  /// **'Daily kCalories:'**
  String get daily_calories;

  /// No description provided for @daily_weightloss_calories.
  ///
  /// In en, this message translates to:
  /// **'Daily weightloss kCalories:'**
  String get daily_weightloss_calories;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
