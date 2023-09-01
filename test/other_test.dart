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
}
