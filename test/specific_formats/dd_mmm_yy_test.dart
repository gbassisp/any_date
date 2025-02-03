import 'package:any_date/any_date.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import '../test_values.dart';

void main() async {
  await initializeDateFormatting();
  // with english format
  final formats = {
    'dd-MMM-yy',
    'dd-MMM-yyyy',
  };

  for (final format in formats) {
    group('$format format', () {
      for (final parser in englishParsers.entries) {
        test('$format with parser #${parser.key}', () {
          final f = DateFormat(format, 'en');
          compare(f, parser);
        });
      }
    });
  }
}

final dates = closeToToday.every(const Duration(days: 38));
// final dates = [DateTime.now()];
const separators = {'-', ' ', '/', '.'};
void compare(DateFormat format, MapEntry<String, AnyDate> anyDate) {
  for (final d in dates) {
    final date = d.dateOnly;
    for (final separator in separators) {
      final formatted = format.format(date).replaceAll('_', separator);
      final parsedDate = anyDate.value.parse(formatted).dateOnly;
      expect(
        parsedDate,
        equals(date),
        reason: 'format: $formatted\n'
            'parsed: $parsedDate\n'
            'parser: ${anyDate.key}',
      );

      final upper = formatted.toUpperCase();
      final parsedUpper = anyDate.value.parse(upper).dateOnly;
      expect(
        parsedUpper,
        equals(date),
        reason: 'format: $upper\n'
            'parsed: $parsedUpper\n'
            'parser: ${anyDate.key}',
      );

      final lower = formatted.toLowerCase();
      final parsedLower = anyDate.value.parse(lower).dateOnly;
      expect(
        parsedLower,
        equals(date),
        reason: 'format: $lower\n'
            'parsed: $parsedLower\n'
            'parser: ${anyDate.key}',
      );
    }
  }
}
