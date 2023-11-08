import 'package:any_date/any_date.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/date_symbol_data_file.dart'
    show availableLocalesForDateFormatting;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:test/test.dart';

import 'test_values.dart' as values;

final _locales = availableLocalesForDateFormatting;

Iterable<DateFormat> formats(String locale) sync* {
  // yield DateFormat.y(locale);
  // yield DateFormat.yM(locale);
  // yield DateFormat.yMMMM(locale);
  // yield DateFormat.yMMM(locale);
  // yield DateFormat.yMEd(locale);
  // yield DateFormat.yMMMEd(locale);
  // yield DateFormat.yMMMMEEEEd(locale);
  // yield DateFormat.yMMMMd(locale);
  // yield DateFormat.yMMMd(locale);

  yield DateFormat.yMd(locale);
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
      expect(locale.longMonths, containsAllInOrder(longMonths));
      expect(locale.shortMonths, containsAllInOrder(shortMonths));
      expect(locale.longWeekdays, containsAllInOrder(longWeekdays));
      expect(locale.shortWeekdays, containsAllInOrder(shortWeekdays));
    });

    test('english speaking - normal format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'AU');
      final longMonths = englishMonths.sublist(0, 12);
      final shortMorhts = englishMonths.sublist(12)
        ..removeWhere((element) => element.name == 'Sep');

      expect(locale.usesMonthFirst, isFalse);
      expect(locale.usesYearFirst, isFalse);
      expect(locale.longMonths, containsAllInOrder(longMonths));
      expect(locale.shortMonths, containsAllInOrder(shortMorhts));
      expect(locale.longWeekdays, containsAllInOrder(longWeekdays));
      expect(locale.shortWeekdays, containsAllInOrder(shortWeekdays));
    });

    for (final l in _locales) {
      final locale = Locale.tryParse(l);
      if (locale == null || !locale.usesNumericSymbols) {
        continue;
      }

      for (final f in formats(l)) {
        test('$l - $f', () {
          for (final d in values.range.days) {
            final anyDate = AnyDate(info: locale.parserInfo);
            final formatted = f.format(d);

            final parsed = anyDate.tryParse(formatted);
            final expected = f.parse(formatted);

            expect(
              parsed,
              expected,
              reason: 'expected $expected from $formatted, '
                  'but got $parsed on $l with ${f.pattern}',
            );
          }
        });
      }
    }

    test('non-latin character month is identified', () {
      final l = Locale.parse('am');
      final info = l.parserInfo;
      final longMonths = info.months;

      bool containsMonth() {
        for (final m in longMonths) {
          if (m.name == 'ጁላይ') {
            return true;
          }
        }
        return false;
      }

      expect(
        containsMonth(),
        isTrue,
        reason: 'expected "am" locale to include "ጁላይ" on month list',
      );
    });
  });
}
