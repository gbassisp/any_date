import 'package:any_date/any_date.dart';
import 'package:test/test.dart';

void main() {
  group('lack of separators formats', () {
    const parser = AnyDate();
    test('yyyyMMddThhmmssSSSSSS', () {
      const formatted = '20240420T152235123456';
      final expected = DateTime(2024, 4, 20, 15, 22, 35, 123, 456);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('yyyyMMddThhmmssSSS', () {
      const formatted = '20240420T152235123';
      final expected = DateTime(2024, 4, 20, 15, 22, 35, 123);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('yyyyMMddThhmmss', () {
      const formatted = '20240420T152235';
      final expected = DateTime(2024, 4, 20, 15, 22, 35);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('yyyyMMddThhmm', () {
      const formatted = '20240420T1522';
      final expected = DateTime(2024, 4, 20, 15, 22);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('yyyyMMddThh', () {
      const formatted = '20240420T15';
      final expected = DateTime(2024, 4, 20, 15);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('yyyyMMddT', () {
      const formatted = '20240420T';
      final expected = DateTime(2024, 4, 20);

      expect(parser.tryParse(formatted), equals(expected));
    });
  });
}
