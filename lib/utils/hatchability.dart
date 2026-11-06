String historicalHatchability(int eggsSet, int hatched, bool recorded) {
  if (!recorded || eggsSet <= 0 || hatched < 0 || hatched > eggsSet) {
    return 'Unavailable';
  }
  return '${(hatched / eggsSet * 100).toStringAsFixed(1)}%';
}
