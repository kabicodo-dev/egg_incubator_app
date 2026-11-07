/// A saved app timestamp is scheduling metadata, never proof of physical Start.
/// Date-only, timezone-less, malformed or future values stay unavailable.
class AppDerivedSchedule {
  const AppDerivedSchedule._(this.day);

  factory AppDerivedSchedule.fromStoredStart(Object? value, DateTime now) {
    if (value is! String) return const AppDerivedSchedule._(null);
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,6})?(Z|[+-]\d{2}:\d{2})$',
    ).firstMatch(value);
    if (match == null) return const AppDerivedSchedule._(null);
    final parts = [for (var i = 1; i <= 6; i++) int.parse(match.group(i)!)];
    final calendar = DateTime.utc(parts[0], parts[1], parts[2]);
    if (calendar.year != parts[0] ||
        calendar.month != parts[1] ||
        calendar.day != parts[2] ||
        parts[3] > 23 ||
        parts[4] > 59 ||
        parts[5] > 59) {
      return const AppDerivedSchedule._(null);
    }
    final zone = match.group(7)!;
    if (zone != 'Z' &&
        (int.parse(zone.substring(1, 3)) > 23 ||
            int.parse(zone.substring(4, 6)) > 59)) {
      return const AppDerivedSchedule._(null);
    }
    final start = DateTime.tryParse(value);
    if (start == null || start.isAfter(now)) {
      return const AppDerivedSchedule._(null);
    }
    return AppDerivedSchedule._(
      now.toUtc().difference(start).inSeconds ~/ 86400 + 1,
    );
  }

  final int? day;
  String get label =>
      day == null ? 'Schedule unavailable' : 'App-derived · Day $day';
  static const limitation =
      'Based only on the saved app start date; not confirmed physical Start, '
      'Running, turning, lockdown or hatch completion.';
}
