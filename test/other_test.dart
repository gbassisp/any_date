import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

final _r = DateTimeRange(start: DateTime(2000), end: DateTime(2002));

Weekday _weekdayByName(String name) {
  return allWeekdays.firstWhere((w) => w.name == name);
}

Month _monthByName(String name) {
  return allMonths.firstWhere((m) => m.name == name);
}

void main() {
  group('weekday and month models', () {
    test('weekday matches DateTime().weekday', () {
      final f1 = DateFormat('EEEE');
      final f2 = DateFormat('EEE');
      for (final d in _r.days) {
        final weekday1 = _weekdayByName(f1.format(d));
        final weekday2 = _weekdayByName(f2.format(d));
        expect(weekday1.number, weekday2.number);
        expect(weekday1.number, d.weekday);
      }
    });
    test('month matches DateTime() month', () {
      final f1 = DateFormat('MMMM');
      final f2 = DateFormat('MMM');
      for (final d in _r.days) {
        final month1 = _monthByName(f1.format(d));
        final month2 = _monthByName(f2.format(d));
        expect(month1.number, month2.number);
        expect(month1.number, d.month);
      }
    });
  });

  group('learning tests', () {
    test('iso date parse does not require T separator', () {
      final d = DateTime.parse('2020-01-01 01:02:03');
      expect(d, DateTime(2020, 1, 1, 1, 2, 3));

      final date = DateTime(1999, 12, 31, 23, 59, 59, 999);
      final f1 = date.toIso8601String();
      final f2 = f1.replaceAll('T', ' ');
      final f3 = f1.replaceAll('T', '-');

      expect(f1, contains('T'));
      expect(f2, isNot(contains('T')));
      expect(f3, isNot(contains('T')));
      expect(f3, isNot(contains(' ')));

      final parsed1 = DateTime.parse(f1);
      final parsed2 = DateTime.parse(f2);
      final parsed3 = DateTime.tryParse(f3);
      expect(parsed1, equals(date));
      expect(parsed2, equals(date));

      // other separators are not allowed
      expect(parsed3, isNull);
    });
  });
}
