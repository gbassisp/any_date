import 'package:any_date/src/any_date_base.dart';
import 'package:lean_extensions/dart_essentials.dart';
import 'package:test/test.dart';

void main() {
  final dates = [
    DateTime(1901),
    DateTime(1960),
    // 1969-09-23 09:30:00.000 (lower limit of ambiguity)
    DateTime.fromMillisecondsSinceEpoch(-8640000001),
    DateTime.fromMicrosecondsSinceEpoch(0),
    // 1970-04-11 09:30:00.000 (upper limit of ambiguity)
    DateTime.fromMillisecondsSinceEpoch(8640000001),
    DateTime(1980),
    DateTime.now(),
    DateTime(2038),

    // out of original limit by 100y
    DateTime(1801),
    DateTime(2138),
  ];
  const parserInfos = [
    DateParserInfo(),
    DateParserInfo(dayFirst: true),
    DateParserInfo(yearFirst: true),
    DateParserInfo(dayFirst: true, yearFirst: true),
  ];

  for (final info in parserInfos) {
    group('unix timestamp - $info', () {
      final parser = AnyDate(info: info);

      test('seconds', () {
        for (var date in dates) {
          final timestamp = date.secondsSinceEpoch;
          // removes rounding errors
          date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          final parsed = parser.tryParse(timestamp.toString());
          expect(
            parsed,
            date,
            reason: 'tried to parse $timestamp into $date but got $parsed'
                ' with $info',
          );
        }
      });
      test('milliseconds', () {
        for (var date in dates) {
          final timestamp = date.millisecondsSinceEpoch;
          // removes rounding errors
          date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final parsed = parser.tryParse(timestamp.toString());
          expect(
            parsed,
            date,
            reason: 'tried to parse $timestamp into $date but got $parsed'
                ' with $info',
          );
        }
      });
      test('microseconds', () {
        for (var date in dates) {
          final timestamp = date.microsecondsSinceEpoch;
          // removes rounding errors
          date = DateTime.fromMicrosecondsSinceEpoch(timestamp);
          final parsed = parser.tryParse(timestamp.toString());
          expect(
            parsed,
            date,
            reason: 'tried to parse $timestamp into $date but got $parsed'
                ' with $info',
          );
        }
      });
      test('nanoseconds', () {
        for (var date in dates) {
          final timestamp = date.nanosecondsSinceEpoch;
          // removes rounding errors
          date = DateTime.fromMicrosecondsSinceEpoch(timestamp ~/ 1000);
          final parsed = parser.tryParse(timestamp.toString());
          expect(
            parsed,
            date,
            reason: 'tried to parse $timestamp into $date but got $parsed'
                ' with $info',
          );
        }
      });
    });

    // unix time is supposed to be in seconds, but people started using milli,
    // micro and nano seconds... this means that a small number (less than
    // 8640000000 seconds) can be any of these
    group('ambiguous  unix time', () {
      const parser = AnyDate();
      test('seconds is always right', () {
        for (final t in range(-8640000000, 8640000000, 12345)) {
          final res = parser.tryParse(t.toString());
          final expected = DateTime.fromMillisecondsSinceEpoch(t * 1000);
          expect(
            res,
            equals(expected),
            reason: 'parsing $t seconds resulted in $res instead of $expected',
          );
        }
      });
    });
  }
}

extension _UnixTime on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
  int get nanosecondsSinceEpoch => microsecondsSinceEpoch * 1000;
}
