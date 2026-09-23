import 'binary_source.dart';

final class StreamBinarySource implements BinarySource {
  StreamBinarySource(Stream<List<int>> stream) : _stream = stream;

  final Stream<List<int>> _stream;

  @override
  int? get length => null;

  @override
  Future<List<int>> readHeader(int maxBytes) async {
    final header = <int>[];
    await for (final chunk in _stream) {
      final remaining = maxBytes - header.length;
      if (remaining <= 0) break;
      header.addAll(chunk.take(remaining));
      if (header.length >= maxBytes) break;
    }
    return List<int>.unmodifiable(header);
  }

  Future<StreamReadResult> readHeaderAndLength(int maxBytes) async {
    final header = <int>[];
    var totalLength = 0;
    await for (final chunk in _stream) {
      totalLength += chunk.length;
      final remaining = maxBytes - header.length;
      if (remaining > 0) header.addAll(chunk.take(remaining));
    }
    return StreamReadResult(
      header: List<int>.unmodifiable(header),
      length: totalLength,
    );
  }
}

final class StreamReadResult {
  const StreamReadResult({required this.header, required this.length});

  final List<int> header;
  final int length;
}
