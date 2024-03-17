import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/date_range.dart';
import 'package:test/test.dart';

void main() {
  const secondsLimit = 8640000000;
  final dates = [
    DateTime(1901),
    DateTime(1960),
    // 1969-09-23 09:30:00.000 (lower limit of ambiguity)
    DateTime.fromMillisecondsSinceEpoch(-secondsLimit - 1),
    DateTime.fromMicrosecondsSinceEpoch(0),
    // 1970-04-11 09:30:00.000 (upper limit of ambiguity)
    DateTime.fromMillisecondsSinceEpoch(secondsLimit + 1),
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
    group('ambiguous unix time', () {
      const parser = AnyDate();
      test('seconds is always right', () {
        for (final d in DateTimeRange(
          start: DateTime(1801),
          end: DateTime(2138),
        ).hours) {
          final t = d.secondsSinceEpoch;
          final s = parser.tryParse(t.toString());
          final expected = d;

          expect(
            s,
            equals(expected),
            reason: 'parsing $d seconds resulted in $s instead of $expected',
          );
        }
      });

      test('milli, micro and nanoseconds fail when too small', () {
        for (final d in DateTimeRange(
          // this is the limit where seconds and milliseconds start to get
          // mixed up. we start getting milliseconds parsed as seconds
          start: DateTime.fromMillisecondsSinceEpoch(-secondsLimit),
          end: DateTime.fromMillisecondsSinceEpoch(secondsLimit),
        ).hours) {
          final ms = d.millisecondsSinceEpoch;
          final us = d.microsecondsSinceEpoch;
          final ns = d.nanosecondsSinceEpoch;
          final msd = parser.tryParse(ms.toString());
          final usd = parser.tryParse(us.toString());
          final nsd = parser.tryParse(ns.toString());
          final reason = 'parsing $d resulted in:\n'
              'milli: $ms into $msd'
              'micro: $us into $usd'
              'milli: $ns into $nsd';

          // except for 0 unix time. this is the same for every case
          if (ms == 0) {
            continue;
          }

          expect(msd, isNot(equals(d)), reason: reason);
          expect(usd, isNot(equals(d)), reason: reason);
          expect(nsd, isNot(equals(d)), reason: reason);
        }
      });
    });
  }
}

extension _UnixTime on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
  int get nanosecondsSinceEpoch => microsecondsSinceEpoch * 1000;
}

extension _IterableRange on DateTimeRange {
  Iterable<DateTime> get hours => every(const Duration(hours: 1));
  // Iterable<DateTime> get minutes => every(const Duration(minutes: 1));
  // Iterable<DateTime> get seconds => every(const Duration(seconds: 1));
}
