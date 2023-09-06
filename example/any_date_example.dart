import 'package:any_date/any_date.dart';

void main() {
  const parser = AnyDate();
  final date = parser.parse('2023-May-23');
  print('awesome: $date');
}
