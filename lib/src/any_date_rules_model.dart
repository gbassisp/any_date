// ignore_for_file: public_member_api_docs

import 'package:any_date/src/any_date_base.dart';

abstract class DateParsingRule {
  DateParsingRule(this.rules);
  final List<DateParsingRule> rules;

  DateTime? apply(DateParsingParameters parameters);
}

class SimpleRule extends DateParsingRule {
  SimpleRule(this._rule, {this.validate = true}) : super([]);
  final DateTime? Function(DateParsingParameters params) _rule;
  final bool validate;

  @override
  DateTime? apply(DateParsingParameters parameters) {
    final param = parameters.copyWith(
      formattedString: _removeWeekday(parameters),
    );
    final expectedWeekday = _expectWeekday(parameters);
    final expectedMonth = _expectMonth(parameters);
    final res = _rule(param) ?? _rule(parameters);
    // print('applying rule');
    if (validate) {
      if (expectedWeekday != null && res?.weekday != expectedWeekday.number) {
        return null;
      }
      if (expectedMonth != null && res?.month != expectedMonth.number) {
        return null;
      }
    }

    return res;
  }
}

class MultipleRules extends DateParsingRule {
  MultipleRules(List<DateParsingRule> rules) : super(rules);

  @override
  DateTime? apply(DateParsingParameters parameters) {
    return _applyAll(parameters).firstWhere(
      (element) => element != null,
      orElse: () => null,
    );
  }

  Iterable<DateTime?> _applyAll(DateParsingParameters parameters) sync* {
    for (final r in rules) {
      try {
        yield r.apply(parameters);
      } catch (_) {}
    }
  }
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

String _removeWeekday(DateParsingParameters parameters) {
  var formattedString = parameters.formattedString.toLowerCase();
  for (final w in allWeekdays) {
    formattedString = formattedString.replaceAll(w.name.toLowerCase(), '');
  }

  return _removeExcessiveSeparators(
    parameters.copyWith(formattedString: formattedString),
  );
  // if (parameters.formattedString != formattedString) {
  //   print('removed weekday: ${parameters.formattedString} '
  //       '-> $formattedString');
  // }
  // return formattedString;
}

String _removeExcessiveSeparators(DateParsingParameters parameters) {
  var formattedString = parameters.formattedString;
  final separators = parameters.parserInfo.allowedSeparators;
  formattedString = replaceSeparators(formattedString, separators);
  for (final sep in separators) {
    // replace multiple separators with a single one
    formattedString = formattedString.replaceAll(RegExp('[$sep]+'), sep);
  }

  return _trimSeparators(formattedString, separators);
}

String _trimSeparators(String formattedString, Iterable<String> separators) {
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
