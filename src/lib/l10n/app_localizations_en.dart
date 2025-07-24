// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about_this_app => 'About this app';

  @override
  String get tell_about_yourself => 'Tell about yourself';

  @override
  String get your_targets => 'You targets';

  @override
  String get daily_overview => 'Daily Overview';

  @override
  String get welcome => 'Welcome! ';

  @override
  String get welcome_message_1 =>
      'Welccome to Open Eats Journal, a free and Open Source Eats Journal to track your food intake and nutritions.';

  @override
  String get welcome_message_2 =>
      'The app needs to know some data from you to calculate nutrition target value proposals, this data is only stored on your device.';

  @override
  String get welcome_message_3 =>
      'Please notice, that this is no medical advice and that the app was not made by a medic or nutrition expert.';

  @override
  String get welcome_message_4 =>
      'The local standard groceries database was made by best effort and for barcode food Open Food Facts is used.';

  @override
  String get welcome_message_5 => 'In any doubt consult a doctor.';

  @override
  String get welcome_message_6 => 'Stay healthy!';

  @override
  String get welcome_message_7 =>
      'The app comes with no warranties and is licensed under AGPLv3. Please visit https://github.com/Drexel2k/OpenEatsJournal to give feedback, report issues or contribute.';

  @override
  String get agree_proceed => 'Agree & Proceed';

  @override
  String get proceed => 'Proceed';

  @override
  String get finish => 'Finish';

  @override
  String get license_agree =>
      'I agree to the license and to the data privacy policy.';

  @override
  String get license_must_agree =>
      'You must agree to the license and privacy policy.';

  @override
  String get close => 'Close';

  @override
  String get understood => 'I understood.';

  @override
  String get must_understood => 'You must confirm to understand the hints.';

  @override
  String get your_gender => 'Your gender:';

  @override
  String get male => 'male';

  @override
  String get female => 'female';

  @override
  String get your_birthday => 'Your birthday:';

  @override
  String get your_height => 'Your height (cm):';

  @override
  String get your_weight => 'Your weight (kg):';

  @override
  String get birthday => 'Birthday';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get your_acitivty_level => 'Your activity level:';

  @override
  String get acitivity_level_explanation =>
      'Very low: \nSitting, no activity\n\nLow: \nSitting, light sports (1-2 times / week)\n\nMedium: \nPredominantly sitting, some walking, moderate sports (2-3 times / week)\n\nHigh: \nPredominantly standing/walking, demanding sports (3-5 times / week)\n\nVery high: \nPhysical demanding, demanding sports (6-7 times / week)';

  @override
  String get very_low => 'Very low';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get very_high => 'Very High';

  @override
  String get professional_athlete => 'Professional Athlete';

  @override
  String get select_gender => 'Please select your gender.';

  @override
  String get select_birthday => 'Please select your birth day.';

  @override
  String get select_height => 'Please enter your height.';

  @override
  String get select_weight => 'Please enter your weight.';

  @override
  String get select_activity_level => 'Please select your activity level.';

  @override
  String get your_weight_target => 'Your weight target:';

  @override
  String get keep_weight => 'Keep weight';

  @override
  String get lose025 => 'Lose 0,25kg per week';

  @override
  String get lose05 => 'Lose 0,5kg per week';

  @override
  String get lose075 => 'Lose 0,75kg per week';

  @override
  String get proposed_values =>
      'These are proposed target values based on Mifflin-St Jeor Equation and the physical activity level factor by the Food and Agriculture Organization of the United Nations. These values can still be adjusted in the settings (even per weekday).';

  @override
  String get in_doubt_consult_doctor =>
      'Individual values may differ, losing weight too fast is unhealthy and may be dangerous. In doubt consult a nutrition expert or doctor.';

  @override
  String get select_target => 'Please select a target.';

  @override
  String get your_calories_values => 'Your calories values:';

  @override
  String get daily_calories => 'Daily kCalories:';

  @override
  String get daily_weightloss_calories => 'Daily weightloss kCalories:';
}
