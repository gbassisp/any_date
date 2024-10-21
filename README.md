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
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: BSD][license_badge]][license_link]

<a href="https://www.buymeacoffee.com/gbassisp" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

Package to improve DateTime manipulation, especially by allowing parsing any format.

There are no new classes to represent `DateTime`. Don't reinvent the wheel, just make it easier to use `DateTime`.

Heavily inspired by python's [dateutil](https://dateutil.readthedocs.io/en/stable/parser.html) package.

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




[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-BSD3-blue.svg
[license_link]: https://opensource.org/licenses/BSD-3
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
