import 'package:any_date/any_date.dart';
import 'package:test/test.dart';

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);

void main() {
  group('basic AnyDate.parse tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('matches DateTime.parse', () {
      final d = DateTime(2023, 1, 2, 3, 4, 5, 6, 7).toString();

      expect(DateTime.parse(d), AnyDate.parse(d));
    });
  });

  group(
    'exhaustive AnyDate.parse tests',
    () {
      setUp(() {
        // Additional setup goes here.
      });

      test('matches DateTime.parse', () {
        final d = DateTime(2023, 1, 2, 3, 4, 5, 6, 7).toString();

        expect(DateTime.parse(d), AnyDate.parse(d));
      });
    },
    skip: !exhaustiveTests,
  );
}
