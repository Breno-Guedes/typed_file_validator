import 'dart:typed_data';

import 'binary_source.dart';

final class MemoryBinarySource implements BinarySource {
  MemoryBinarySource(Uint8List bytes) : _bytes = bytes;

  final Uint8List _bytes;

  @override
  int get length => _bytes.length;

  @override
  Future<List<int>> readHeader(int maxBytes) async {
    final end = _bytes.length < maxBytes ? _bytes.length : maxBytes;
    return List<int>.unmodifiable(_bytes.sublist(0, end));
  }
}
