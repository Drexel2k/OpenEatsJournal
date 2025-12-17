import "package:openeatsjournal/domain/gender.dart";

class NutritionCalculator {
  //Deutsche Gesellschaft für Ernährung
  //https://www.dge.de/wissenschaft/referenzwerte/energie/
  static const double _kCalKJouleConversionFactor = 4.184;
  static const int kJouleForOnekCal = 4;

  //calculation according to Mifflin St Jeor equation
  static double calculateBasalMetabolicRateInKJoule({
    required double weightKg,
    required int heightCm,
    required int ageYear,
    required Gender gender,
  }) {
    final int genderFactor = gender == Gender.male ? 5 : -161;
    return (10 * weightKg + 6.25 * heightCm - 5 * ageYear + genderFactor) * _kCalKJouleConversionFactor;
  }

  static double calculateTotalKJoulePerDay({required double kJoulePerDay, required double activityFactor}) {
    return kJoulePerDay * activityFactor;
  }

  static double calculateTargetKJoulePerDay({required double kJoulePerDay, required double weightLossPerWeekKg}) {
    return kJoulePerDay - (weightLossPerWeekKg * 29288 / 7);
  }

  //Deutsche Gesellschaft für Ernährung
  //https://www.dge.de/wissenschaft/referenzwerte/energie/
  //https://www.dge.de/gesunde-ernaehrung/faq/energiezufuhr/
  //https://www.dge.de/blog/2023/fett-in-der-ernaehrung-fakten-rund-um-die-bedeutung-von-fett-fuer-den-koerper/
  //https://www.dge.de/wissenschaft/stellungnahmen-und-fachinformationen/positionen/richtwerte-fuer-die-energiezufuhr-aus-kohlenhydraten-und-fett/
  //https://www.ernaehrung.de/tipps/allgemeine_infos/ernaehr13.php
  //55 (55-60) % Carbohydrates,  1g = 17kJ, 4kCal
  //15 (10-15) % Protein,  1g = 17kJ, 4kCal
  //30 % Fat,  1g = 37kJ, 7kCal
  static double calculateCarbohydrateDemandByKJoule({required int kJoule}) {
    return kJoule / 17 * 0.55;
  }

  static double calculateProteinDemandByKJoule({required int kJoule}) {
    return kJoule / 17 * 0.15 ;
  }

  static double calculateFatDemandByKJoule({required int kJoule}) {
    return kJoule / 37 * 0.3;
  }

  static int getKCalsFromKJoules({required num kJoules}) {
    return (kJoules / _kCalKJouleConversionFactor).round();
  }

  static int getKJoulesFromKCals({required num kCals}) {
    return (kCals * _kCalKJouleConversionFactor).round();
  }
}
