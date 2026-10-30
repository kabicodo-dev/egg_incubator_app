/// A presentation snapshot supplied by an approved original-Start/time adapter.
/// It does not parse wire fields, promote cloud Active/ACKs to Start, or trust
/// the phone clock by default. Inputs must be substantiated UTC instants.
class ConfirmedIncubationTime {
  const ConfirmedIncubationTime._(this.startUtc, this.elapsed);

  factory ConfirmedIncubationTime.fromVerifiedInstants({
    required DateTime? confirmedOriginalStartUtc,
    required DateTime? trustworthyNowUtc,
  }) {
    final start = confirmedOriginalStartUtc;
    final now = trustworthyNowUtc;
    if (start == null || !start.isUtc) {
      return const ConfirmedIncubationTime._(null, null);
    }
    if (now == null || !now.isUtc || now.isBefore(start)) {
      return ConfirmedIncubationTime._(start, null);
    }
    return ConfirmedIncubationTime._(start, now.difference(start));
  }

  final DateTime? startUtc;
  final Duration? elapsed;

  // Never cap Day N at a species duration or infer Completed from it.
  int? get day => elapsed == null ? null : elapsed!.inSeconds ~/ 86400 + 1;

  String get dayLabel => startUtc == null
      ? 'Waiting for confirmed start'
      : day == null
      ? 'Waiting for trustworthy elapsed time'
      : 'Day $day';

  String? get manilaStartLabel =>
      startUtc == null ? null : formatProjectManilaInstant(startUtc!);
}

/// Modern project dates: Asia/Manila is UTC+08:00 (no DST).
/// This is display-only, never a midnight/day-counter input. Explicit UTC input
/// avoids dependence on the Android/desktop's selected local timezone.
String formatProjectManilaInstant(DateTime utc) {
  if (!utc.isUtc) throw ArgumentError('An explicit UTC instant is required');
  final display = utc.add(const Duration(hours: 8));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${display.year}-${two(display.month)}-${two(display.day)} '
      '${two(display.hour)}:${two(display.minute)}:${two(display.second)} '
      'Asia/Manila (UTC+08:00)';
}
