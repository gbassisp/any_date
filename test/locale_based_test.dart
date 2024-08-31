import 'package:any_date/any_date.dart';
import 'package:any_date/src/locale_based_rules.dart';
import 'package:intl/date_symbol_data_file.dart'
    show availableLocalesForDateFormatting;

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:test/test.dart';

import 'rfc_test.dart';
import 'test_values.dart';

Iterable<DateFormat> _formatFactory(String locale) sync* {
  yield DateFormat.yMMMMd(locale);
}

final _englishLocales = _localeCodes.map((e) => e).toList()
  ..removeWhere((element) => !element.toLanguageTag().startsWith('en'));

final _locales = availableLocalesForDateFormatting.map((e) => e).toList()
  ..removeWhere((element) {
    final unsupported = ['ar', 'as', 'bn', 'fa', 'mr', 'my', 'ne', 'ps']
      // maybe unsupported?
      // ignore: prefer_inlined_adds
      ..addAll(['am', 'be', 'bg', 'ca'])
      ..clear();
    for (final l in unsupported) {
      if (element.startsWith(l)) {
        return true;
      }
    }
    return false;
  });
final _localeCodes = _locales.map(Locale.tryParse).whereIsNotNull().toList();

/// taken from collection package to avoid deprecation warning and conflict
/// with dart sdk
extension _IterableNullableExtension<T extends Object> on Iterable<T?> {
  Iterable<T> whereIsNotNull() sync* {
    for (final element in this) {
      if (element != null) yield element;
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
  });
  group('all locales support rfc formats', () {
    for (final l in _localeCodes) {
      final parser = l.anyDate;
      rfcTests(parser);
    }

    // invalid locale
    rfcTests(AnyDate.fromLocale(null));
  });

  group('all locales can parse text month formats', () {
    final date = DateTime.now();
    for (final l in [..._locales, ..._localeCodes]) {
      final parser = AnyDate.fromLocale(l);
      for (final format
          in _formatFactory(l is Locale ? l.toLanguageTag() : l.toString())) {
        final formatted = format.format(date);
        final reason = '$formatted on $l with format ${format.pattern}';
        test(reason, () {
          final result = parser.tryParse(formatted);
          final expected = format.parse(formatted);
          expect(
            result,
            equals(expected),
            reason: '$reason resulted in $result, but expected $expected',
          );
        });
      }
    }
  });

  group('locale tests', () {
    final englishMonths = AnyDate.defaultSettings.months;
    final englishWeekdays = AnyDate.defaultSettings.weekdays;
    final longWeekdays = englishWeekdays.sublist(0, 7);
    final shortWeekdays = englishWeekdays.sublist(7);
    test('english speaking - american format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'US');
      final longMonths = englishMonths.sublist(0, 12);
      final shortMonths = englishMonths.sublist(12);

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
      final shortMonths = englishMonths.sublist(12);

      expect(locale.usesMonthFirst, isFalse);
      expect(locale.usesYearFirst, isFalse);
      expect(longMonths, containsAll(locale.longMonths));
      expect(shortMonths, containsAll(locale.shortMonths));
      expect(longWeekdays, containsAll(locale.longWeekdays));
      expect(shortWeekdays, containsAll(locale.shortWeekdays));
    });
  });

  group('locale specific cases', () {
    // this is to ensure 日 is not mis-interpreted between day of the week and
    // day of the month
    test(
        '2024年8月31日 on ja with format y年M月d日 resulted in null, '
        'but expected 2024-08-31 00:00:00.000', () {
      const locale = 'ja';
      const formatted = '2024年8月31日';
      const format = 'y年M月d日';
      final formatter = DateFormat(format);
      final expected = DateTime.parse('2024-08-31 00:00:00.000');
      final parser = AnyDate.fromLocale(locale);

      expect(
        formatter.parseLoose(formatted),
        equals(expected),
        reason: 'sanity check that DateFormat $format can parse $formatted',
      );
      expect(parser.tryParse(formatted), equals(expected));
    });

    const unambiguousEnglish = {
      'March 27, 2024',
      'March 27 2024',
      '27 March 2024',
      'Mar 27, 2024',
      'Mar 27 2024',
      '27 Mar 2024',
    };
    final expected = DateTime(2024, 3, 27);

    for (final l in _englishLocales) {
      test('simple english date in any english locale $l', () {
        for (final d in unambiguousEnglish) {
          final p = AnyDate.fromLocale(l);
          final res = p.tryParse(d);
          expect(
            res,
            equals(expected),
            reason: 'expected $expected for $d with locale $l',
          );
        }
      });
    }
  });
}
