import 'package:any_date/any_date.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/date_symbol_data_file.dart'
    show availableLocalesForDateFormatting;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';

import 'package:lean_extensions/dart_essentials.dart';

import 'package:test/test.dart';

import 'rfc_test.dart';

final _locales = availableLocalesForDateFormatting.map((e) => e).toList()
  ..removeWhere((element) {
    final unsupported = ['ar', 'as', 'bn', 'fa', 'mr', 'my', 'ne', 'ps'];
    for (final l in unsupported) {
      if (element.startsWith(l)) {
        return true;
      }
    }
    return false;
  });
final _localeCodes = _locales.map(Locale.tryParse).safeWhereNotNull().toList();

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

// TODO(gbassisp): promote this to lib/ once we enable support for locale
extension _LocaleExtensions on Locale {
  AnyDate get anyDate => AnyDate(
        info: DateParserInfo(
          dayFirst: !usesMonthFirst,
          yearFirst: usesYearFirst,
          months: [...longMonths, ...shortMonths],
          weekdays: [...longWeekdays, ...shortWeekdays],
        ),
      );

  static final _date = DateTime(1234, 5, 6, 7, 8, 9);

  String get _yMd => DateFormat.yMd(toString()).format(_date);

  // DateParserInfo get parserInfo => DateParserInfo(
  //       yearFirst: usesYearFirst,
  //       dayFirst: !usesMonthFirst,
  //       months: [...longMonths, ...shortMonths],
  //       weekdays: [...longWeekdays, ...shortWeekdays],
  //     );

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
}

Future<void> main() async {
  await initializeDateFormatting();

  group('locale extensions', () {
    test('extensions converges', () {
      var count = 0;
      for (final locale in _locales) {
        final l = Locale.tryParse(locale);
        // ignore unimplemented locale
        if (l == null || !l.usesNumericSymbols) {
          continue;
        }

        final month = l.usesMonthFirst;
        final year = l.usesMonthFirst;

        // just expect is doesn't throw
        expect(month, isNot(isNull));
        expect(year, isNot(isNull));
        count++;
      }

      expect(count, greaterThan(0));
    });

    group('all locales support rfc formats', () {
      for (final l in _localeCodes) {
        final parser = l.anyDate;
        rfcTests(parser);
      }
    });
  });

  group('locale tests', () {
    final englishMonths = AnyDate.defaultSettings.months;
    final englishWeekdays = AnyDate.defaultSettings.weekdays;
    final longWeekdays = englishWeekdays.sublist(0, 7);
    final shortWeekdays = englishWeekdays.sublist(7)
      ..removeWhere((element) => element.name == 'Sept');
    test('english speaking - american format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'US');
      final longMonths = englishMonths.sublist(0, 12);
      final shortMonths = englishMonths.sublist(12)
        ..removeWhere((element) => element.name == 'Sept');

      expect(locale.usesMonthFirst, isTrue);
      expect(locale.usesYearFirst, isFalse);
      expect(longMonths, containsAll(locale.longMonths));
      expect(shortMonths, containsAll(locale.shortMonths));
      expect(longWeekdays, containsAll(locale.longWeekdays));
      expect(shortWeekdays, containsAll(locale.shortWeekdays));
    });

    test('english speaking - normal format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'AU');
      final longMonths = englishMonths.sublist(0, 12);
      final shortMonths = englishMonths.sublist(12)
        ..removeWhere((element) => element.name == 'Sep');

      expect(locale.usesMonthFirst, isFalse);
      expect(locale.usesYearFirst, isFalse);
      expect(longMonths, containsAll(locale.longMonths));
      expect(shortMonths, containsAll(locale.shortMonths));
      expect(longWeekdays, containsAll(locale.longWeekdays));
      expect(shortWeekdays, containsAll(locale.shortWeekdays));
    });
  });
}
