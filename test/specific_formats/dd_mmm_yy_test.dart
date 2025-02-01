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
  final notYearFirstParsers = {...parsers}
    ..removeWhere((key, value) => value.info.yearFirst);

  // print(notYearFirstParsers.length);
  for (final format in formats) {
    group('$format format', () {
      for (final parser in notYearFirstParsers.entries) {
        test('$format with parser #${parser.key}', () {
          final f = DateFormat(format);
          compare(f, parser);
        });
      }
    });
  }
}

final dates = closeToToday.every(const Duration(days: 38));
const separators = {'-', ' ', '/', '.'};
void compare(DateFormat format, MapEntry<String, AnyDate> anyDate) {
  for (final d in dates) {
    final date = d.dateOnly;
    for (final separator in separators) {
      final formatted = format.format(date).replaceAll('_', separator);
      final parsedDate = anyDate.value.tryParse(formatted)?.dateOnly;
      expect(
        parsedDate,
        equals(date),
        reason: 'format: $formatted\n'
            'parsed: $parsedDate\n'
            'parser: ${anyDate.key}',
      );

      final upper = formatted.toUpperCase();
      final parsedUpper = anyDate.value.tryParse(upper)?.dateOnly;
      expect(
        parsedUpper,
        equals(date),
        reason: 'format: $upper\n'
            'parsed: $parsedUpper\n'
            'parser: ${anyDate.key}',
      );

      final lower = formatted.toLowerCase();
      final parsedLower = anyDate.value.tryParse(lower)?.dateOnly;
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
