import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

// TODO: review this
/// AI-generated set of many different date formats
const baseDateFormat = {
  'yyyy.M.d h:m:s.SS a',
  'yyyy.M.d h:m:s.SS',
  'yyyy.M.d h:m:s.S a',
  'yyyy.M.d h:m:s.S',
  'yyyy.M.d h:m:s a',
  'yyyy.M.d h:m:s',
  'yyyy.M.d h:m a',
  'yyyy.M.d h:m',
  'yyyy.M.d h a',
  'yyyy.M.d h',
  'yyyy.M.d',
  // 'yyyy.M',
  // 'yyyy',
  'y.M.d h:m:s.SS a',
  'y.M.d h:m:s.SS',
  'y.M.d h:m:s.S a',
  'y.M.d h:m:s.S',
  'y.M.d h:m:s a',
  'y.M.d h:m:s',
  'y.M.d h:m a',
  'y.M.d h:m',
  'y.M.d h a',
  'y.M.d h',
  'y.M.d',
  // 'y.M',
  // 'y',
  'M.d.y h:m:s.SS a',
  'M.d.y h:m:s.SS',
  'M.d.y h:m:s.S a',
  'M.d.y h:m:s.S',
  'M.d.y h:m:s a',
  'M.d.y h:m:s',
  'M.d.y h:m a',
  'M.d.y h:m',
  'M.d.y h a',
  'M.d.y h',
  'M.d.y',
  // 'M.d',
  // 'M',
  'd.M.y h:m:s.SS a',
  'd.M.y h:m:s.SS',
  'd.M.y h:m:s.S a',
  'd.M.y h:m:s.S',
  'd.M.y h:m:s a',
  'd.M.y h:m:s',
  'd.M.y h:m a',
  'd.M.y h:m',
  'd.M.y h a',
  'd.M.y h',
  'd.M.y',
  // 'd.M',
  // 'd',
  'h:m:s.SS a',
  'h:m:s.SS',
  'h:m:s.S a',
  'h:m:s.S',
  'h:m:s a',
  'h:m:s',
  'h:m a',
  'h:m',
  'h a',
  'h',
  'a',
  'EEEE, MMMM d, y',
  'EEEE, MMMM d, y h:m:s.SS a',
  'EEEE, MMMM d, y h:m:s.SS',
  'EEEE, MMMM d, y h:m:s.S a',
  'EEEE, MMMM d, y h:m:s.S',
  'EEEE, MMMM d, y h:m:s a',
  'EEEE, MMMM d, y h:m:s',
  'EEEE, MMMM d, y h:m a',
  'EEEE, MMMM d, y h:m',
  'EEEE, MMMM d, y h a',
  'EEEE, MMMM d, y h',
  // 'EEEE, MMMM d',
  // 'EEEE, MMMM',
  'EEEE, M/d/y',
  'EEEE, M/d/y h:m:s.SS a',
  'EEEE, M/d/y h:m:s.SS',
  'EEEE, M/d/y h:m:s.S a',
  'EEEE, M/d/y h:m:s.S',
  'EEEE, M/d/y h:m:s a',
  'EEEE, M/d/y h:m:s',
  'EEEE, M/d/y h:m a',
  'EEEE, M/d/y h:m',
  'EEEE, M/d/y h a',
  'EEEE, M/d/y h',
  // 'EEEE, M/d',
  // 'EEEE, M',
  'EEEE, d.M.y',
  'EEEE, d.M.y h:m:s.SS a',
  'EEEE, d.M.y h:m:s.SS',
  'EEEE, d.M.y h:m:s.S a',
  'EEEE, d.M.y h:m:s.S',
  'EEEE, d.M.y h:m:s a',
  'EEEE, d.M.y h:m:s',
  'EEEE, d.M.y h:m a',
  'EEEE, d.M.y h:m',
  'EEEE, d.M.y h a',
  'EEEE, d.M.y h',
  // 'EEEE, d.M',
  // 'EEEE, d',
  'EEEE, y.M.d',
  'EEEE, y.M.d h:m:s.SS a',
  'EEEE, y.M.d h:m:s.SS',
  'yyyy-MM-ddTHH:mm:ss',
  'dd/MM/yyyy HH:mm:ss',
  'MM/dd/yyyy HH:mm:ss',
  'yyyy.MM.dd HH:mm:ss',
  'dd-MM-yyyy HH:mm:ss',
  'yyyy MM dd HH:mm:ss',
  'dd.MM.yyyy HH:mm:ss',
  'yyyy-MM-ddTHH:mm',
  'dd/MM/yyyy HH:mm',
  'MM/dd/yyyy HH:mm',
  'yyyy.MM.dd HH:mm',
  'dd-MM-yyyy HH:mm',
  'yyyy MM dd HH:mm',
  'dd.MM.yyyy HH:mm',
  'yyyy-MM-ddTHH:mm:ss.SSS',
  'dd/MM/yyyy HH:mm:ss.SSS',
  'MM/dd/yyyy HH:mm:ss.SSS',
  'yyyy.MM.dd HH:mm:ss.SSS',
  'dd-MM-yyyy HH:mm:ss.SSS',
  'yyyy MM dd HH:mm:ss.SSS',
  'dd.MM.yyyy HH:mm:ss.SSS',
  'yyyy-MM-ddTHH:mm:ssZ',
  'dd/MM/yyyy HH:mm:ss Z',
  'MM/dd/yyyy HH:mm:ss Z',
  'yyyy.MM.dd HH:mm:ss Z',
  'dd-MM-yyyy HH:mm:ss Z',
  'yyyy MM dd HH:mm:ss Z',
  'dd.MM.yyyy HH:mm:ss Z',
  'E, dd MMM yyyy HH:mm:ss',
  'dd MMM yyyy HH:mm:ss E',
  'E, dd MMM yyyy HH:mm:ss Z',
  'dd MMM yyyy HH:mm:ss Z E',
  'EEE, dd MMM yyyy HH:mm:ss',
  'dd MMM yyyy HH:mm:ss EEE',
  'EEE, dd MMM yyyy HH:mm:ss Z',
  'dd MMM yyyy HH:mm:ss Z EEE',
  'dd MMM yyyy HH:mm:ss',
  'dd MMM yyyy HH:mm:ss Z',
  'dd MMM yyyy HH:mm:ss.SSS',
  'dd MMM yyyy HH:mm',
  'dd MMM yyyy HH:mm Z',
};

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);
const hugeRange = bool.fromEnvironment('huge');

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
    // 1, // h
  ),
  end: DateTime(
    hugeRange ? 2005 : 2000, // y
    // 1, // h
  ),
);
final singleDate = DateTime(2023, 1, 2, 3, 4, 5, 6, 7);

void testRange(
  AnyDate parser,
  String Function(DateTime date, String sep1, String sep2) formatter, [
  DateTimeRange? customRange,
  bool dayOnly = true,
]) {
  final cache = <String>{};
  final separators = parser.info.allowedSeparators;
  var count = 0;
  for (final date in (customRange ?? range).days) {
    for (final a in separators) {
      for (final b in separators) {
        final f = formatter(date, a, b);
        if (!cache.contains(f)) {
          final g = parser.parse(f);
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
      const d = 'not a date';

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
          parser,
          (date, sep1, sep2) => DateFormat('yyyy/M/d').format(date),
        );
      });
      test('yyyy M d with multiple separators', () {
        print('yyyy.M.d (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) => DateFormat('yyyy${sep1}M${sep2}d').format(date),
        );
      });
      test('yyyy MMM d with multiple separators', () {
        print('yyyy.MMM.d (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMM${sep2}d').format(date),
        );
      });
      test('yyyy MMMM d with multiple separators', () {
        print('yyyy.MMMM.d (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d').format(date),
        );
      });
      test('yyyy d MMM with multiple separators', () {
        print('yyyy.d.MMM (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}d${sep2}MMM').format(date),
        );
      });
      test('yyyy d MMMM with multiple separators', () {
        print('yyyy.d.MMMM (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}d${sep2}MMMM').format(date),
        );
      });
      test('d MMM yyyy with multiple separators', () {
        print('d.MMM.yyyy (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('d${sep1}MMM${sep2}yyyy').format(date),
        );
      });
      test('d MMMM yyyy with multiple separators', () {
        print('d.MMMM.yyyy (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('d${sep1}MMMM${sep2}yyyy').format(date),
        );
      });
      test('MMM d yyyy with multiple separators', () {
        print('MMM.d.yyyy (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('MMM${sep1}d${sep2}yyyy').format(date),
        );
      });
      test('MMMM d yyyy with multiple separators', () {
        print('MMMM.d.yyyy (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('MMMM${sep1}d${sep2}yyyy').format(date),
        );
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
          parser,
          (date, sep1, sep2) => DateFormat('yyyy/d/M').format(date),
        );
      });
      test('yyyy d M with multiple separators', () {
        print('yyyy.d.M (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) => DateFormat('yyyy${sep1}d${sep2}M').format(date),
        );
      });
    },
    skip: !exhaustiveTests,
  );
}
