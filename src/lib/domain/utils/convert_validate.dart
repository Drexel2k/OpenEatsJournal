import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';
import 'package:openeatsjournal/domain/utils/week_of_year.dart';

class ConvertValidate {
  static void init({required String languageCode}) {
    numberFomatterInt = NumberFormat(null, languageCode);
    numberFomatterDouble = NumberFormat.decimalPatternDigits(locale: languageCode, decimalDigits: 1);
    _decimalSeparator = NumberFormat.decimalPattern(languageCode).symbols.DECIMAL_SEP;

    initializeDateFormatting(languageCode);
    dateFormatterDisplayLongDateOnly = DateFormat.yMMMMd(languageCode);
  }

  static late NumberFormat numberFomatterInt;
  static late NumberFormat numberFomatterDouble;
  static final DateFormat dateformatterDatabaseDateOnly = DateFormat(OpenEatsJournalStrings.dbDateFormatDateOnly);
  static final DateFormat dateFormatterDatabaseDateAndTime = DateFormat(OpenEatsJournalStrings.dbDateFormatDateAndTime);
  static late DateFormat dateFormatterDisplayLongDateOnly;
  static late String _decimalSeparator;

  // static double? convertLocalStringToDouble({required String numberString, required String languageCode}) {
  //   num? number = NumberFormat(null, languageCode).tryParse(numberString);
  //   return number == null ? null : number as double;
  // }

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
}
