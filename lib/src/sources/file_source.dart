import 'dart:io';

import 'binary_source.dart';

final class FileBinarySource implements BinarySource {
  FileBinarySource(this.file);

  final File file;

  @override
  int get length => file.lengthSync();

  @override
  Future<List<int>> readHeader(int maxBytes) async {
    final handle = await file.open();
    try {
      return await handle.read(maxBytes);
    } finally {
      await handle.close();
    }
  }

  Future<int> resolveLength() => file.length();
}
