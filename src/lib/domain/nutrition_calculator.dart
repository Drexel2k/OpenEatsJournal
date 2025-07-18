class NutritionCalculator {

  //calculation according to Mifflin St Jeor equation
  static double calculateBasalMetabolicRate(double weightKg, int heightCm, int ageYear, int gender) {
    final int genderFactor = gender == 1 ? 5 : -161;
    return 10 * weightKg + 6.25 * heightCm - 5 * ageYear + genderFactor;
  }

  static double calculateTotalKCaloriesPerDay(double weightKg, int heightCm, int ageYear, int gender, double activityFactor) {
    final int genderFactor = gender == 1 ? 5 : -161;
    return (10 * weightKg + 6.25 * heightCm - 5 * ageYear + genderFactor) * activityFactor;
  }

  static double calculateTotalWithWeightLoss(double kCaloriesPerDay, double weightLossPerWeekKg) {
    return kCaloriesPerDay - (weightLossPerWeekKg * 7000 / 7);
  }

  static double calculateCarbohydrateDemandByKCalories(double kCalories) {
    return kCalories * 0.55 * 0.24;
  }

  static double calculateProteinDemandByKCalories(double kCalories) {
    return kCalories * 0.3 * 0.11;
  }

  static double calculateFatDemandByKCalories(double kCalories) {
    return kCalories * 0.15 * 0.24;
  }
}