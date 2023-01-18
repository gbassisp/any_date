import 'package:any_date/any_date.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'any_date_test.dart';

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
                DateFormat('yyyy${sep1}MMMM${sep2}d H-m-s').format(date));
      },
    );
    test(
      'yyyy.M.d h:m',
      () {
        print('yyyy.M.d h:m (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('yyyy${sep1}MMMM${sep2}d H-m').format(date));
      },
    );
  });
}

extension Printer on String {
  void p() => print(this);
}
