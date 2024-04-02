import 'package:any_date/src/any_date_base.dart';
import 'package:meta/meta.dart';

/// A function that takes a [String] and tries to convert
/// to a [DateTime] object.
typedef DateParsingFunction = DateTime? Function(String params);

/// A function that takes the entire [DateParsingParameters] and converts to
/// a [DateTime] object.
@internal
typedef CompleteDateParsingFunction = DateTime? Function(
  DateParsingParameters params,
);

@internal
abstract class DateParsingRule {
  DateParsingRule(this.rules);
  final List<DateParsingRule> rules;

  DateTime? apply(DateParsingParameters parameters);
}

@internal
class SimpleRule extends DateParsingRule {
  SimpleRule(this._rule, {this.validate = true}) : super([]);
  final CompleteDateParsingFunction _rule;
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

      return res;
    } catch (_) {
      return null;
    }
  }
}

@internal
class MultipleRules extends DateParsingRule {
  MultipleRules(List<DateParsingRule> rules) : super(rules);

  factory MultipleRules.fromFunctions(Iterable<DateParsingFunction> functions) {
    return MultipleRules(
      functions
          .map(
            (e) => MultipleRules([
              SimpleRule((params) => e(params.originalString)),
              SimpleRule((params) => e(params.formattedString)),
            ]),
          )
          .toList(),
    );
  }

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
