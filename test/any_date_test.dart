import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'test_values.dart';

extension _DateFormatHacks on String {
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  bool get isInvalid => isAlpha || this.isEmpty || this == '_';
}

const defaultParser = AnyDate();
final separators = [
  ' ',
  ',',
  '\n',
  ':',
  '_',
  '/',
  ...AnyDate.defaultSettings.allowedSeparators,
];

void testRange(
  AnyDate parser,
  String Function(DateTime date, String sep1, String sep2) formatter, [
  DateTimeRange? customRange,
  // ignore: avoid_positional_boolean_parameters
  bool dayOnly = true,
]) {
  final cache = <String>{};
  final seps = AnyDate.defaultSettings.allowedSeparators.toList()
    ..removeWhere((e) => e.isInvalid);
  const step = Duration(hours: 23, minutes: 13);

  for (final date in (customRange ?? range).every(step)) {
    for (final a in seps) {
      for (final b in seps) {
        final f = formatter(date, a, b);
        if (!cache.contains(f)) {
          cache.add(f);
          final g = parser.parse(f);
          final reason = 'date: $date, f: $f, g: $g';
          if (dayOnly) {
            expect(g.year, date.year, reason: reason);
            expect(g.month, date.month, reason: reason);
            expect(g.day, date.day, reason: reason);
            return;
          }
          // this test doesn't support seconds or less; use something else
          expect(g.hour, date.hour, reason: reason);
          expect(g.minute, date.minute, reason: reason);
        }
      }
    }
  }
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

void compare(DateFormat format, AnyDate anyDate) {
  const step = Duration(
    hours: 23,
    minutes: 13,
    seconds: 17,
    microseconds: 123,
  );
  // for (final singleDate in range.every(step)) {
  for (final r in [range.days, range.every(step)]) {
    for (final singleDate in r) {
      final f = format;
      final d = f.format(singleDate);
      final a = anyDate;
      final reason = 'format: ${format.pattern}, date: $d';
      final e = f.tryParse(d);
      // expect(e, isNotNull, reason: 'DateFormat failed: $reason');
      final r = a.tryParse(d);
      expect(r, isNotNull, reason: 'AnyDate failed: $reason');
      // result should be formatted the same as the original
      final reformat = f.format(r!);
      expect(
        d,
        reformat,
        reason: 'format: ${format.pattern},\n'
            'formatted: $d,\n'
            'reformatted: $reformat,\n'
            'result: $r,\n'
            'expect: $e',
      );
    }
  }
}

void main() {
  group('basic AnyDate().parse tests', () {
    for (final format in {
      ...monthFirstFormats,
      ...monthFirstWithWeekday,
      ...otherFormats,
    }) {
      test('many formats - $format', () {
        final f = DateFormat(format);
        const a = AnyDate();
        compare(f, a);
      });
    }

    for (final format in {
      ...dayFirstFormats,
      ...dayFirstWithWeekday,
    }) {
      test('many formats - $format', () {
        final f = DateFormat(format);
        const a = AnyDate(info: DateParserInfo(dayFirst: true));
        compare(f, a);
      });
    }

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
