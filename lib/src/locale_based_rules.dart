import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:meta/meta.dart';

final _rulesCache = <String, AnyDate>{};

@internal
extension LocaleExtensions on Locale {
  AnyDate get anyDate {
    _rulesCache.putIfAbsent(_t, () => _anyDate);

    return _rulesCache[_t] ?? _anyDate;
  }

  String get _t => toLanguageTag();

  AnyDate get _anyDate {
    try {
      return AnyDate(
        info: DateParserInfo(
          dayFirst: !usesMonthFirst,
          yearFirst: usesYearFirst,
          months: [...longMonths, ...shortMonths],
          weekdays: [...longWeekdays, ...shortWeekdays],
          customRules: _parsingRules,
        ),
      );
    } catch (_) {
      return AnyDate(
        info: DateParserInfo(
          // error is likely to be on attempting to guess months and weekdays
          // default to using english ones, but add custom rules
          customRules: _parsingRules,
        ),
      );
    }
  }

  static final _date = DateTime(1234, 5, 6, 7, 8, 9);

  String get _yMd => DateFormat.yMd(_t).format(_date);

  bool get usesNumericSymbols {
    try {
      usesMonthFirst;
      usesYearFirst;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool get usesMonthFirst {
    final formatted = _yMd;
    final fields = formatted.split(RegExp(r'\D'))
      ..removeWhere((element) => element.trim().tryToInt() == null);
    final numbers = fields.map((e) => e.toInt());

    assert(
      numbers.contains(5),
      'could not find test date in $this: $formatted',
    );

    final monthIndex = numbers.indexOf(5);
    final dayIndex = numbers.indexOf(6);

    assert(
      monthIndex != null && dayIndex != null,
      'month and day must both be present in $this: $formatted',
    );
    return monthIndex! < dayIndex!;
  }

  bool get usesYearFirst {
    final formatted = _yMd;
    final fields = formatted.split(RegExp(r'\D'))
      ..removeWhere((element) => element.trim().tryToInt() == null);
    final numbers = fields.map((e) => e.toInt());

    assert(
      numbers.contains(1234),
      'could not find test date in $this: $formatted',
    );

    final yearIndex = numbers.indexOf(1234);
    final monthIndex = numbers.indexOf(5);

    assert(
      yearIndex != null && monthIndex != null,
      'month and year must both be present in $this: $formatted',
    );
    return yearIndex! < monthIndex!;
  }

  Iterable<Month> get longMonths sync* {
    final format = DateFormat('MMMM', toString());
    for (final i in range(12)) {
      final m = i + 1;
      final d = DateTime(1234, m, 10);
      yield Month(number: m, name: format.format(d));
    }
  }

  Iterable<Month> get shortMonths sync* {
    final format = DateFormat('MMM', toString());
    for (final i in range(12)) {
      final m = i + 1;
      final d = DateTime(1234, m, 10);
      yield Month(number: m, name: format.format(d));
    }
  }

  Iterable<Weekday> get longWeekdays sync* {
    final format = DateFormat('EEEE', toString());
    for (final i in range(7)) {
      final w = i + 1;
      final d = DateTime(2023, 10, 8 + w);
      yield Weekday(number: w, name: format.format(d));
    }
  }

  Iterable<Weekday> get shortWeekdays sync* {
    final format = DateFormat('EEE', toString());
    for (final i in range(7)) {
      final w = i + 1;
      final d = DateTime(2023, 10, 8 + w);
      yield Weekday(number: w, name: format.format(d));
    }
  }

  Iterable<DateFormat> get _dateOnly sync* {
    yield DateFormat.yMMMMEEEEd(_t);
    yield DateFormat.yMMMMd(_t);
    yield DateFormat.yMMMd(_t);
    yield DateFormat.yMMMEd(_t);
    yield DateFormat.yMEd(_t);
    yield DateFormat.yMd(_t);
  }

  Iterable<DateFormat> get _dateTime sync* {
    for (final f in _dateOnly) {
      yield f.add_Hms();
      yield f.add_Hm();
      yield f.add_H();
      yield f.add_jms();
      yield f.add_jm();
      yield f.add_j();
    }
  }

  Iterable<DateParsingFunction> get _parsingRules sync* {
    for (final f in _dateTime) {
      yield f.parseLoose;
    }
    for (final f in _dateOnly) {
      yield f.parseLoose;
    }
  }
}

extension _ListExtension<T> on Iterable<T> {
  int? indexOf(T element) {
    for (final i in range(length)) {
      if (elementAt(i) == element) {
        return i;
      }
    }

    return null;
  }
}
