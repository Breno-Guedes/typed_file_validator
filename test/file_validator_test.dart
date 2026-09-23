import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:typed_file_validator/typed_file_validator.dart';

void main() {
  final validator = FileValidator();

  test('validates a PNG and matches its extension', () async {
    final result = await validator.validateBytes(
      Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
      fileName: 'image.png',
    );

    expect(result, isA<ValidFile>());
    expect((result as ValidFile).fileType, FileType.png);
  });

  test('rejects extension spoofing', () async {
    final result = await validator.validateBytes(
      Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]),
      fileName: 'document.png',
    );

    expect(result, isA<InvalidFile>());
    expect((result as InvalidFile).error, isA<ExtensionSpoofingError>());
  });

  test('rejects a disallowed type', () async {
    final result = await validator.allow([FileType.pdf]).validateBytes(
      Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
    );

    expect(result, isA<InvalidFile>());
    expect((result as InvalidFile).error, isA<DisallowedFileType>());
  });

  test('rejects a file larger than the configured limit', () async {
    final result = await validator.maxSizeBytes(4).validateBytes(
          Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]),
        );

    expect(result, isA<InvalidFile>());
    expect((result as InvalidFile).error, isA<FileTooLargeError>());
  });

  test('validates a stream using only its header', () async {
    final result = await validator.validateStream(
      Stream<List<int>>.fromIterable([
        [0xFF, 0xD8],
        [0xFF, 0xE0, 0x00, 0x01],
      ]),
      fileName: 'photo.jpeg',
    );

    expect(result, isA<ValidFile>());
    expect((result as ValidFile).fileType, FileType.jpeg);
  });
}
