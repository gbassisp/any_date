import 'package:any_date/src/any_date_rules.dart';
import 'package:any_date/src/any_date_rules_model.dart';
import 'package:meta/meta.dart';

/// this is a group of ridiculous formats that should be embarassing to use
@internal
final nonsenseRules = MultipleRules([
  _concatenatedComponents,
]);

final _concatenatedComponents = SimpleRule((params) {
  final timestamp = params.formattedString.toUpperCase();
  const sep = 'T';
  final re = RegExp(r'^\d+' + sep + r'\d*$');
  final matched = re.stringMatch(timestamp) ?? '';
  if (matched.isNotEmpty) {
    final date = matched.split(sep).first.padLeft(8, '0');
    final time = matched.split(sep).last.padRight(12, '0');
    final reformatted = '${date.substring(0, 4)}-'
        '${date.substring(4, 6)}-'
        '${date.substring(6, 8)}T'
        '${time.substring(0, 2)}:'
        '${time.substring(2, 4)}:'
        '${time.substring(4, 6)}.'
        '${time.substring(6)}';
    // print('found $matched and changed to $reformatted');
    return maybeDateTimeParse.apply(
      params.copyWith(
        formattedString: reformatted,
        originalString: reformatted,
      ),
    );
  }

  return null;
});
