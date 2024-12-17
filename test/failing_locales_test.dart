// the following locales are failing:
// vi
// nyn
// ln
// zh-TW
// zh_HK
// zh_CN
// zh
// ko
// mn
// ja
import 'package:any_date/any_date.dart';
import 'package:any_date/src/extensions.dart';
import 'package:intl/intl.dart';
import 'package:test/test.dart';

import 'test_values.dart';

const _failing = {
  'vi',
  'nyn',
  'ln',
  'zh_TW',
  'zh_HK',
  'zh_CN',
  'zh',
  'ko',
  'mn',
  'ja',
};
Future<void> main() async {
  await initializeDateFormatting();

  final date = DateTime.now().dateOnly;
  group('ensure failing locales are working', () {
    for (final l in _failing) {
      final format = DateFormat.yMMMMd(l);
      final formatted = format.format(date);
      test('locale $l can parse $formatted text month', () {
        final parser = AnyDate.fromLocale(l);

        final parsed = parser.tryParse(formatted);

        expect(parsed, equals(date));
      });

      test('sanity check - locale $l can self-parse $formatted text month', () {
        final parsed = format.tryParse(formatted);

        expect(parsed, equals(date));
      });
    }
  });
}
