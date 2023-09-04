import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

// TODO(gbassisp): review this disabled formats

const _anyFormat = {
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
  // TODO(gbassisp): allow madness (year guessing)
  // 'EEEE, MMMM d',
  // 'EEEE, MMMM',
};

const _monthFirstFormats = {
  'yyyy.M.d h:m:s.SS a',
  'yyyy.M.d h:m:s.SS',
  'yyyy.M.d h:m:s.S a',
  'yyyy.M.d h:m:s.S',
  'yyyy.M.d h:m:s a',
  'yyyy.M.d h:m:s',
  'yyyy.M.d h:m a',
  'yyyy.M.d h:m',
  'yyyy.M.d h a',
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
  'M.d.y',
  // 'M.d',
  // 'M',
  'yyyy-MM-ddTHH:mm:ss',
  'MM/dd/yyyy HH:mm:ss',
  'yyyy.MM.dd HH:mm:ss',
  'yyyy MM dd HH:mm:ss',
  'yyyy-MM-ddTHH:mm',
  'MM/dd/yyyy HH:mm',
  'yyyy.MM.dd HH:mm',
  'yyyy MM dd HH:mm',
  'yyyy-MM-ddTHH:mm:ss.SSS',
  'MM/dd/yyyy HH:mm:ss.SSS',
  'yyyy.MM.dd HH:mm:ss.SSS',
  'yyyy MM dd HH:mm:ss.SSS',
  'yyyy-MM-ddTHH:mm:ssZ',
  'MM/dd/yyyy HH:mm:ss Z',
  'yyyy.MM.dd HH:mm:ss Z',
  'yyyy MM dd HH:mm:ss Z',
  // 'yyyy.M.d h',
  // 'y.M.d h',
  // 'M.d.y h',
};

const _monthFirstWithWeekday = {
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
  // 'EEEE, M/d',
  // 'EEEE, M',
  // 'EEEE, M/d/y h',
  'EEEE, y.M.d',
  'EEEE, y.M.d h:m:s.SS a',
  'EEEE, y.M.d h:m:s.SS',
};

const _dayFirstFormats = {
  'd.M.y h:m:s.SS a',
  'd.M.y h:m:s.SS',
  'd.M.y h:m:s.S a',
  'd.M.y h:m:s.S',
  'd.M.y h:m:s a',
  'd.M.y h:m:s',
  'd.M.y h:m a',
  'd.M.y h:m',
  'd.M.y h a',
  'd.M.y',
  // TODO(gbassisp): re-enable this
  // 'd.M',
  // 'd',
  // 'h:m:s.SS a',
  // 'h:m:s.SS',
  // 'h:m:s.S a',
  // 'h:m:s.S',
  // 'h:m:s a',
  // 'h:m:s',
  // 'h:m a',
  // 'h:m',
  // 'h a',
  // 'd.M.y h',
  // 'h',
  // 'a',

  'dd/MM/yyyy HH:mm:ss',
  'dd-MM-yyyy HH:mm:ss',
  'dd.MM.yyyy HH:mm:ss',
  'dd/MM/yyyy HH:mm',
  'dd-MM-yyyy HH:mm',
  'dd.MM.yyyy HH:mm',
  'dd/MM/yyyy HH:mm:ss.SSS',
  'dd-MM-yyyy HH:mm:ss.SSS',
  'dd.MM.yyyy HH:mm:ss.SSS',
  'dd/MM/yyyy HH:mm:ss Z',
  'dd-MM-yyyy HH:mm:ss Z',
  'dd.MM.yyyy HH:mm:ss Z',
  'dd MMM yyyy HH:mm:ss E',
  'dd MMM yyyy HH:mm:ss Z E',
  'dd MMM yyyy HH:mm:ss EEE',
  // 'EEEE, d.M.y h',
  'dd MMM yyyy HH:mm:ss Z EEE',
  'dd MMM yyyy HH:mm:ss',
  'dd MMM yyyy HH:mm:ss Z',
  'dd MMM yyyy HH:mm:ss.SSS',
  'dd MMM yyyy HH:mm',
  'dd MMM yyyy HH:mm Z',
};

const _dayFirstWithWeekday = {
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
  'E, dd MMM yyyy HH:mm:ss',
  'E, dd MMM yyyy HH:mm:ss Z',
  'EEE, dd MMM yyyy HH:mm:ss',
  'EEE, dd MMM yyyy HH:mm:ss Z',
  // 'EEEE, d.M',
  // 'EEEE, d',
};

extension _DateFormatHacks on String {
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  bool get isInvalid => isAlpha || this.isEmpty || this == '_';
}

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);
const hugeRange = bool.fromEnvironment('huge');

const defaultParser = AnyDate();
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
  // ignore: avoid_positional_boolean_parameters
  bool dayOnly = true,
]) {
  final cache = <String>{};
  final seps = parser.info.allowedSeparators.toList()
    ..removeWhere((e) => e.isInvalid);

  // var count = 0;
  for (final date in (customRange ?? range).days) {
    for (final a in seps) {
      for (final b in seps) {
        final f = formatter(date, a, b);
        if (!cache.contains(f)) {
          final g = parser.parse(f);
          // print(f);
          // print(g.toString());
          final reason = 'date: $date, f: $f, g: $g';
          if (dayOnly) {
            expect(g.year, date.year, reason: reason);
            expect(g.month, date.month, reason: reason);
            expect(g.day, date.day, reason: reason);
          }
          expect(g, date, reason: reason);
          // count++;
          cache.add(f);
        }
      }
    }
  }
  // print('tested $count cases');
}

extension _TryParse on DateFormat {
  DateTime? tryParse(String input) {
    try {
      return parse(input);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  group('basic AnyDate().parse tests', () {
    void compare(DateFormat format, AnyDate anyDate) {
      for (final singleDate in range.days) {
        final f = format;
        final d = f.format(singleDate);
        final a = anyDate;
        final reason = 'format: ${format.pattern}, date: $d';
        final e = f.tryParse(d);
        expect(e, isNotNull, reason: 'DateFormat failed: $reason');
        final r = a.tryParse(d);
        expect(r, isNotNull, reason: 'AnyDate failed: $reason');
        expect(
          r,
          e,
          reason: 'format: ${format.pattern},\n'
              'date: $d,\n'
              'result: $r,\n'
              'expect: $e',
        );
      }
    }

    test('many formats', () {
      for (final format in _monthFirstFormats) {
        final f = DateFormat(format);
        const a = AnyDate();
        compare(f, a);
      }

      for (final format in _dayFirstFormats) {
        final f = DateFormat(format);
        const a = AnyDate(info: DateParserInfo(dayFirst: true));
        compare(f, a);
      }
      for (final format in _dayFirstWithWeekday) {
        final f = DateFormat(format);
        const a = AnyDate(info: DateParserInfo(dayFirst: true));
        compare(f, a);
      }
      for (final format in _monthFirstWithWeekday) {
        final f = DateFormat(format);
        const a = AnyDate();
        compare(f, a);
      }
      for (final format in _anyFormat) {
        final f = DateFormat(format);
        const a = AnyDate();
        compare(f, a);
      }
    });

    test(
      'matches DateTime.parse',
      () {
        final d = '$singleDate';

        expect(const AnyDate().parse(d), DateTime.parse(d));
      },
    );
    test('format exception', () {
      const d = 'not a date';

      expect(() => const AnyDate().parse(d), throwsA(isA<FormatException>()));
    });
  });

  group(
    'exhaustive default AnyDate()',
    () {
      const parser = AnyDate();
      test('matches DateTime.parse', () {
        // print('iso format:');
        testRange(parser, (date, sep1, sep2) => '$date');
      });
      test('yyyy M d with / separator', () {
        // print('yyyy/M/d format:');
        testRange(
          parser,
          (date, sep1, sep2) => DateFormat('yyyy/M/d').format(date),
        );
      });
      test('yyyy M d with multiple separators', () {
        // print('yyyy.M.d (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) => DateFormat('yyyy${sep1}M${sep2}d').format(date),
        );
      });
      test('yyyy MMM d with multiple separators', () {
        // print('yyyy.MMM.d (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMM${sep2}d').format(date),
        );
      });
      test('yyyy MMMM d with multiple separators', () {
        // print('yyyy.MMMM.d (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}MMMM${sep2}d').format(date),
        );
      });
      test('yyyy d MMM with multiple separators', () {
        // print('yyyy.d.MMM (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}d${sep2}MMM').format(date),
        );
      });
      test('yyyy d MMMM with multiple separators', () {
        // print('yyyy.d.MMMM (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('yyyy${sep1}d${sep2}MMMM').format(date),
        );
      });
      test('d MMM yyyy with multiple separators', () {
        // print('d.MMM.yyyy (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('d${sep1}MMM${sep2}yyyy').format(date),
        );
      });
      test('d MMMM yyyy with multiple separators', () {
        // print('d.MMMM.yyyy (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('d${sep1}MMMM${sep2}yyyy').format(date),
        );
      });
      test('MMM d yyyy with multiple separators', () {
        // print('MMM.d.yyyy (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) =>
              DateFormat('MMM${sep1}d${sep2}yyyy').format(date),
        );
      });
      test('MMMM d yyyy with multiple separators', () {
        // print('MMMM.d.yyyy (any separator) format:');
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
        // print('yyyy.d.M (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) => DateFormat('yyyy/d/M').format(date),
        );
      });
      test('yyyy d M with multiple separators', () {
        // print('yyyy.d.M (any separator) format:');
        testRange(
          parser,
          (date, sep1, sep2) => DateFormat('yyyy${sep1}d${sep2}M').format(date),
        );
      });
    },
    skip: !exhaustiveTests,
  );
}
