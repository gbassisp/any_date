import 'package:any_date/any_date.dart';
import 'package:intl/date_symbol_data_file.dart'
    show availableLocalesForDateFormatting;
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/locale.dart';
import 'package:test/test.dart';

import 'locale_test_implementation.dart';
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
