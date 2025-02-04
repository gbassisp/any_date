<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
[![PubStats Popularity](https://pubstats.dev/badges/packages/any_date/popularity.svg)](https://pubstats.dev/packages/any_date)


Package to improve DateTime manipulation, especially by allowing parsing any format. Heavily inspired by python's [dateutil](https://dateutil.readthedocs.io/en/stable/parser.html) package.


## Summary

In a glance, these are the features:

1. Easy parsing of a `String` with **many** date formats into a `DateTime` object
2. Same flexibility supported in almost any `Locale`. Not just English, but any language and culture
3. Always compliant with `ISO 8601` and major `RFC`s (822, 2822, 1123, 1036 and 3339), regardless of `Locale`
4. Supports UNIX time in either `seconds`, `milliseconds`, `microseconds`, or `nanoseconds` since epoch



## Basic usage

Usage is simple, use the `AnyDate()` constructor to create a parser with the desired settings, and use it to parse any `String` into `DateTime`, regardless of the format.

Note that, in order to resolve ambiguity, some settings are required either on the `AnyDate()` constructor or on the `AnyDate.defaultSettings` static attribute.

```dart
const parser = AnyDate();
final date = parser.parse('13 Aug 2023');
final sameDate = parser.parse('Aug 13 2023');
final stillTheSame = parser.parser('2023, August 13');
// in all cases date is parsed as DateTime(2023, 08, 13)
```


However, you may notice that the example above is in English. What if you want a different `Locale`? You can use the `AnyDate.fromLocale()` factory method to get the desired parser:

```dart
// American English
final parser1 = AnyDate.fromLocale('en-US');
final date1 = parser.parse('August 13, 2023');
// note that even if formatting is unusual for locale, it can still understand unambiguous dates
final sameDate = parser.parse('13 August 2023'); // this is not common for US locale, but it still parses normally


// Brazilian Portuguese
final parser2 = AnyDate.fromLocale('pt-BR');
final date2 = parser.parse('13 de Agosto de 2023');

// again, they all resolve to same DateTime value
```

## Solving ambiguous cases

Moreover, the parser can be used to solve ambiguous cases. Look at the following example:

```dart
// what date is this? 1 Feb 2003, 2 Jan 2003, or worse 2 Mar 2001?
// this could be dd/mm/yy, mm/dd/yy or yy/mm/dd
const ambiguousDate = '01/02/03';

// the parser can be configured for all cases:
// mm/dd/yy (this is the default behaviour)
const parser1 = AnyDate();
final case1 = a.parse(ambiguousDate); // results in DateTime(2003, 1, 2);

// dd/mm/yy
const dayFirstInfo = DateParserInfo(dayFirst: true);
const parser2 = AnyDate(info: info);
final case2 = a.parse(ambiguousDate); // results in DateTime(2003, 2, 1);

// yy/mm/dd
const yearFirstInfo = DateParserInfo(yearFirst: true);
const parser3 = AnyDate(info: info);
final case3 = a.parse(ambiguousDate); // results in DateTime(2001, 2, 3);
```



Using a `Locale` based parser also allows you to solve ambiguity based on that culture:

```dart
// same example:
const ambiguousDate = '01/02/03';

// American English
final parser1 = AnyDate.fromLocale('en-US');
final date1 = parser.parse(ambiguousDate); // the ambiguous date results in Jan 2, 2003 (mm/dd/yy)


// Brazilian Portuguese
final parser2 = AnyDate.fromLocale('pt-BR');
final date2 = parser.parse(ambiguousDate); // the ambiguous date results in Feb 1, 2003 (dd/mm/yy)
```


Feedback appreciated 💙
