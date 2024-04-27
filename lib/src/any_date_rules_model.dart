// ignore_for_file: public_member_api_docs

import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/extensions.dart';
import 'package:any_date/src/time_zone_logic.dart';

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
    try {
      final simplifiedString = parameters.simplifiedString;
      final param = parameters.copyWith(formattedString: simplifiedString);
      final expectedWeekday = parameters.weekday;
      final expectedMonth = parameters.month;
      var res = _rule(param);
      if (res == null && simplifiedString != parameters.formattedString) {
        res = _rule(parameters);
      }

      if (validate) {
        if (expectedWeekday != null && res?.weekday != expectedWeekday.number) {
          return null;
        }
        if (expectedMonth != null && res?.month != expectedMonth.number) {
          return null;
        }
      }

      // try timezone
      final tz = getTimezoneOffset(parameters.originalString.trim());
      if (tz != null &&
          res != null &&
          !res.isUtc &&
          hasTimezoneOffset(parameters.originalString)) {
        return res.copyWithOffset(tz);
      }

      return res;
    } catch (_) {
      return null;
    }
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
