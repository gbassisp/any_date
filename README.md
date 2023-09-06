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

## Features

Still experimental and on early stages, but this package is meant to parse any timestamp into a DateTime object. Only depends on `intl` for testing, but the package has minimum constraints to work with pure Dart projects as well.

## Usage

Usage is simple, use the `AnyDate()` constructor to create a parser with the desired settings, and use it to parse any `String` into `DateTime`, regardless of the format.

Note that, in order to resolve ambiguity, some settings are required either on the `AnyDate()` constructor or on the `AnyDate.defaultSettings` static attribute.

```dart
const parser = AnyDate();
final date = parser.parse('13 Aug 2023');
// date is parsed as DateTime(2023, 08, 13)
```
