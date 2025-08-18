import 'package:intl/intl.dart';

class ConvertValidate {
  static double? convertLocalStringToDouble({required String numberString, required String languageCode}) {
    num? number = NumberFormat(null, languageCode).tryParse(numberString);
    return number == null ? null : number as double;
  }

  static int? convertLocalStringToInt({required String numberString, required String languageCode}) {
    num? number = NumberFormat(null, languageCode).tryParse(numberString);
    return number?.toInt();
  }

  //checks a weight string for eon comma and valid number lengths before and after comma
  static bool validateWeight({required String weight, required String decimalSeparator}) {
    //none or multiple digits (\d*) followed by none or one decimalSeparator (\decimalSeparator?) followed by none or multiple digits (\d*)
    var matches = RegExp(r"^\d*\" + decimalSeparator + r"?\d*$").allMatches(weight);
    if (matches.length != 1) {
      return false;
    }

    List<String> parts = weight.split(decimalSeparator);

    if (parts.length > 2) {
      return false;
    }

    if (parts[0].length > 3) {
      return false;
    }

    if (parts.length > 1) {
      if (parts[1].length > 1) {
        return false;
      }
    }

    return true;
  }

  static bool validateCalories({required String kCals, required String thousandSeparator}) {
    //none or multiple digits (\d*) followed by none or one thousandSeparator (\thousandSeparator?) followed by none or multiple digits (\d*)
    var matches = RegExp(r"^\d*\" + thousandSeparator + r"?\d*$").allMatches(kCals);
    if (matches.length != 1) {
      return false;
    }

    List<String> parts = kCals.split(thousandSeparator);

    if (parts.length > 2) {
      return false;
    }

    if (parts.length > 1) {
      if (parts[0].length > 1) {
        return false;
      }

      if (parts.length > 1) {
        if (parts[1].length > 3) {
          return false;
        }
      }
    } else {
      if (parts[0].length > 4) {
        return false;
      }
    }

    return true;
  }
}
