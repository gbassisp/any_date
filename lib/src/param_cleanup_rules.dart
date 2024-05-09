import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/any_date_rules.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/extensions.dart';
import 'package:any_date/src/time_zone_logic.dart';
import 'package:meta/meta.dart';

/// does the basic setup of [DateParsingParameters] for parsing logic
@internal
final basicSetup = MultipleRules([
  _setBasicParam,
  _initialCleanup,
  _timezoneCleanup,
]);

/// specific cleanup for messier formats
@internal
final cleanupRules = MultipleRules([
  _expectWeekdayAndMonth,
  _simplifyWeekday,
  _betterTimeComponent,
]);

final _setBasicParam = CleanupRule((params) {
  params
    ..formattedString = params.originalString.toLowerCase().trim()
    ..simplifiedString = params.originalString.toLowerCase().trim();

  return null;
});

final _initialCleanup = CleanupRule((params) {
  final formattedString = params.formattedString;
  final info = params.parserInfo;

  final caseInsensitive = _replaceSeparators(
    formattedString,
    info.allowedSeparators,
  );
  final i = info.copyWith(
    allowedSeparators: _usedSeparators.toList(),
  );
  params
    ..formattedString = caseInsensitive
    ..simplifiedString = caseInsensitive
    ..parserInfo = i;

  return null;
});

final _expectWeekdayAndMonth = CleanupRule((params) {
  params
    ..weekday = _expectWeekday(params)
    ..month = _expectMonth(params);
  // print('params now have weekday $params');

  return null;
});

final _simplifyWeekday = CleanupRule((params) {
  String removeWeekday() {
    // print('removing weekday from $params');
    if (params.weekday != null) {
      // print('removing weekday ${params.weekday} from $params');
      return params.formattedString
          .replaceFirst(params.weekday!.name.toLowerCase(), '');
    }

    return params.formattedString;
  }

  params
    ..formattedString = removeWeekday()
    ..simplifiedString = removeWeekday();

  return null;
});

/// used on iso date spacing; can and will be replaced with space
const _specialSeparators = {'t', 'T'};
const _forbiddenSeparators = {'^', r'$', '#'};
const _usedSeparators = usedSeparators;
const _knownSeparators = {..._usedSeparators, ..._specialSeparators};

/// these are the separators used by the default DateTime.parse
String _replaceSeparators(String formattedString, Iterable<String> separators) {
  var result = formattedString;
  result = replaceUtc(result);
  final unknownSeparators = separators.toSet().difference(_knownSeparators);

  // this needs to be an unused separator
  final separator = _forbiddenSeparators.last;
  for (final sep in unknownSeparators) {
    result = result.replaceAll(sep, separator);
  }

  return _restoreMillisecons(result, separator).replaceAll(separator, '-');
}

String _restoreMillisecons(String formattedString, String separator) {
  // regex with T00:00:00-000
  final r = RegExp(
    r't?(\d{1,2}:\d{1,2}:\d{1,2})' + separator + r'(\d+)',
    caseSensitive: false,
  );

  // replace with 00:00:00.000
  return formattedString.replaceAllMapped(
    r,
    (m) => ' ${m.group(1)}.${m.group(2)}',
  );
}

Month? _expectMonth(DateParsingParameters parameters) {
  final timestamp = parameters.formattedString.toLowerCase();
  final month = parameters.parserInfo.months.where(
    (element) =>
        element.name.tryToInt() == null &&
        timestamp.contains(element.name.toLowerCase()),
  );
  final english = allMonths.where(
    (element) => timestamp.contains(element.name.toLowerCase()),
  );

  return month.firstOrNullExtenstion ?? english.firstOrNullExtenstion;
}

Weekday? _expectWeekday(DateParsingParameters parameters) {
  final timestamp = parameters.formattedString.toLowerCase();
  final weekday = parameters.parserInfo.weekdays
      .where(
        (element) => timestamp.startsWith(element.name.toLowerCase()),
      )
      .firstOrNullExtenstion;
  final english = allWeekdays
      .where(
        (element) => timestamp.startsWith(element.name.toLowerCase()),
      )
      .firstOrNullExtenstion;

  return weekday ?? english;
}

final _exprs = [...idealTimePatterns]..removeLast();
final _betterTimeComponent = CleanupRule((params) {
  String padLeft(String? original) => (original ?? '').padLeft(2, '0');
  String padRight(String? original) => (original ?? '').padRight(3, '0');

  for (final e in _exprs) {
    final re = RegExp(e);
    final matches = re.allMatches(params.formattedString);
    // unsure what to do if many matches
    if (matches.length == 1) {
      final m = matches.first;
      final newString = params.formattedString.replaceAllMapped(
        re,
        (match) => '${padLeft(m.namedGroup('hour'))}:'
            '${padLeft(m.tryNamedGroup('minute'))}:'
            '${padLeft(m.tryNamedGroup('second'))}'
            '${m.tryNamedGroup('microsecond') != null ? '.'
                '${padRight(m.tryNamedGroup('microsecond'))}' : ''}',
      );
      params
        ..formattedString = newString
        ..simplifiedString = newString;
      // print(params);
      break;
    }
  }

  // print('parsing $params');
  return null;
});

final _timezoneCleanup = CleanupRule((params) {
  final timestamp = params.formattedString;
  final expectTz = hasTimezoneOffset(timestamp);
  if (expectTz) {
    final tz = getTimezoneOffset(timestamp);
    params.timezoneOffset = tz;
    final noTz = removeTimezoneOffset(timestamp);
    params
      ..formattedString = noTz
      ..simplifiedString = noTz;
  }

  return null;
});

extension _GroupNames on RegExpMatch {
  String? tryNamedGroup(String name) {
    try {
      return namedGroup(name);
    } catch (_) {
      return null;
    }
  }
}

extension _IterableX<T> on Iterable<T> {
  T? get firstOrNullExtenstion => isEmpty ? null : first;
  // T? get lastOrNull => isEmpty ? null : last;
}
