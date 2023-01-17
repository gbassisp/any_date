import 'package:any_date/any_date.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);
final defaultParser = AnyDate();
final separators = [
  ' ',
  ',',
  '\n',
  ':',
  '_',
  '/',
  ...defaultParser.allowedSeparators,
];

final range = DateTimeRange(
  start: DateTime(
    1999, // y
    1, // m
    1, // d
    // 1, // h
  ),
  end: DateTime(
    2005, // y
    1, // m
    1, // d
    // 1, // h
  ),
);
final singleDate = DateTime(2023, 1, 2, 3, 4, 5, 6, 7);

void testRange(
  AnyDate parser,
  String Function(DateTime date, String sep1, String sep2) formatter,
) {
  Set cache = <String>{};
  final separators = parser.info.allowedSeparators;
  int count = 0;
  for (var date in range.days) {
    for (var a in separators) {
      for (var b in separators) {
        String f = formatter(date, a, b);
        if (!cache.contains(f)) {
          DateTime g = parser.parse(f);
          // print(f);
          // print(g.toString());
          expect(g, date);
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
        testRange(
            parser, (date, sep1, sep2) => DateFormat('yyyy/M/d').format(date));
      });
      test('yyyy M d with multiple separators', () {
        print('yyyy.M.d (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('yyyy${sep1}M${sep2}d').format(date));
      });
      test('yyyy MMM d with multiple separators', () {
        print('yyyy.MMM.d (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('yyyy${sep1}MMM${sep2}d').format(date));
      });
    },
    skip: !exhaustiveTests,
  );
  group(
    'exhaustive dayFirst tests',
    () {
      final parser = AnyDate(
        info: DateParserInfo(
          dayFirst: true,
          allowedSeparators: separators,
        ),
      );
      test('yyyy d M with / separator', () {
        print('yyyy.d.M (any separator) format:');
        testRange(
            parser, (date, sep1, sep2) => DateFormat('yyyy/d/M').format(date));
      });
      test('yyyy d M with multiple separators', () {
        print('yyyy.d.M (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('yyyy${sep1}d${sep2}M').format(date));
      });
    },
    skip: !exhaustiveTests,
  );
}
