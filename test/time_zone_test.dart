import 'package:any_date/any_date.dart';
import 'package:lean_extensions/dart_essentials.dart';
import 'package:test/test.dart';

void main() {
  const parser = AnyDate();
  const utcSymbol = 'Z';
  group('utc with iso format', () {
    void expectUtc(String symbol) {
      for (final i in range(4)) {
        final date = DateTime.now().toUtc();
        final iso =
            date.toIso8601String().replaceAll(utcSymbol, '${' ' * i}$symbol');
        // print(iso);

        expect(parser.tryParse(iso), equals(date));
      }
    }

    test('learning test - sanity check', () {
      final date = DateTime.now().toUtc();
      final iso = date.toIso8601String();
      const reason = 'other tests rely on replacing utc symbol in timestamp';
      expect(iso.endsWith(utcSymbol), isTrue, reason: reason);
      expect(
        iso.indexOf(utcSymbol),
        equals(iso.lastIndexOf(utcSymbol)),
        reason: reason,
      );
      expect(parser.tryParse(iso), equals(date));
    });
    test('basic utc now - Z', () {
      expectUtc('Z');
    });
    test('basic utc now - GMT', () {
      expectUtc('GMT');
    });
    test('basic utc now - UTC', () {
      expectUtc('UTC');
    });
    test('basic utc now - GMT+0000', () {
      expectUtc('GMT+0000');
    });
    test('basic utc now - GMT-0000', () {
      expectUtc('GMT-0000');
    });
    test('basic utc now - +0000', () {
      expectUtc('+0000');
    });
    test('basic utc now - -0000', () {
      expectUtc('-0000');
    });
    test('basic utc now - +00', () {
      expectUtc('+00');
    });
    test('basic utc now - -00', () {
      expectUtc('-00');
    });
  });
}
