class ApiV1Helpers {
  //ApiV1 returns numbers as ints, doubles oder Strings...
  static int getIntFromNumOrString(dynamic value) {
    num number;
    if (value is num) {
      number = value;
    } else {
      number = num.parse(value);
    }

    if (number is int) {
      return number;
    }

    return number.round();
  }

  //ApiV1 returns numbers as ints, doubles oder Strings...
  static double getDoubleFromNumOrString(dynamic value) {
    num number;
    if (value is num) {
      number = value;
    } else {
      number = num.parse(value);
    }

    if (number is double) {
      return number;
    }

    return number.toDouble();
  }
}
