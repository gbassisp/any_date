import 'package:any_date/any_date.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);
const hugeRange = bool.fromEnvironment('huge', defaultValue: false);

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
    hugeRange ? 2005 : 2000, // y
    1, // m
    1, // d
    // 1, // h
  ),
);
final singleDate = DateTime(2023, 1, 2, 3, 4, 5, 6, 7);

void testRange(AnyDate parser,
    String Function(DateTime date, String sep1, String sep2) formatter,
    [DateTimeRange? _range, bool dayOnly = true]) {
  Set cache = <String>{};
  final separators = parser.info.allowedSeparators;
  int count = 0;
  for (var date in (_range ?? range).days) {
    for (var a in separators) {
      for (var b in separators) {
        String f = formatter(date, a, b);
        if (!cache.contains(f)) {
          DateTime g = parser.parse(f);
          // print(f);
          // print(g.toString());
          if (dayOnly) {
            expect(g.year, date.year);
            expect(g.month, date.month);
            expect(g.day, date.day);
          }
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
      test('yyyy MMMM d with multiple separators', () {
        print('yyyy.MMMM.d (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('yyyy${sep1}MMMM${sep2}d').format(date));
      });
      test('yyyy d MMM with multiple separators', () {
        print('yyyy.d.MMM (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('yyyy${sep1}d${sep2}MMM').format(date));
      });
      test('yyyy d MMMM with multiple separators', () {
        print('yyyy.d.MMMM (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('yyyy${sep1}d${sep2}MMMM').format(date));
      });
      test('d MMM yyyy with multiple separators', () {
        print('d.MMM.yyyy (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('d${sep1}MMM${sep2}yyyy').format(date));
      });
      test('d MMMM yyyy with multiple separators', () {
        print('d.MMMM.yyyy (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('d${sep1}MMMM${sep2}yyyy').format(date));
      });
      test('MMM d yyyy with multiple separators', () {
        print('MMM.d.yyyy (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('MMM${sep1}d${sep2}yyyy').format(date));
      });
      test('MMMM d yyyy with multiple separators', () {
        print('MMMM.d.yyyy (any separator) format:');
        testRange(
            parser,
            (date, sep1, sep2) =>
                DateFormat('MMMM${sep1}d${sep2}yyyy').format(date));
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
