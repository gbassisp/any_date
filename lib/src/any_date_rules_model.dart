import 'package:any_date/src/any_date_base.dart';
import 'package:any_date/src/extensions.dart';
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
      final expectedWeekday = parameters.weekday;
      final expectedMonth = parameters.month;
      var res = _rule(parameters);

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
      final tz = parameters.timezoneOffset;
      if (tz != null && res != null && !res.isUtc) {
        return res.copyWithOffset(tz);
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

@internal
class CleanupRule extends SimpleRule {
  CleanupRule(DateTime? Function(DateParsingParameters params) rule)
      : super(rule);

  void _cleanup(DateParsingParameters parameters) {
    final newValue = _trimSeparators(
      _removeSpacing(parameters.formattedString),
      parameters.parserInfo.allowedSeparators,
    ).trim();

    parameters
      ..formattedString = newValue
      ..simplifiedString = newValue;
  }

  static final _re = RegExp(r'\s+');
  String _removeSpacing(String timestamp) {
    return timestamp.replaceAllMapped(_re, (match) => ' ').trim().toLowerCase();
  }

  String _trimSeparators(String timestamp, Iterable<String> separators) {
    var updated = timestamp;
    final seps = '(\\${separators.join(r'|\')})';
    final right = RegExp('$seps+\$');
    updated = updated.replaceAllMapped(right, (match) => '');

    final left = RegExp('^$seps+(?!$seps)');
    return updated.replaceAllMapped(left, (match) => '');
  }

  @override
  DateTime? apply(DateParsingParameters parameters) {
    final res = super._rule(parameters);
    _cleanup(parameters);

    return res;
  }
}
