import 'package:any_date/src/any_date_base.dart';
import 'package:test/test.dart';

import 'test_values.dart';

void main() {
  const count = 100;
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
        for (var date in getRandomDates(count)) {
          final timestamp = date.millisecondsSinceEpoch ~/ 1000;
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
        for (final date in getRandomDates(count)) {
          final timestamp = date.millisecondsSinceEpoch;
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
        for (final date in getRandomDates(count)) {
          final timestamp = date.microsecondsSinceEpoch;
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
        for (var date in getRandomDates(count)) {
          final timestamp = date.microsecondsSinceEpoch * 1000;
          // removes rounding errors
          date = DateTime.fromMillisecondsSinceEpoch(timestamp ~/ 1000);
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
  }
}
