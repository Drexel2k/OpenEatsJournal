import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:openeatsjournal/domain/utils/energy_unit.dart";
import "package:openeatsjournal/domain/utils/height_unit.dart";
import "package:openeatsjournal/domain/utils/open_eats_journal_strings.dart";
import "package:openeatsjournal/domain/utils/volume_unit.dart";
import "package:openeatsjournal/domain/utils/week_of_year.dart";
import "package:openeatsjournal/domain/utils/weight_unit.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";

class ConvertValidate {
  ConvertValidate._();

  static void init({
    required String languageCode,
    required EnergyUnit energyUnit,
    required HeightUnit heightUnit,
    required WeightUnit weightUnit,
    required VolumeUnit volumeUnit,
  })  {
    numberFomatterInt = NumberFormat(null, languageCode);
    //use onyl for parsing directly, for formatting use getCleanDoubleString or getCleanDoubleEditString
    numberFomatterDouble = NumberFormat.decimalPatternDigits(locale: languageCode, decimalDigits: 1);
    _decimalSeparator = NumberFormat.decimalPattern(languageCode).symbols.DECIMAL_SEP;

    dateFormatterDisplayLongDateOnly = DateFormat.yMMMMd(languageCode);
    dateFormatterDisplayMediumDateOnly = DateFormat.yMMMd(languageCode);

    _energyUnit = energyUnit;
    _heightUnit = heightUnit;
    _weightUnit = weightUnit;
    _volumeUnit = volumeUnit;
  }

  //https://de.wikipedia.org/wiki/Energie https://www.gesundheit.gv.at/leben/ernaehrung/info/grundumsatz.html https://www.tk.de/techniker/gesundheit-foerdern/gesunde-ernaehrung/uebergewicht-und-diaet/wie-viele-kalorien-pro-tag-2006758
  static const double kJoulekCalConversionFactor = 4.184;
  static const double cmInchConversionFactor = 2.54; //https://de.wikipedia.org/wiki/Zoll_(Einheit)
  static const double mlFlOzGbConversionFactor = 28.4130642624675; //https://de.wikipedia.org/wiki/Fluid_ounce
  static const double mlFlOzUsConversionFactor = 29.5735295625; //https://de.wikipedia.org/wiki/Fluid_ounce
  static const double gOzConversionFactor = 28.349523125; //https://de.wikipedia.org/wiki/Unze

  static late NumberFormat numberFomatterInt;
  static late NumberFormat numberFomatterDouble;
  static final DateFormat dateformatterDatabaseDateOnly = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
  static final DateFormat dateFormatterDatabaseDateAndTime = DateFormat(OpenEatsJournalStrings.dbDateFormatDateAndTime);
  static late DateFormat dateFormatterDisplayLongDateOnly;
  static late DateFormat dateFormatterDisplayMediumDateOnly;
  static late String _decimalSeparator;

  static late EnergyUnit _energyUnit;
  static late HeightUnit _heightUnit;
  static late WeightUnit _weightUnit;
  static late VolumeUnit _volumeUnit;

  static String getLocalizedEnergyUnitAbbreviated({required BuildContext context}) {
    if (_energyUnit == EnergyUnit.kcal) {
      return AppLocalizations.of(context)!.kcal;
    }

    return AppLocalizations.of(context)!.kjoule_abbreviated;
  }

  static String getLocalizedEnergyUnit({required BuildContext context}) {
    if (_energyUnit == EnergyUnit.kcal) {
      return AppLocalizations.of(context)!.kcal;
    }

    return AppLocalizations.of(context)!.kjoule;
  }

  static String getLocalizedHeightUnitAbbreviated({required BuildContext context}) {
    if (_heightUnit == HeightUnit.cm) {
      return AppLocalizations.of(context)!.cm;
    }

    return AppLocalizations.of(context)!.inch_abbreviated;
  }

  static String getLocalizedWeightUnitGAbbreviated({required BuildContext context}) {
    if (_weightUnit == WeightUnit.g) {
      return AppLocalizations.of(context)!.gram_abbreviated;
    }

    return AppLocalizations.of(context)!.ounce_abbreviated;
  }

  static String getLocalizedWeightUnitKgAbbreviated({required BuildContext context}) {
    if (_weightUnit == WeightUnit.g) {
      return AppLocalizations.of(context)!.kg;
    }

    return AppLocalizations.of(context)!.lb;
  }

  static String getLocalizedWeightUnitG({required BuildContext context}) {
    if (_weightUnit == WeightUnit.g) {
      return AppLocalizations.of(context)!.gram;
    }

    return AppLocalizations.of(context)!.ounce;
  }

  static String getLocalizedVolumeUnitAbbreviated({required BuildContext context}) {
    if (_volumeUnit == VolumeUnit.ml) {
      return AppLocalizations.of(context)!.milliliter_abbreviated;
    }

    if (_volumeUnit == VolumeUnit.flOzGb) {
      return AppLocalizations.of(context)!.fluid_ounce_gb_abbreviated;
    }

    return AppLocalizations.of(context)!.fluid_ounce_us_abbreviated;
  }

  static String getLocalizedVolumeUnit2char({required BuildContext context}) {
    if (_volumeUnit == VolumeUnit.ml) {
      return AppLocalizations.of(context)!.milliliter_abbreviated;
    }

    return AppLocalizations.of(context)!.fluid_ounce_2char;
  }

  static String getLocalizedVolumeUnit({required BuildContext context}) {
    if (_volumeUnit == VolumeUnit.ml) {
      return AppLocalizations.of(context)!.milliliter;
    }

    if (_volumeUnit == VolumeUnit.flOzGb) {
      return AppLocalizations.of(context)!.fluid_ounce_gb;
    }

    return AppLocalizations.of(context)!.fluid_ounce_us;
  }

  static double _getCmFromInch({required num inch}) {
    return inch * ConvertValidate.cmInchConversionFactor;
  }

  static double _getInchFromCm({required num cm}) {
    return cm / ConvertValidate.cmInchConversionFactor;
  }

  static double _getMlFromFlOzGb({required num flOz}) {
    return flOz * ConvertValidate.mlFlOzGbConversionFactor;
  }

  static double _getFlOzGbFromMl({required num ml}) {
    return ml / ConvertValidate.mlFlOzGbConversionFactor;
  }

  static double _getMlFromFlOzUs({required num flOz}) {
    return flOz * ConvertValidate.mlFlOzUsConversionFactor;
  }

  static double _getFlOzUsFromMl({required num ml}) {
    return ml / ConvertValidate.mlFlOzUsConversionFactor;
  }

  static double _getGFromOz({required num oz}) {
    return oz * ConvertValidate.gOzConversionFactor;
  }

  static double _getOzFromG({required num g}) {
    return g / ConvertValidate.gOzConversionFactor;
  }

  static int getKCalsFromKJoules({required num kJoules}) {
    return (kJoules / ConvertValidate.kJoulekCalConversionFactor).round();
  }

  static int getKJoulesFromKCals({required num kCals}) {
    return (kCals * ConvertValidate.kJoulekCalConversionFactor).round();
  }

  static double getDisplayHeight({required double heightCm}) {
    if (_heightUnit == HeightUnit.cm) {
      return heightCm;
    }

    return _getInchFromCm(cm: heightCm);
  }

  static double getHeightCm({required double displayHeight}) {
    if (_heightUnit == HeightUnit.cm) {
      return displayHeight;
    }

    return _getCmFromInch(inch: displayHeight);
  }

  static double getDisplayWeightG({required double weightG}) {
    if (_weightUnit == WeightUnit.g) {
      return weightG;
    }

    return _getOzFromG(g: weightG);
  }

  static double getWeightG({required double displayWeight}) {
    if (_weightUnit == WeightUnit.g) {
      return displayWeight;
    }

    return _getGFromOz(oz: displayWeight);
  }

  static double getDisplayWeightKg({required double weightKg}) {
    if (_weightUnit == WeightUnit.g) {
      return weightKg;
    }

    return _getOzFromG(g: weightKg * 1000) / 16;
  }

  static double getWeightKg({required double displayWeight}) {
    if (_weightUnit == WeightUnit.g) {
      return displayWeight;
    }

    return _getGFromOz(oz: displayWeight * 16) / 1000;
  }

  static double getDisplayVolume({required double volumeMl}) {
    if (_volumeUnit == VolumeUnit.ml) {
      return volumeMl;
    }

    if (_volumeUnit == VolumeUnit.flOzGb) {
      return _getFlOzGbFromMl(ml: volumeMl);
    }

    return _getFlOzUsFromMl(ml: volumeMl);
  }

  static double getVolumeMl({required double displayVolume}) {
    if (_volumeUnit == VolumeUnit.ml) {
      return displayVolume;
    }

    if (_volumeUnit == VolumeUnit.flOzGb) {
      return _getMlFromFlOzGb(flOz: displayVolume);
    }

    return _getMlFromFlOzUs(flOz: displayVolume);
  }

  static int getDisplayEnergy({required int energyKJ}) {
    if (_energyUnit == EnergyUnit.kj) {
      return energyKJ;
    }

    return getKCalsFromKJoules(kJoules: energyKJ);
  }

  static int getEnergyKJ({required int displayEnergy}) {
    if (_energyUnit == EnergyUnit.kj) {
      return displayEnergy;
    }

    return getKJoulesFromKCals(kCals: displayEnergy);
  }

  //cuts off trailing comma or 0
  static String getCleanDoubleString({required double doubleValue}) {
    String decimalString = numberFomatterDouble.format(doubleValue);
    bool cleaned = false;

    while (!cleaned) {
      if (decimalString.contains(_decimalSeparator) && (decimalString.endsWith(_decimalSeparator) || decimalString.endsWith("0"))) {
        decimalString = decimalString.substring(0, decimalString.length - 1);
      } else {
        cleaned = true;
      }
    }

    return decimalString;
  }

  //if original string ended with decimal separator, leave it to allow adding of decimals durign editing.
  static String getCleanDoubleEditString({required double doubleValue, required String doubleValueString}) {
    String decimalString = getCleanDoubleString(doubleValue: doubleValue);

    if (doubleValueString.endsWith(_decimalSeparator)) {
      decimalString = "$decimalString$_decimalSeparator";
    }

    return decimalString;
  }

  static WeekOfYear getweekOfYear(DateTime date) {
    int year = date.year;
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekOfYear = ((dayOfYear - date.weekday + 10) / 7).floor();

    if (weekOfYear < 1) {
      weekOfYear = _getWeekCount(date.year - 1);
      year = year - 1;
    } else if (weekOfYear > _getWeekCount(date.year)) {
      weekOfYear = 1;
    }

    return WeekOfYear(week: weekOfYear, year: year);
  }

  static DateTime getWeekStartDate(DateTime date) {
    if (date.weekday != 1) {
      return date.subtract(Duration(days: date.weekday - 1));
    }

    return DateTime(date.year, date.month, date.day);
  }

  static int _getWeekCount(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  //Currently all editors accept only decimal numbers with one number after the decimal separator. Returning the old value if the user wants to enter a 2nd
  //number after the decimal separator ensures that there are no rounding issues, when parsing the number first and then let the getCleanDouble... beautify it.
  static bool decimalHasMoreThan1Fraction({required String decimalstring}) {
    List<String> numberParts = decimalstring.split(_decimalSeparator);
    if (numberParts.isEmpty || numberParts.length > 2) {
      throw ArgumentError("Unexpected number part count.");
    }

    if (numberParts.length == 2) {
      if (numberParts[1].trim().length > 1) {
        return true;
      }
    }

    return false;
  }
}
