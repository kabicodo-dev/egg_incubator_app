enum FarmerNoticeTone { information, warning, error, success }

/// An already-classified presentation notice, not a fault detector or protocol.
class FarmerNotice {
  const FarmerNotice({
    required this.title,
    required this.message,
    required this.tone,
  });
  final String title;
  final String message;
  final FarmerNoticeTone tone;
}
