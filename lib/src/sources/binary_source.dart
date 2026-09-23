abstract interface class BinarySource {
  int? get length;

  Future<List<int>> readHeader(int maxBytes);
}
