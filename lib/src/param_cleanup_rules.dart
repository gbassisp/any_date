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
  var result = _replaceComma(formattedString);
  result = replaceUtc(result);
  final unknownSeparators = separators.toSet().difference(_knownSeparators);

  // this needs to be an unused separator
  final separator = _forbiddenSeparators.last;
  for (final sep in unknownSeparators) {
    result = result.replaceAll(sep, separator);
  }

  return _restoreMillisecons(result, separator).replaceAll(separator, '-');
}

String _replaceComma(String formattedString) {
  final re1 = RegExp(r',\s+');
  final re2 = RegExp(r',\s+');
  final re3 = RegExp(r'\s+');

  return formattedString
      .replaceAll(re1, ' ')
      .replaceAll(re2, ' ')
      .replaceAll(re3, ' ');
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

// .reversed because it works for disambiguation
// (e.g., in vi locale try 'thang 12' before 'thang 1')
Iterable<Month> _sortMonths(Iterable<Month> months) {
  final sorted = months.toList()
    ..sort((a, b) => a.name.length.compareTo(b.name.length))
    ..sort((a, b) => a.number.compareTo(b.number));

  return sorted.reversed;
}

Month? _expectMonth(DateParsingParameters parameters) {
  final timestamp = parameters.formattedString.toLowerCase();
  final month = _sortMonths(parameters.parserInfo.months).where(
    (element) =>
        element.name.tryToInt() == null &&
        timestamp.contains(element.name.toLowerCase()),
  );
  final english = allMonths.where(
    (element) => timestamp.contains(element.name.toLowerCase()),
  );

  return month.firstOrNullExtension ?? english.firstOrNullExtension;
}

// .reversed because it works for disambiguation
// (e.g., in vi locale try 'thang 12' before 'thang 1')
Iterable<Weekday> _sortWeekdays(Iterable<Weekday> weekdays) {
  final sorted = weekdays.toList()
    ..sort((a, b) => a.name.length.compareTo(b.name.length))
    ..sort((a, b) => a.number.compareTo(b.number));

  return sorted.reversed;
}

Weekday? _expectWeekday(DateParsingParameters parameters) {
  // TODO(gbassisp): allow weekday in any part of the string
  // currently unsupported because some locales can have a conflict between
  // month and weekday (e.g., "Mar" in French for Mardi and Mars)
  final timestamp = parameters.formattedString.toLowerCase();
  var weekday = _sortWeekdays(parameters.parserInfo.weekdays)
      .where(
        (element) => timestamp.startsWith(element.name.toLowerCase()),
        // (element) => timestamp
        //     .contains(RegExp('\\D${element.name}', caseSensitive: false)),
      )
      .firstOrNullExtension;
  if (weekday != null) return weekday;
//   weekday = parameters.parserInfo.weekdays
//       .where((element) => timestamp.endsWith(element.name.toLowerCase()))
//       .firstOrNullExtension;
//   if (weekday != null) return weekday;

// english
  weekday = allWeekdays
      .where(
        (element) => timestamp.startsWith(element.name.toLowerCase()),
      )
      .firstOrNullExtension;
  if (weekday != null) return weekday;

  return allWeekdays
      .where(
        (element) => timestamp.endsWith(element.name.toLowerCase()),
      )
      .firstOrNullExtension;
}

final _exprs = [...idealTimePatterns]..removeLast();
final _betterTimeComponent = CleanupRule((params) {
  String padLeft(String? original) => (original ?? '').padLeft(2, '0');
  String padRight(String? original) => (original ?? '').padRight(3, '0');
  String cleanAmpm(String? original) =>
      original?.replaceAll(RegExp(r'(\.|-)'), '').toLowerCase() ?? '';

  for (final e in _exprs) {
    const ampm = r'\s*(?<ampm>(a|p)(\.|-)?m(\.|-)?\W)?';
    final re = RegExp(e + ampm, caseSensitive: false);
    final s = '${params.formattedString} ';
    final matches = re.allMatches(s);
    // unsure what to do if many matches
    if (matches.length == 1) {
      final m = matches.first;
      final newTime = ' ${padLeft(m.namedGroup('hour'))}:'
          '${padLeft(m.tryNamedGroup('minute'))}:'
          '${padLeft(m.tryNamedGroup('second'))}'
          '${m.tryNamedGroup('microsecond') != null ? '.'
              '${padRight(m.tryNamedGroup('microsecond'))}' : ''} '
          '${cleanAmpm(m.tryNamedGroup('ampm'))}';
      final newString = s.replaceAllMapped(re, (_) => '') + newTime;

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
  T? get firstOrNullExtension => isEmpty ? null : first;
  // T? get lastOrNull => isEmpty ? null : last;
}
