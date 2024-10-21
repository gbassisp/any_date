import 'package:any_date/any_date.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'test_values.dart';

void main() {
  const parsers = {
    'default params': AnyDate(),
    'day first': AnyDate(info: DateParserInfo(dayFirst: true)),
  };
  const seps = ['-', '/'];
  for (final e in parsers.entries) {
    group('dd-MMM-yy', () {
      for (final s in seps) {
        final dateComponent = 'dd${s}MMM${s}yy';
        test('$dateComponent should work on ${e.key}', () {
          final p = e.value;
          final f = DateFormat(dateComponent);
          for (final date in closeToToday.days) {
            final formatted = f.format(date);
            final upper = formatted.toUpperCase();
            final lower = formatted.toLowerCase();

            expect(p.parse(formatted), date);
            expect(p.parse(upper), date);
            expect(p.parse(lower), date);
          }
        });
        test('${e.key} should accept time component on $dateComponent', () {
          final p = e.value;
          final f = DateFormat('$dateComponent hh:mm:ss');
          for (final date in closeToToday.days) {
            final withTime = date.dateOnly.add(
              const Duration(hours: 10, minutes: 11, seconds: 12),
            );
            final formatted = f.format(withTime);
            final upper = formatted.toUpperCase();
            final lower = formatted.toLowerCase();

            expect(p.parse(formatted), withTime);
            expect(p.parse(upper), withTime);
            expect(p.parse(lower), withTime);
          }
        });
      }
    });
  }
}
