import 'package:any_date/src/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DateTime extensions', () {
    test('safeCopyWith - invalid', () {
      final date = DateTime(2000);

      expect(
        () => date.safeCopyWith(microsecond: 1234),
        throwsA(isA<FormatException>()),
        reason: 'the new microseconds would result in a change in milliseconds',
      );
    });
  });
}
