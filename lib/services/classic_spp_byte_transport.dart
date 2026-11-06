/// Protocol-independent port for a future approved Android Classic SPP driver.
/// This is NOT a Bluetooth implementation, authorization or device connection.
/// No production caller uses this preparation seam; no lifecycle wire schema is
/// selected here. Implementations must not retry hardware commands implicitly.
abstract interface class ClassicSppByteTransport {
  Stream<List<int>> get incomingBytes;
  Future<void> writeBytes(List<int> bytes);
  Future<void> close();
}
