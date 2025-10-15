import 'package:any_date/src/locale_extensions.dart';
import 'package:intl/locale.dart' show Locale;
import 'package:test/test.dart';

import 'test_values.dart';

Future<void> main() async {
  await initializeDateFormatting();
  group('getters do not throw', () {
    group('usesNumericSymbols', () {
      for (final locale in allLocales) {
        test(locale, () {
          final l = Locale.tryParse(locale);
          if (l == null) {
            return;
          }

          expect(() => l.usesNumericSymbols, isNot(throwsA(anything)));
        });
      }
    });
  });
}
