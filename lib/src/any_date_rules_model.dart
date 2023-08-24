// ignore_for_file: public_member_api_docs

import 'package:any_date/src/any_date_base.dart';

abstract class DateParsingRule {
  DateParsingRule(this.rules);
  final List<DateParsingRule> rules;

  DateTime? apply(DateParsingParameters parameters);
}

class SimpleRule extends DateParsingRule {
  SimpleRule(this._rule) : super([]);
  final DateTime? Function(DateParsingParameters params) _rule;

  @override
  DateTime? apply(DateParsingParameters parameters) {
    return _rule(parameters);
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
