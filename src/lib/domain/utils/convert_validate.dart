import 'package:intl/intl.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/domain/utils/week_of_year.dart';

class ConvertValidate {
  static void init({required String languageCode}) {
    numberFomatterInt = NumberFormat(null, languageCode);
    numberFomatterDouble = NumberFormat.decimalPatternDigits(locale: languageCode, decimalDigits: 1);
  }

  static late NumberFormat numberFomatterInt;
  static late NumberFormat numberFomatterDouble;
  static DateFormat dateformatterDateOnly = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
  static DateFormat dateFormatterDateAndTime = DateFormat(OpenEatsJournalStrings.dbDateFormatDateAndTime);

  // static double? convertLocalStringToDouble({required String numberString, required String languageCode}) {
  //   num? number = NumberFormat(null, languageCode).tryParse(numberString);
  //   return number == null ? null : number as double;
  // }

  static int? convertLocalStringToInt({required String numberString, required String languageCode}) {
    num? number = NumberFormat(null, languageCode).tryParse(numberString);
    return number?.toInt();
  }

  static bool validateInt({required String intString, required String thousandSeparator}) {
    //none or multiple digits (\d*) followed by none or one thousandSeparator (\thousandSeparator?) followed by none or multiple digits (\d*)
    var matches = RegExp(r"^\d{1,3}(" + thousandSeparator + r"\d{3})*$").allMatches(intString);
    if (matches.length != 1) {
      return false;
    }

    return true;
  }

  //max 2 decimal digits
  static bool validateDecimal({required String decimalString, required String thousandSeparator, required String decimalSeparator}) {
    //none or multiple digits (\d*) followed by none or one thousandSeparator (\thousandSeparator?) followed by none or multiple digits (\d*)
    var matches = RegExp(r"^\d{1,3}(" + thousandSeparator + r"\d{3})*(\" + decimalSeparator + r"\d{1,2})?$").allMatches(decimalString);
    if (matches.length != 1) {
      return false;
    }

    return true;
  }

  static WeekOfYear getweekNumber(DateTime date) {
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

  static int _getWeekCount(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }
}
