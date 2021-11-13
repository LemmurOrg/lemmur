import 'package:timeago/timeago.dart';

class PlShortMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'teraz';
  @override
  String aboutAMinute(int minutes) => '1min';
  @override
  String minutes(int minutes) => '${minutes}min';
  @override
  String aboutAnHour(int minutes) => '~1godz';
  @override
  String hours(int hours) => '${hours}godz';
  @override
  String aDay(int hours) => '~1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '~1mies';
  @override
  String months(int months) => '${months}mies';
  @override
  String aboutAYear(int year) => '~1rok';
  @override
  String years(int years) => '$years lat';
  @override
  String wordSeparator() => ' ';
}
