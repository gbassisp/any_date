
## 1.0.4

- Added support for git non-sense format, e.g., `Thu May 16 10:18:07 2024 +0930` and `Thu May 16 10:18:07pm 2024 +0930`

## 1.0.3

- Merged in `0.1.14`:  
  Added support for non-sense formats; at the moment only `yyyyMMdd'T'hhmmss` with no separator, including time variants

## 1.0.2

- Minor change to package description

## 1.0.1

- Added support for `intl` 0.19

## 1.0.0

Stable version release

### Features

- Supports any type of `Object` for parsing, such as `int` for unix epoch
- Allows passing custom parsing rules to `AnyDate(customRules: ...)`
- Added `AnyDate.fromLocale()` factory to support other languages. Essentially, any language can be used

### Breaking changes

- Requires `intl` dependency to support languages other than English


## 0.1.14

- Added support for non-sense formats; at the moment only `yyyyMMdd'T'hhmmss` with no separator, including time variants

## 0.1.13

- Added test cases to ensure RFC 822, 2822, 1036, 1123, and 3339 are supported
- Minor fixes to make them supported in edge cases
- Added support for unix epoch timestamp

## 0.1.12

- Fix caret syntax on dependencies

## 0.1.11

- Added homepage to `pubspec.yaml`

## 0.1.10

- Added more test cases and updated documentation

## 0.1.9

- Fix ambiguous parsing of `aa/bb/cc` format (e.g 01/02/03 that can be parsed as 2001-02-03, 2003-01-02, or 2003-02-01)

## 0.1.8

- Fix most of time component parsing

## 0.1.7

- Fix some cases where weekday wouldn't be parsed correctly

## 0.1.6

- Export DateParserInfo class to allow setting parameters

## 0.1.5

- Support a few more formats

## 0.1.4

- Removed unused dev dependencies

## 0.1.3

- Lower constraint on dev dependencies

## 0.1.2

- Fix issue where DateTime.parse was not being used

## 0.1.1

- No added feature, minor clean-up


## 0.1.0

- Initial version
- Includes basic date-only parsers
