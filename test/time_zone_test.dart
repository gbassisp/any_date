import 'package:any_date/any_date.dart';
import 'package:intl/intl.dart';
import 'package:lean_extensions/dart_essentials.dart';
import 'package:test/test.dart';

import 'test_values.dart';

Future<void> main() async {
  await initializeDateFormatting();
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
    test(
      'timezone offset ahead with iso sanity check',
      () {
        const offset1 = '2024-04-27T13:22:15+05:00';
        const offset2 = '2024-04-27T13:22:15+0500';
        const offset3 = '2024-04-27T13:22:15+05';
        final date = DateTime.parse(offset1);
        expect(date.isUtc, isTrue);
        expect(DateTime.parse(offset2), equals(date));
        expect(DateTime.parse(offset3), equals(date));

        const offset1n = '2024-04-27T13:22:15-05:00';
        const offset2n = '2024-04-27T13:22:15-0500';
        const offset3n = '2024-04-27T13:22:15-05';
        final date2 = DateTime.parse(offset1n);
        expect(date2.isUtc, isTrue);
        expect(DateTime.parse(offset2n), equals(date2));
        expect(DateTime.parse(offset3n), equals(date2));
      },
    );
    test('timezone offset ahead with iso format', () {
      const offset1 = '2024-04-27T13:22:15+0500';
      const offset2 = '2024-04-27T13:22:15+05:00';
      const offset3 = '2024-04-27T13:22:15+05';
      final date = DateTime.parse(offset1);

      expect(parser.parse(offset1), equals(date));
      expect(parser.parse(offset2), equals(date));
      expect(parser.parse(offset3), equals(date));
    });
    test('timezone offset behind with iso format', () {
      const offset1 = '2024-04-27T13:22:15-0500';
      const offset2 = '2024-04-27T13:22:15-05:00';
      const offset3 = '2024-04-27T13:22:15-05';
      final date = DateTime.parse(offset1);

      expect(parser.parse(offset1), equals(date));
      expect(parser.parse(offset2), equals(date));
      expect(parser.parse(offset3), equals(date));
    });
  });

  const format = 'yyyy MMM dd hh:mm:ss';
  group('$format with timezone offset', () {
    final f = DateFormat(format);
    const noOffset = '2024-04-27T13:22:15';
    var date = DateTime.parse(noOffset);
    final formatted = f.format(date);
    // in case the format looses information (e.g., no seconds)
    date = f.parse(formatted);
    final isoNoOffset = date.toIso8601String();
    const utc = [' Z', ' GMT', ' UTC'];
    final tz = ['+0100', '+0700', '+0930', '+0000']
        .expand(
          (element) => [
            element, // +0930
            element.substring(0, 3), // +09
            element.substring(0, 3) + element.substring(3), // +09:30
          ],
        )
        .expand((element) => [element, element.replaceAll('+', '-')]) // -09...
        .expand(
          (element) => [
            element,
            ' $element',
            '  $element',
          ],
        )
        .toList();

    for (final e in tz) {
      final expected = DateTime.parse('$isoNoOffset${e.trim()}');
      for (final p in parsers.entries) {
        test('$format with TZ offset as "$formatted$e" parser ${p.key}', () {
          expect(p.value.parse('$formatted$e'), equals(expected));
        });
      }
    }

    for (final e in utc) {
      final expected = DateTime.parse('${isoNoOffset}Z');
      for (final p in parsers.entries) {
        test('$format with UTC as "$formatted $e" parser ${p.key}', () {
          expect(p.value.parse('$isoNoOffset $e'), equals(expected));
          expect(p.value.parse('$formatted $e'), equals(expected));
        });
      }
    }
  });
}
