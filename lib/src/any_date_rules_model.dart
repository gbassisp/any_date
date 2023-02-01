import 'any_date_base.dart';

abstract class DateParsingRule {
  final List<DateParsingRule> rules;

  DateParsingRule(this.rules);

  DateTime? apply(DateParsingParameters parameters);
}

class SimpleRule extends DateParsingRule {
  final DateTime? Function(DateParsingParameters params) _rule;
  SimpleRule(this._rule) : super([]);

  @override
  DateTime? apply(DateParsingParameters parameters) {
    return _rule(parameters);
  }
}

class MultipleRules extends DateParsingRule {
  MultipleRules(super.rules);

  @override
  DateTime? apply(DateParsingParameters parameters) {
    return _applyAll(parameters).firstWhere(
      (element) => element != null,
      orElse: () => null,
    );
  }

  Iterable<DateTime?> _applyAll(DateParsingParameters parameters) sync* {
    for (var r in rules) {
      try {
        yield r.apply(parameters);
      } catch (_) {}
    }
  }
}
