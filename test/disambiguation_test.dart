import 'package:any_date/any_date.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'any_date_test.dart';
import 'test_values.dart';

void main() {
  const simple = '01/02/03';
  group('simple disambiguation', () {
    test('ymd', () {
      final d = DateTime(2001, 2, 3);
      const info = DateParserInfo(yearFirst: true);
      const a = AnyDate(info: info);
      expect(a.parse(simple), equals(d));
    });

    test('dmy', () {
      final d = DateTime(2003, 2);
      const info = DateParserInfo(dayFirst: true);
      const a = AnyDate(info: info);
      expect(a.parse(simple), equals(d));
    });

    test('mdy', () {
      final d = DateTime(2003, 1, 2);
      const a = AnyDate();
      expect(a.parse(simple), equals(d));
    });
  });

  const ymd = 'yy/mm/dd';
  group(ymd, () {
    final formats = ymdFormats;
    for (final format in formats) {
      test('$ymd disambiguation - $format', () {
        final f = DateFormat(format);
        const info = DateParserInfo(yearFirst: true);
        const a = AnyDate(info: info);
        compare(f, a, randomDates: false);
      });
    }
  });
  const dmy = 'dd/mm/yy';
  group(dmy, () {
    final formats = dmyFormats;
    for (final format in formats) {
      test('$dmy disambiguation - $format', () {
        final f = DateFormat(format);
        const info = DateParserInfo(dayFirst: true);
        const a = AnyDate(info: info);
        compare(f, a, randomDates: false);
      });
    }
  });
  const mdy = 'mm/dd/yy';
  group(mdy, () {
    final formats = mdyFormats;
    for (final format in formats) {
      test('$mdy disambiguation - $format', () {
        final f = DateFormat(format);
        const a = AnyDate();
        compare(f, a, randomDates: false);
      });
    }
  });
}
