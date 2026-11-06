class BatchData {
  final int id;
  final String batchNumber;
  final String species;
  final String startDate;
  final String endDate;
  final int eggsTotal;
  final int eggsHatched;
  final bool hasRecordedHatchCount;
  final String temperature;
  final String status;
  final bool isSuccess;
  final String? appStartDate;

  const BatchData({
    required this.id,
    required this.batchNumber,
    required this.species,
    required this.startDate,
    required this.endDate,
    required this.eggsTotal,
    required this.eggsHatched,
    this.hasRecordedHatchCount = true,
    required this.temperature,
    required this.status,
    required this.isSuccess,
    this.appStartDate,
  });

  factory BatchData.fromSession(Map<String, dynamic> session) {
    final id = session['id'] as int;
    final species = session['egg_type'] as String? ?? '';
    final startDate = session['start_date'] as String? ?? '';
    final endDate = session['end_date'] as String? ?? '';
    final rawQuantity = session['egg_quantity'];
    final eggQty = rawQuantity is int ? rawQuantity : 0;
    final rawHatched = session['eggs_hatched'];
    final hatched = rawHatched is int ? rawHatched : 0;
    final temp = session['temperature'];
    final tempStr = temp != null ? '$temp\u00B0C' : 'Unavailable';
    final status = session['status'] as String? ?? 'Active';
    final isCompleted = status == 'Completed';
    final formattedStart = startDate.length >= 10
        ? startDate.substring(0, 10)
        : startDate;
    final formattedEnd = endDate.length >= 10
        ? endDate.substring(0, 10)
        : endDate;
    return BatchData(
      id: id,
      batchNumber: 'Batch #$id',
      species: species,
      startDate: formattedStart,
      endDate: formattedEnd,
      eggsTotal: eggQty,
      eggsHatched: hatched,
      hasRecordedHatchCount: rawHatched is int,
      temperature: tempStr,
      status: status,
      isSuccess: isCompleted && hatched > 0,
      appStartDate: startDate,
    );
  }
}
