import 'dart:math';

import 'package:any_date/any_date.dart';
import 'package:any_date/src/date_range.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'package:intl/locale.dart';

final defaultParsers = {
  'default': const AnyDate(),
  'dayFirst': const AnyDate(info: DateParserInfo(dayFirst: true)),
  'yearFirst': const AnyDate(info: DateParserInfo(yearFirst: true)),
  'day and year first':
      const AnyDate(info: DateParserInfo(dayFirst: true, yearFirst: true)),
  'en': AnyDate.fromLocale(Locale.parse('en')),
  'en-US': AnyDate.fromLocale(Locale.parse('en-US')),
  'en-UK': AnyDate.fromLocale(Locale.parse('en-UK')),
  'en-AU': AnyDate.fromLocale(Locale.parse('en-AU')),
  'en-NZ': AnyDate.fromLocale(Locale.parse('en-NZ')),
  'en-CA': AnyDate.fromLocale(Locale.parse('en-CA')),
};

final allLocales = availableLocalesForDateFormatting;
final allLocaleParsers = Map.fromEntries(
  allLocales.map((e) => MapEntry(e, AnyDate.fromLocale(e))),
);

final englishLocales = allLocales.where((element) => element.startsWith('en'));
final englishParsers = {
  ...defaultParsers,
  ...Map.fromEntries(
    englishLocales.map((e) => MapEntry(e, AnyDate.fromLocale(e))),
  ),
};

final allParsers = {...englishParsers, ...allLocaleParsers};

final nonEnglishParsers = {...allLocaleParsers}
  ..removeWhere((key, value) => englishParsers.containsKey(key));

bool _hasInitialized = false;
Future<void> initializeDateFormatting() async {
  if (!_hasInitialized) {
    await intl.initializeDateFormatting();
    _hasInitialized = true;
  }
  ensureDateFormattingInitialized();
}

void ensureDateFormattingInitialized() {
  assert(
    _hasInitialized,
    'locale aware tests must initalize date formatting '
    'by calling initializeDateFormatting on main()',
  );
}

/// used to run tests on a wide range of dates
const exhaustiveTests = bool.fromEnvironment('exhaustive', defaultValue: true);
const hugeRange = bool.fromEnvironment('huge');

final now = DateTime.now();
const _span = 1;
final dateRange = DateTimeRange(
  start: DateTime(now.year - _span, 7),
  end: DateTime(now.year + _span - 1, 7),
);
const _span2 = 100;
final century = DateTimeRange(
  start: DateTime(now.year - _span2, 7),
  end: DateTime(now.year + _span2 - 1, 7),
);
const _span3 = 1000;
final millennium = DateTimeRange(
  start: DateTime(now.year - _span3, 7),
  end: DateTime(now.year + _span3 - 1, 7),
);
const _span4 = 40;
final closeToToday = DateTimeRange(
  start: DateTime(now.year, now.month - _span4),
  end: DateTime(now.year, now.month + _span4),
);

const _step = Duration(
  hours: 1,
  minutes: 13,
  seconds: 17,
  milliseconds: 23,
  microseconds: 29,
);
final manyDates = List<DateTime>.unmodifiable(millennium.every(_step));
Iterable<DateTime> getRandomDates([int? count]) sync* {
  const def = exhaustiveTests ? 1000 : 100;
  final limit = count ?? def;
  if (limit >= manyDates.length) {
    yield* manyDates;
    return;
  }

  final r = Random();
  final res = <DateTime>{};
  while (res.length < limit) {
    final d = manyDates[r.nextInt(manyDates.length)];
    final added = res.add(d);
    if (added) {
      yield d;
    }
  }
}

final singleDate = DateTime(2023, 1, 2, 3, 4, 5, 6, 7);

final allFormats = {
  ...otherFormats,
  ...mdyFormats,
  ...dmyFormats,
  ...ymdFormats,
};

final textMonthFormats = allFormats.where((element) => element.contains('MMM'));

const otherFormats = {
  'EEEE, MMMM d, y',
  'EEEE, MMMM d, y h:m:s.SS a',
  'EEEE, MMMM d, y H:m:s.SS',
  'EEEE, MMMM d, y h:m:s.S a',
  'EEEE, MMMM d, y H:m:s.S',
  'EEEE, MMMM d, y h:m:s a',
  'EEEE, MMMM d, y H:m:s',
  'EEEE, MMMM d, y h:m a',
  'EEEE, MMMM d, y H:m',
  'EEEE, MMMM d, y h a',
  'EEEE, MMMM d, y H',
  // TODO(gbassisp): allow madness (year guessing)
  // 'EEEE, MMMM d',
  // 'EEEE, MMMM',
};

const monthFirstFormats = {
  'yyyy.M.d h:m:s.SS a',
  'yyyy.M.d H:m:s.SS',
  'yyyy.M.d h:m:s.S a',
  'yyyy.M.d H:m:s.S',
  'yyyy.M.d h:m:s a',
  'yyyy.M.d H:m:s',
  'yyyy.M.d h:m a',
  'yyyy.M.d H:m',
  'yyyy.M.d h a',
  'yyyy.M.d H',
  'yyyy.M.d',
  // 'yyyy.M',
  // 'yyyy',
  'y.M.d h:m:s.SS a',
  'y.M.d H:m:s.SS',
  'y.M.d h:m:s.S a',
  'y.M.d H:m:s.S',
  'y.M.d h:m:s a',
  'y.M.d H:m:s',
  'y.M.d h:m a',
  'y.M.d H:m',
  'y.M.d h a',
  'y.M.d H',
  'y.M.d',
  // 'y.M',
  // 'y',
  'M.d.y h:m:s.SS a',
  'M.d.y H:m:s.SS',
  'M.d.y h:m:s.S a',
  'M.d.y H:m:s.S',
  'M.d.y h:m:s a',
  'M.d.y H:m:s',
  'M.d.y h:m a',
  'M.d.y H:m',
  'M.d.y h a',
  'M.d.y H',
  'M.d.y',
  // 'M.d',
  // 'M',
  'yyyy-MM-ddTHH:mm:ss',
  'MM/dd/yyyy HH:mm:ss',
  'yyyy.MM.dd HH:mm:ss',
  'yyyy MM dd HH:mm:ss',
  'yyyy-MM-ddTHH:mm',
  'MM/dd/yyyy HH:mm',
  'yyyy.MM.dd HH:mm',
  'yyyy MM dd HH:mm',
  'yyyy-MM-ddTHH:mm:ss.SSS',
  'MM/dd/yyyy HH:mm:ss.SSS',
  'yyyy.MM.dd HH:mm:ss.SSS',
  'yyyy MM dd HH:mm:ss.SSS',
  'yyyy-MM-ddTHH:mm:ssZ',
  'MM/dd/yyyy HH:mm:ss Z',
  'yyyy.MM.dd HH:mm:ss Z',
  'yyyy MM dd HH:mm:ss Z',
};

const monthFirstWithWeekday = {
  'EEEE, M/d/y',
  'EEEE, M/d/y h:m:s.SS a',
  'EEEE, M/d/y H:m:s.SS',
  'EEEE, M/d/y h:m:s.S a',
  'EEEE, M/d/y H:m:s.S',
  'EEEE, M/d/y h:m:s a',
  'EEEE, M/d/y H:m:s',
  'EEEE, M/d/y h:m a',
  'EEEE, M/d/y H:m',
  'EEEE, M/d/y h a',
  // 'EEEE, M/d',
  // 'EEEE, M',
  'EEEE, M/d/y H',
  'EEEE, y.M.d',
  'EEEE, y.M.d h:m:s.SS a',
  'EEEE, y.M.d H:m:s.SS',
};

const dayFirstFormats = {
  'd.M.y h:m:s.SS a',
  'd.M.y H:m:s.SS',
  'd.M.y h:m:s.S a',
  'd.M.y H:m:s.S',
  'd.M.y h:m:s a',
  'd.M.y H:m:s',
  'd.M.y h:m a',
  'd.M.y H:m',
  'd.M.y h a',
  'd.M.y',
  // TODO(gbassisp): re-enable this
  // 'd.M',
  // 'd',
  // 'h:m:s.SS a',
  // 'h:m:s.SS',
  // 'h:m:s.S a',
  // 'h:m:s.S',
  // 'h:m:s a',
  // 'h:m:s',
  // 'h:m a',
  // 'h:m',
  // 'h a',
  // 'h',
  'd.M.y H',

  'dd/MM/yyyy HH:mm:ss',
  'dd-MM-yyyy HH:mm:ss',
  'dd.MM.yyyy HH:mm:ss',
  'dd/MM/yyyy HH:mm',
  'dd-MM-yyyy HH:mm',
  'dd.MM.yyyy HH:mm',
  'dd/MM/yyyy HH:mm:ss.SSS',
  'dd-MM-yyyy HH:mm:ss.SSS',
  'dd.MM.yyyy HH:mm:ss.SSS',
  'dd/MM/yyyy HH:mm:ss Z',
  'dd-MM-yyyy HH:mm:ss Z',
  'dd.MM.yyyy HH:mm:ss Z',
  'dd MMM yyyy HH:mm:ss E',
  'dd MMM yyyy HH:mm:ss Z E',
  'dd MMM yyyy HH:mm:ss EEE',
  'EEEE, d.M.y H',
  'dd MMM yyyy HH:mm:ss Z EEE',
  'dd MMM yyyy HH:mm:ss',
  'dd MMM yyyy HH:mm:ss Z',
  'dd MMM yyyy HH:mm:ss.SSS',
  'dd MMM yyyy HH:mm',
  'dd MMM yyyy HH:mm Z',
};

const dayFirstWithWeekday = {
  'EEEE, d.M.y',
  'EEEE, d.M.y h:m:s.SS a',
  'EEEE, d.M.y H:m:s.SS',
  'EEEE, d.M.y h:m:s.S a',
  'EEEE, d.M.y H:m:s.S',
  'EEEE, d.M.y h:m:s a',
  'EEEE, d.M.y H:m:s',
  'EEEE, d.M.y h:m a',
  'EEEE, d.M.y H:m',
  'EEEE, d.M.y h a',
  'E, dd MMM yyyy HH:mm:ss',
  'E, dd MMM yyyy HH:mm:ss Z',
  'EEE, dd MMM yyyy HH:mm:ss',
  'EEE, dd MMM yyyy HH:mm:ss Z',
  // 'EEEE, d.M',
  // 'EEEE, d',
};

final _years = List.generate(5, (index) => 'y' * (index + 1)).toSet();
final _months = List.generate(2, (index) => 'M' * (index + 1)).toSet();
final _days = List.generate(2, (index) => 'd' * (index + 1)).toSet();
final _hours = List.generate(2, (index) => 'H' * (index + 1)).toSet();
final _minutes = List.generate(2, (index) => 'm' * (index + 1)).toSet();
final _seconds = List.generate(2, (index) => 's' * (index + 1)).toSet();
final _milliseconds = List.generate(6, (index) => 'S' * (index + 1)).toSet();

extension SwapExtension on String {
  /// we assume it's used to replace yyyy with dd or similar;
  ///
  /// hence we don't need to worry about complex cases, only simple ones
  String swap(String a, String b) {
    const unusedString = 'x';

    final countA = a.allMatches(this).length;
    final countB = b.allMatches(this).length;
    assert(countA > 0, 'no "$a" in "$this"');
    assert(countB > 0, 'no "$b" in "$this"');
    final pattern1 = RegExp('$a+');
    final pattern2 = RegExp('$b+');

    return replaceAll(pattern1, unusedString)
        .replaceAll(pattern2, a * countA)
        .replaceAll(unusedString, b * countB);
  }
}

Set<String> get dmyFormats {
  final set = ymdFormats;
  final res = <String>{};
  for (final f in set) {
    res.add(f.swap('y', 'd'));
  }
  return res;
}

Set<String> get mdyFormats {
  final set = dmyFormats;
  final res = <String>{};
  for (final f in set) {
    res.add(f.swap('d', 'M'));
  }
  return res;
}

Set<String> get ymdFormats {
  final set = <String>{};
  for (final y in _years) {
    for (final m in _months) {
      for (final d in _days) {
        set.add('$y/$m/$d');
      }
    }
  }

  final timeComponents = <String>{};
  for (final f in set) {
    timeComponents
      ..addAll(hm.map((e) => '$f $e'))
      ..addAll(hms.map((e) => '$f $e'))
      ..addAll(hmsS.map((e) => '$f $e'));
  }
  final hma = <String>{}
    ..addAll(timeComponents.map((e) => '${e.replaceAll('H', 'h')} a'));

  return set
    ..addAll(timeComponents)
    ..addAll(hma);
}

Set<String> get hm {
  final set = <String>{};
  for (final h in _hours) {
    for (final m in _minutes) {
      set.add('$h:$m');
    }
  }
  return set;
}

Set<String> get hms {
  final set = hm;
  for (final s in _seconds) {
    set.addAll(hm.map((e) => '$e:$s'));
  }
  return set;
}

Set<String> get hmsS {
  final set = hms;
  for (final ms in _milliseconds) {
    set.addAll(hms.map((e) => e.endsWith('s') ? '$e.$ms' : e));
  }
  return set;
}

extension DateRangeExtension on DateTimeRange {
  Iterable<DateTime> every(Duration step) sync* {
    var current = start;
    while (current.isBefore(end)) {
      yield current;
      current = current.add(step);
    }
  }
}
