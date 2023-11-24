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

Package to improve DateTime manipulation, especially by allowing parsing any format. Heavily inspired by python's [dateutil](https://dateutil.readthedocs.io/en/stable/parser.html) package.

## Usage

Usage is simple, use the `AnyDate()` constructor to create a parser with the desired settings, and use it to parse any `String` into `DateTime`, regardless of the format.

Note that, in order to resolve ambiguity, some settings are required either on the `AnyDate()` constructor or on the `AnyDate.defaultSettings` static attribute.

```dart
const parser = AnyDate();
final date = parser.parse('13 Aug 2023');
final sameDate = parser.parse('Aug 13 2023');
final stillTheSame = parser.parser('2023, August 13');
// in all cases date is parsed as DateTime(2023, 08, 13)
```

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

It currently has basic support for time component as well, but there is still some work in progress. Feedback appreciated.
