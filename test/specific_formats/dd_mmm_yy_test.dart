import 'package:any_date/any_date.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import '../test_values.dart';

void main() async {
  await initializeDateFormatting();
  final formats = {
    'dd-MMM-yy',
    'dd-MMM-yyyy',
  };
  final notYearFirstParsers = parsers.where((p) => !p.info.yearFirst);
  // print(notYearFirstParsers.length);
  for (final format in formats) {
    group('$format format', () {
      var i = 0;
      for (final parser in notYearFirstParsers) {
        test('$format with parser #$i', () {
          final f = DateFormat(format);
          compare(f, parser);
        });
        i++;
      }
    });
  }
}

void compare(DateFormat format, AnyDate anyDate) {
  final dates = closeToToday.every(const Duration(days: 8));
  const separators = {'-', ' ', '/', '.'};
  for (final d in dates) {
    final date = d.dateOnly;
    for (final separator in separators) {
      final formatted = format.format(date).replaceAll('_', separator);
      final parsedDate = anyDate.parse(formatted).dateOnly;
      expect(
        parsedDate,
        equals(date),
        reason: 'format: $formatted\n'
            'parsed: $parsedDate\n'
            'parser: ${anyDate.info}',
      );

      final upper = formatted.toUpperCase();
      final parsedUpper = anyDate.parse(upper).dateOnly;
      expect(
        parsedUpper,
        equals(date),
        reason: 'format: $upper\n'
            'parsed: $parsedUpper\n'
            'parser: ${anyDate.info}',
      );

      final lower = formatted.toLowerCase();
      final parsedLower = anyDate.parse(lower).dateOnly;
      expect(
        parsedLower,
        equals(date),
        reason: 'format: $lower\n'
            'parsed: $parsedLower\n'
            'parser: ${anyDate.info}',
      );
    }
  }
}
