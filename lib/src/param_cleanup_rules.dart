import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/any_date_rules.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:any_date/src/time_zone_logic.dart';
import 'package:meta/meta.dart';

/// entry point for all clean-up rules
@internal
final cleanupRules = MultipleRules([
  _setBasicParam,
  // ..weekday = _expectWeekday(p)
  // ..month = _expectMonth(p);
  _simplifyWeekday,
]);

final _setBasicParam = SimpleRule((params) {
  final formattedString = params.originalString;
  final info = params.parserInfo;

  final caseInsensitive = _replaceSeparators(
    formattedString.trim().toLowerCase(),
    info.allowedSeparators,
  );
  final i = info.copyWith(
    allowedSeparators: _usedSeparators.toList(),
  );
  final p = DateParsingParameters(
    formattedString: caseInsensitive,
    parserInfo: i,
    originalString: formattedString,
  );

  return null;
});

final _simplifyWeekday = SimpleRule((params) {
  String trimSeparators(String formattedString, Iterable<String> separators) {
    var result = formattedString;
    for (final sep in separators) {
      while (result.startsWith(sep)) {
        result = result.substring(1).trim();
      }

      while (result.endsWith(sep)) {
        result = result.substring(0, result.length - 1).trim();
      }
    }
    return result;
  }

  String removeExcessiveSeparators(DateParsingParameters parameters) {
    var formattedString = parameters.formattedString;
    final separators = parameters.parserInfo.allowedSeparators;
    formattedString = _replaceSeparators(formattedString, separators);
    for (final sep in separators) {
      // replace multiple separators with a single one
      formattedString = formattedString.replaceAll(RegExp('[$sep]+'), sep);
    }

    return trimSeparators(formattedString, separators);
  }

  String removeWeekday() {
    final parameters = params;
    var formattedString = parameters.formattedString.toLowerCase();
    for (final w in allWeekdays) {
      formattedString = formattedString.replaceAll(w.name.toLowerCase(), '');
    }

    return removeExcessiveSeparators(
      parameters.copyWith(formattedString: formattedString),
    );
  }

  params.simplifiedString = removeWeekday();

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
  final month = allMonths.where(
    (element) => timestamp.contains(element.name.toLowerCase()),
  );

  if (month.isEmpty) {
    return null;
  }

  return month.first;
}

Weekday? _expectWeekday(DateParsingParameters parameters) {
  final timestamp = parameters.formattedString.toLowerCase();
  final weekday = allWeekdays.where(
    (element) => timestamp.contains(element.name.toLowerCase()),
  );

  if (weekday.isEmpty) {
    return null;
  }

  return weekday.first;
}
// TODO(gbassisp): consolidate all these extra pre-processing functions
