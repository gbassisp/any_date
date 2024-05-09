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

  group('nasa formats from stack overflow', () {
    const parser = AnyDate();
    test('format 1 complete', () {
      const formatted = 'Thu, 01 Jan 1970 00:00:00 +0000';
      final expected = DateTime.utc(1970);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('format 2 complete', () {
      const formatted = 'Thu, 01 Jan 1970 00:00:00 GMT';
      final expected = DateTime.utc(1970);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('format 1 without seconds', () {
      const formatted = 'Thu, 01 Jan 1970 00:00 +0000';
      final expected = DateTime.utc(1970);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('format 2 without seconds', () {
      const formatted = 'Thu, 01 Jan 1970 00:00 GMT';
      final expected = DateTime.utc(1970);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('format 1 complete +0130', () {
      const formatted = 'Thu, 01 Jan 1970 01:30:00 +0130';
      final expected = DateTime.utc(1970);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('format 1 without seconds +0130', () {
      const formatted = 'Thu, 01 Jan 1970 01:30 +0130';
      final expected = DateTime.utc(1970);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('format 1 complete -0130', () {
      const formatted = 'Thu, 01 Jan 1970 00:30:00 -0230';
      final expected = DateTime.utc(1970, 1, 1, 3);

      expect(parser.tryParse(formatted), equals(expected));
    });
    test('format 1 without seconds -0130', () {
      const formatted = 'Thu, 01 Jan 1970 00:30 -0230';
      final expected = DateTime.utc(1970, 1, 1, 3);

      expect(parser.tryParse(formatted), equals(expected));
    });
  });
}
