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
  bool get usesMonthFirst {
    final formatted = DateFormat.yMd(toString()).format(_date);
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
    final formatted = DateFormat.yMd(toString()).format(_date);
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
}

Future<void> main() async {
  for (final locale in _locales) {
    await initializeDateFormatting(locale);
  }

  group('locale extensions', () {
    test('Locale.usesMonthFirst converges', () {
      for (final locale in _locales) {
        final l = Locale.tryParse(locale);
        // ignore unimplemented locale
        if (l == null) {
          continue;
        }
        final res = l.usesMonthFirst;

        // just expect is doesn't throw
        expect(res, isNot(isNull));
      }
    });
  });

  group('locale tests', () {
    test('english speaking - american format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'US');

      expect(locale.usesMonthFirst, isTrue);
      expect(locale.usesYearFirst, isFalse);
    });

    test('english speaking - normal format', () {
      final locale = Locale.fromSubtags(languageCode: 'en', countryCode: 'AU');

      expect(locale.usesMonthFirst, isFalse);
      expect(locale.usesYearFirst, isFalse);
    });
  });
}
