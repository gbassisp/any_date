import 'package:any_date/any_date.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/date_symbol_data_file.dart'
    show availableLocalesForDateFormatting;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:lean_extensions/dart_essentials.dart';
import 'package:test/test.dart';

final _locales = availableLocalesForDateFormatting;

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
  static final _date = DateTime(1234, 5, 6, 7, 8, 9);

  String get _yMd => DateFormat.yMd(toString()).format(_date);

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

  Iterable<String> get longMonths sync* {
    final format = DateFormat('MMMM', toString());
    for (final i in range(12)) {
      final d = DateTime(1234, i + 1, 10);
      yield format.format(d);
    }
  }

  Iterable<String> get shortMonths sync* {
    final format = DateFormat('MMM', toString());
    for (final i in range(12)) {
      final d = DateTime(1234, i + 1, 10);
      yield format.format(d);
    }
  }
}

Future<void> main() async {
  for (final locale in _locales) {
    await initializeDateFormatting(locale);
  }

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
  });

  group('locale tests', () {
    final englishMonths = AnyDate.defaultSettings.months;
    test('english speaking - american format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'US');
      final longMonths = englishMonths.sublist(0, 12).map((e) => e.name);
      final shortMorhts = englishMonths.sublist(12).map((e) => e.name).toList()
        ..removeWhere((element) => element == 'Sept');

      expect(locale.usesMonthFirst, isTrue);
      expect(locale.usesYearFirst, isFalse);
      expect(locale.longMonths, containsAllInOrder(longMonths));
      expect(locale.shortMonths, containsAllInOrder(shortMorhts));
    });

    test('english speaking - normal format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'AU');
      final longMonths = englishMonths.sublist(0, 12).map((e) => e.name);
      final shortMorhts = englishMonths.sublist(12).map((e) => e.name).toList()
        ..removeWhere((element) => element == 'Sep');

      expect(locale.usesMonthFirst, isFalse);
      expect(locale.usesYearFirst, isFalse);
      expect(locale.longMonths, containsAllInOrder(longMonths));
      expect(locale.shortMonths, containsAllInOrder(shortMorhts));
    });
  });
}
