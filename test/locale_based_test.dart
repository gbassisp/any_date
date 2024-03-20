import 'package:any_date/any_date.dart';
import 'package:any_date/src/locale_based_rules.dart';
import 'package:intl/date_symbol_data_file.dart'
    show availableLocalesForDateFormatting;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:lean_extensions/collection_extensions.dart';
import 'package:test/test.dart';

import 'rfc_test.dart';
// import 'test_values.dart' hide range;

Iterable<DateFormat> _formatFactory(String locale) sync* {
  yield DateFormat.yMMMMd(locale);
}

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
final _localeCodes = _locales.map(Locale.tryParse).whereNotNull().toList();

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
  });

  group('all locales can parse text month formats', () {
    final date = DateTime.now();
    for (final l in _localeCodes) {
      final parser = AnyDate.fromLocale(l);
      for (final format in _formatFactory(l.toLanguageTag())) {
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
  });
}
