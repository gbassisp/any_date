import 'package:any_date/any_date.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'any_date_test.dart';
import 'test_values.dart';

void main() {
  const ymd = 'yy/mm/dd';
  group(ymd, () {
    final formats = ymdFormats;
    for (final format in formats) {
      test('$ymd disambiguation - $format', () {
        final f = DateFormat(format);
        const info = DateParserInfo(yearFirst: true);
        const a = AnyDate(info: info);
        compare(f, a);
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
        compare(f, a);
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
        compare(f, a);
      });
    }
  });
}
