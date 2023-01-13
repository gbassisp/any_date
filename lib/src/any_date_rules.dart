part of 'any_date_base.dart';

/// default parsing rule from dart core
DateTime? _dateTimeTryParse(String formattedString) =>
    DateTime.tryParse(formattedString);

/// if no values were found, throws format exception
DateTime _noValidFormatFound(String formattedString) {
  print('no valid format identified for date $formattedString');
  return DateTime.parse(formattedString);
}

DateTime? _ymd(String formattedString, DateParserInfo info) {
  return _yyyymmdd(formattedString, info);
}

DateTime? _yyyymmdd(String formattedString, DateParserInfo info) {}

DateTime? _ydm(String formattedString, DateParserInfo info) {}

DateTime? _dmy(String formattedString, DateParserInfo info) {}

DateTime? _mdy(String formattedString, DateParserInfo info) {}
