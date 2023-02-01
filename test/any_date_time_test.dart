import 'package:any_date/any_date.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'any_date_test.dart';

final _range = DateTimeRange(
  start: DateTime(
    1999, // y
    1, // m
    1, // d
    1, // h
  ),
  end: DateTime(
    hugeRange ? 2005 : 2000, // y
    1, // m
    1, // d
    1, // h
  ),
);
void main() {
  group('default AnyDate()', () {
    final parser = AnyDate();

    test(
      'yyyy.M.d h:m:s',
      () {
        print('yyyy.M.d h:m:s (any separator) format:');
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
        print('yyyy.M.d h:m:S (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d H-m-s.S').format(date),
          _range,
          false,
        );
      },
    );
    test(
      'yyyy.M.d h:m:s a',
      () {
        print('yyyy.M.d h:m:s a (any separator) format:');
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
        print('yyyy.M.d h:m (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d H-m').format(date),
          range,
          false,
        );
      },
    );
  });
}

// extension Printer on String {
// void p() => print(this);
// }
