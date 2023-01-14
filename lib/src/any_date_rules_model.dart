part of 'any_date_base.dart';

abstract class _DateParsingRule {
  final List<_DateParsingRule> rules;

  _DateParsingRule(this.rules);

  DateTime? apply(DateParsingParameters parameters);
}

class _SimpleRule extends _DateParsingRule {
  final DateTime? Function(DateParsingParameters params) _rule;
  _SimpleRule(this._rule) : super([]);

  @override
  DateTime? apply(DateParsingParameters parameters) {
    return _rule(parameters);
  }
}

class _MultipleRules extends _DateParsingRule {
  _MultipleRules(super.rules);

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
