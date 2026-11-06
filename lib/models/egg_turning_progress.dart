/// Presentation input only, not a Bluetooth message or persistence schema.
/// An approved adapter must scope both counts to the same daily window and
/// batch. Do not derive completed turns from elapsed time or app launch.
class EggTurningProgress {
  const EggTurningProgress({
    this.completedTurns,
    this.plannedTurns,
    this.interval,
    this.untilNextTurn,
  });

  final int? completedTurns;
  final int? plannedTurns;
  final Duration? interval;
  final Duration? untilNextTurn;

  bool get hasValidCounts =>
      completedTurns != null &&
      plannedTurns != null &&
      completedTurns! >= 0 &&
      plannedTurns! > 0 &&
      completedTurns! <= plannedTurns!;

  String get countLabel =>
      hasValidCounts ? '$completedTurns/$plannedTurns' : '—';

  String? get intervalLabel {
    final seconds = interval?.inSeconds;
    if (seconds == null || seconds <= 0) return null;
    if (seconds % 3600 == 0) {
      final hours = seconds ~/ 3600;
      return 'Every $hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    if (seconds % 60 == 0) return 'Every ${seconds ~/ 60} minutes';
    return 'Every $seconds seconds';
  }

  String? get nextTurnLabel {
    final remaining = untilNextTurn;
    if (!hasValidCounts || remaining == null || remaining.isNegative) {
      return null;
    }
    if (remaining.inSeconds == 0) return 'Next turn due';
    final minutes = (remaining.inSeconds / 60).ceil();
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return hours == 0 ? 'Next in $rest min' : 'Next in $hours h $rest min';
  }
}
