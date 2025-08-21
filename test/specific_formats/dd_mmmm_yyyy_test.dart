import 'package:any_date/functions.dart';
import 'package:any_date/src/any_date_base.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import '../test_values.dart';

Future<void> main() async {
  await initializeDateFormatting();
  final date = DateTime(2025, 8, 21);
  const locale = 'sq';
  final timestamp = DateFormat('dd MMMM yyyy', locale).format(date);
  group('$timestamp with $locale locale', () {
    test('can parse dd MMMM yyyy', () {
      final fromParser = AnyDate.fromLocale(locale).tryParse(timestamp);
      expect(fromParser, isNotNull);
      expect(fromParser!.day, 21);
      expect(fromParser.month, 8);
      expect(fromParser.year, 2025);

      final fromFunction = tryParseAnyDateTime(timestamp, locale: locale);
      expect(fromFunction, isNotNull);
      expect(fromFunction!.day, 21);
      expect(fromFunction.month, 8);
      expect(fromFunction.year, 2025);
    });
  });
}
