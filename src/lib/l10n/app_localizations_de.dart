// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about_this_app => 'Über diese App';

  @override
  String get tell_about_yourself => 'Erzähle von Dir';

  @override
  String get your_targets => 'Deine Ziele';

  @override
  String get daily_overview => 'Tagesübersicht';

  @override
  String get welcome => 'Willkommen! ';

  @override
  String get welcome_message_1 =>
      'Willkommen beim Open Eats Journal, eine freies und Open Source Ernährungstagebuch um Deine Nahrungsaufnahme und Nährwerte nachzuhalten.';

  @override
  String get welcome_message_2 =>
      'Die App braucht ein paar Daten von Dir um Zielwertvorschläge für Deine Nährwerte zu berechnen, diese Daten werden nur auf Deinem Gerät gespeichert.';

  @override
  String get welcome_message_3 =>
      'Bitte beachte, dass das kein medizinischer Rat ist und dass die App nicht von einem Mediziner oder Ernährungsexperten erstellt wurde.';

  @override
  String get welcome_message_4 =>
      'Die lokale Standard Lebensmitteldatenbank wurde nach bestem Wissen und Gewissen erstellt und für Barcode Lebensmittel wird Open Food Facts benutzt.';

  @override
  String get welcome_message_5 => 'Bei Zweifeln konsultiere einen Arzt.';

  @override
  String get welcome_message_6 => 'Bleib gesund!';

  @override
  String get welcome_message_7 =>
      'Die App kommt mit keinerlei Garantien und ist unter AGPLv3 lizenziert. Die Datenschutzerklärung findest Du unter ....Bitte besuche https://github.com/Drexel2k/OpenEatsJournal, um Feedback zu geben, Probleme zu melden oder beizutragen.';

  @override
  String get agree_proceed => 'Zustimmen & Fortfahren';

  @override
  String get proceed => 'Fortfahren';

  @override
  String get finish => 'Fertigstellen';

  @override
  String get license_agree =>
      'Ich stimme der Lizenz und der Datenschutzerklärung zu.';

  @override
  String get license_must_agree =>
      'Du musst der Lizenz und der Datenschutzerklärung zustimmen.';

  @override
  String get close => 'Schließen';

  @override
  String get understood => 'Ich habe verstanden.';

  @override
  String get must_understood =>
      'Du musst bestötigen, die Hinweise verstanden zu haben.';

  @override
  String get your_gender => 'Dein Geschlecht:';

  @override
  String get male => 'Männlich';

  @override
  String get female => 'Weiblich';

  @override
  String get your_birthday => 'Dein Geburtstag:';

  @override
  String get your_height => 'Deine Größe (cm):';

  @override
  String get your_weight => 'Dein Gewicht (kg):';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get height => 'Größe';

  @override
  String get weight => 'Gewicht';

  @override
  String get your_acitivty_level => 'Dein Aktivitätslevel:';

  @override
  String get acitivity_level_explanation =>
      'Sehr niedrig: \nSitzen, keine Aktivität\n\nNiedrig: \nSitzen, wenig Sport (1-2 Mal / Woche)\n\nMedium: \nÜberwiegend sitzen, etwas laufen, moderater Sport (2-3 Mal / Woche)\n\nHoch: \nÜberwiegend stehen/laufen, fordernder Sport (3-5 Mal / Woche)\n\nSehr hoch: \nKörperlich fordernd, fordernder Sport (6-7 Mal / Woche)';

  @override
  String get very_low => 'Sehr niedrig';

  @override
  String get low => 'Niedrig';

  @override
  String get medium => 'Mittel';

  @override
  String get high => 'Hoch';

  @override
  String get very_high => 'Sehr hoch';

  @override
  String get professional_athlete => 'Prof. Sportler';

  @override
  String get select_gender => 'Bitte wähle Dein Geschlecht.';

  @override
  String get select_birthday => 'Bitte wähle Deinen Geburtstag.';

  @override
  String get select_height => 'Bitte gib Deine Größe ein.';

  @override
  String get select_weight => 'Bitte gibt Dein Gewicht ein.';

  @override
  String get select_activity_level => 'Bitte wähle Dein Aktivitätslevel.';

  @override
  String get your_weight_target => 'Dein Gewicht Ziel:';

  @override
  String get keep_weight => 'Gewicht halten';

  @override
  String get lose025 => '-0,25kg pro Woche';

  @override
  String get lose05 => '-0,5kg pro Woche';

  @override
  String get lose075 => '-0,75kg pro Woche';

  @override
  String get proposed_values =>
      'Die vorgeschlagenen Zielwerte basieren auf der Mifflin-St Jeor Formel und dem Phyischen Aktivitätslevel Faktor der Food and Agriculture Organization of the United Nations. In den Einstellungen können diese Werte noch angepasst werden (auch pro Wochentag).';

  @override
  String get in_doubt_consult_doctor =>
      'Individuelle Werte können abweichen, zu schnell Gewicht zu verlieren ist ungesund und kann gefährlich sein. Im Zweifel konsultiere einen Ernährungsexperten oder Arzt.';

  @override
  String get select_target => 'Please select a target.';

  @override
  String get your_calories_values => 'Deine Kalorien Werte:';

  @override
  String get daily_calories => 'Täglicher Bedarf:';

  @override
  String get daily_target_calories => 'Tägliches Ziel kCal (⌀):';

  @override
  String get statistics => 'Statistics';

  @override
  String get kcal => 'kCal';

  @override
  String get fat => 'Fett';

  @override
  String get carb => 'KH';

  @override
  String get prot => 'Prot';

  @override
  String get days => 'Tage';

  @override
  String get weeks => 'Wochen';

  @override
  String get months => 'Monate';

  @override
  String last_amount_timeinfo(Object ammount, Object timeInfo) {
    return 'Letzte $ammount $timeInfo';
  }

  @override
  String average_number(Object average) {
    return 'Durchschnitt: $average';
  }

  @override
  String get app_settings => 'App Einstellungen';

  @override
  String get personal_settings => 'Persönliche Einstellungen';

  @override
  String get app_settings_linebreak => 'App\nEinstellungen';

  @override
  String get personal_settings_linebreak => 'Persönliche\nEinstellungen';

  @override
  String get dark_mode => 'Dark mode';

  @override
  String get language => 'Sprache:';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get recalculate_calories_target => 'Kal. Ziele neu berechnen';

  @override
  String get recalculate_calories_target_hint =>
      'Das Neuberechnen der Kalorien Ziele überschreibt alle täglichen Kalorien Zielwerte.';

  @override
  String get are_you_sure => 'Bist Du sicher?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get edit_calories_target => 'Kalorien Ziele bearbeiten';

  @override
  String get daily_target_new => 'Tägl. Ziel (⌀) neu:';

  @override
  String get daily_target_original => 'Tägl. Ziel (⌀) Original:';

  @override
  String get monday_kcals => 'Montag kCal:';

  @override
  String get tuesday_kcals => 'Dienstag kCal:';

  @override
  String get wednesday_kcals => 'Mittwoch kCal:';

  @override
  String get thursday_kcals => 'Donnerstag kCal:';

  @override
  String get friday_kcals => 'Freitag kCal:';

  @override
  String get saturday_kcals => 'Samstag kCal:';

  @override
  String get sunday_kcals => 'Sonntag kCal:';

  @override
  String amount_kcal(Object amount) {
    return '$amount kcal';
  }
}
