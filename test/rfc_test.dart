import 'package:any_date/src/any_date_base.dart';
import 'package:test/test.dart';

void main() {
  final dates = [
    DateTime(1901),
    DateTime(1960),
    DateTime.fromMicrosecondsSinceEpoch(0),
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
          final timestamp = date.microsecondsSinceEpoch * 1000;
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
  }
}
