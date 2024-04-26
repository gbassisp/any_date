import 'package:any_date/any_date.dart';
import 'package:any_date/src/date_range.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'any_date_test.dart';
import 'test_values.dart';

final r = DateTimeRange(
  start: DateTime(900, 1, 1, 13, 14, 15, 16),
  end: DateTime(hugeRange ? 2100 : 902, 12, 31, 15, 16, 17, 18),
);

final _range = dateRange;
void main() {
  group('default AnyDate()', () {
    const parser = AnyDate();

    test(
      'yyyy.M.d h:m:s',
      () {
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d H-m-s').format(date),
          _range,
          false,
        );
      },
    );
    test(
      'yyyy.M.d h:m:S',
      () {
        // print('yyyy.M.d h:m:SSSSSS (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d H-m-s.SSSSSS').format(date),
          _range,
          false,
        );
      },
    );
    test(
      'yyyy.M.d h:m:s a',
      () {
        // print('yyyy.M.d h:m:s a (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d h-m-s a').format(date),
          _range,
          false,
        );
      },
    );
    test(
      'yyyy.M.d h:m',
      () {
        // print('yyyy.M.d h:m (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d H-m').format(date),
          dateRange,
          false,
        );
      },
    );

    test('with timezone', () {
      // hour (local) = 14:
      const s = '2022-12-15T14:50:30.644+10:00'; // 2022-12-15 04:50:30.644 UTC
      // hour (utc) = 4:
      final d = DateTime.utc(2022, 12, 15, 4, 50, 30, 644);
      final r = parser.parse(s);

      expect(r, d);
    });

    test('UTC', () {
      String s;
      for (final date in r.days) {
        final d = date.safeCopyWith(
          hour: 10,
          minute: 11,
          second: 12,
          millisecond: 13,
        );
        s = d.toString();
        expect(s.toDateTime(), d);
        s = d.toString();
        expect(s.toDateTime(utc: true), d.toUtc());
        s = d.toIso8601String();
        expect(s.toDateTime(), d);
        s = d.toLocal().toString();
        expect(s.toDateTime(), d);
        s = d.toUtc().toString();
        expect(s.toDateTime().isUtc, true);
        expect(s.toDateTime(), d.toUtc());
      }
    });
  });
}

// extension Printer on String {
// void p() => print(this);
// }
