import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:typed_file_validator/typed_file_validator.dart';

void main() {
  test('memory source returns at most the requested header length', () async {
    final source = MemoryBinarySource(Uint8List.fromList([1, 2, 3, 4]));

    expect(await source.readHeader(2), [1, 2]);
    expect(source.length, 4);
  });

  test('stream source reads only the requested header length', () async {
    final source = StreamBinarySource(
      Stream<List<int>>.fromIterable([
        [1, 2],
        [3, 4],
      ]),
    );

    expect(await source.readHeader(3), [1, 2, 3]);
    expect(source.length, isNull);
  });

  test('file source reads a header and resolves its length', () async {
    final file =
        File('${Directory.systemTemp.path}/typed_file_validator_test.bin');
    await file.writeAsBytes([1, 2, 3, 4]);
    addTearDown(() => file.delete());
    final source = FileBinarySource(file);

    expect(await source.readHeader(2), [1, 2]);
    expect(await source.resolveLength(), 4);
  });
}
