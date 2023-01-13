import 'package:any_date/any_date.dart';
import 'package:any_date/src/date_range.dart';
import 'package:test/test.dart';

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);
final range = DateTimeRange(start: DateTime(1999), end: DateTime(2005));
final singleDate = DateTime(2023, 1, 2, 3, 4, 5, 6, 7);

void testRange(
  AnyDate parser,
  String Function(DateTime date, String sep1, String sep2) formatter,
) {
  Set cache = <String>{};
  final separators = parser.allowedSeparators;
  int count = 0;
  for (var date in range.days) {
    for (var a in separators) {
      for (var b in separators) {
        String f = formatter(date, a, b);
        if (!cache.contains(f)) {
          expect(parser.parse(f), date);
          count++;
          cache.add(f);
        }
      }
    }
  }
  print('tested $count cases');
}

void main() {
  group('basic AnyDate().parse tests', () {
    test('matches DateTime.parse', () {
      final d = '$singleDate';

      expect(AnyDate().parse(d), DateTime.parse(d));
    });
    test('format exception', () {
      final d = 'not a date';

      expect(() => AnyDate().parse(d), throwsA(isA<FormatException>()));
    });
  });

  group(
    'exhaustive default AnyDate()',
    () {
      final parser = AnyDate();
      test('matches DateTime.parse', () {
        print('iso format:');
        testRange(parser, (date, sep1, sep2) => '$date');
      });
      test('yyyy M d with / separator', () {
        print('yyyy/M/d format:');
        testRange(parser,
            (date, sep1, sep2) => '${date.year}/${date.month}/${date.day}');
      });
      test('yyyy M d with multiple separators', () {
        print('yyyy.M.d (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                '${date.year}$sep1${date.month}$sep2${date.day}');
      });
    },
    skip: !exhaustiveTests,
  );
  group(
    'exhaustive dayFirst tests',
    () {
      final parser = AnyDate(info: DateParserInfo(dayFirst: true));
      test('yyyy d M with / separator', () {
        print('yyyy.M.d (any separator) format:');
        testRange(parser,
            (date, sep1, sep2) => '${date.year}/${date.day}/${date.month}');
      });
      test('yyyy d M with multiple separators', () {
        print('yyyy.d.M (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                '${date.year}$sep1${date.day}$sep2${date.month}');
      });
    },
    skip: !exhaustiveTests,
  );
}
