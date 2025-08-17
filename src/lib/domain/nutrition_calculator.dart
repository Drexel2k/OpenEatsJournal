import "package:openeatsjournal/domain/gender.dart";

class NutritionCalculator {

  //calculation according to Mifflin St Jeor equation
  static double calculateBasalMetabolicRate({required double weightKg, required int heightCm, required int ageYear, required Gender gender}) {
    final int genderFactor = gender == Gender.male? 5 : -161;
    return 10 * weightKg + 6.25 * heightCm - 5 * ageYear + genderFactor;
  }

  static double calculateTotalKCaloriesPerDay({required double kCaloriesPerDay, required double activityFactor}) {
    return kCaloriesPerDay * activityFactor;
  }

  static double calculateTargetCaloriesPerDay({required double kCaloriesPerDay, required double weightLossPerWeekKg}) {
    return kCaloriesPerDay - (weightLossPerWeekKg * 7000 / 7);
  }

  static double calculateCarbohydrateDemandByKCalories({required double kCalories}) {
    return kCalories * 0.55 * 0.24;
  }

  static double calculateProteinDemandByKCalories({required double kCalories}) {
    return kCalories * 0.3 * 0.11;
  }

  static double calculateFatDemandByKCalories({required double kCalories}) {
    return kCalories * 0.15 * 0.24;
  }
}