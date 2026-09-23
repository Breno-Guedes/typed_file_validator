# typed_file_validator

`typed_file_validator` is a dependency-free Dart 3 library for validating uploaded files by their binary signature. It detects JPEG, PNG, and PDF files from magic bytes instead of trusting a user-controlled filename or MIME header.

## Why use it

File extensions and request headers can be forged. This package inspects the beginning of the content and compares it with known signatures. Header inspection uses a bounded buffer, so validation does not load an entire file into memory.

The package is suitable for Dart Frog, Shelf, Serverpod, Flutter, and command-line applications. It has no runtime dependencies outside the Dart SDK.

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  typed_file_validator: ^0.1.0-beta.1
```

Then run `dart pub get`.

## Quick start

```dart
import 'dart:typed_data';
import 'package:typed_file_validator/typed_file_validator.dart';

Future<void> main() async {
  final validator = FileValidator()
      .allow([FileType.jpeg, FileType.png])
      .maxSizeInMB(10)
      .checkExtensionSpoofing(true);

  final result = await validator.validateBytes(
    Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
    fileName: 'avatar.png',
  );

  switch (result) {
    case ValidFile(:final fileType, :final size):
      print('Accepted ${fileType.mimeType}; $size bytes.');
    case InvalidFile(:final error):
      print('Rejected: ${error.message}');
  }
}
```

## Sources

`MemoryBinarySource` validates a `Uint8List`, `FileBinarySource` reads a header from a `dart:io` file, and `StreamBinarySource` reads only the bounded header from a stream. All sources implement `BinarySource`, so applications can provide their own source abstraction.

```dart
final result = await FileValidator().validate(
  FileBinarySource(File('/tmp/upload.pdf')),
  fileName: 'upload.pdf',
);

final streamResult = await FileValidator().validateStream(
  request,
  fileName: 'upload.pdf',
);
```

For stream sources, the length is not known unless the application supplies it through a custom source. Consequently, a stream result reports the inspected header length. Enforce request or content-length limits at the HTTP boundary when a stream length is unavailable.

## Supported types

| Type | Extensions | MIME type | Signature |
|---|---|---|---|
| JPEG | `.jpg`, `.jpeg` | `image/jpeg` | `FF D8 FF` |
| PNG | `.png` | `image/png` | `89 50 4E 47 0D 0A 1A 0A` |
| PDF | `.pdf` | `application/pdf` | `%PDF-` |

## Results and errors

A successful validation returns `ValidFile`, including the detected `FileType` and known size. A failed validation returns `InvalidFile` with one of `FileTooLargeError`, `ExtensionSpoofingError`, `UnrecognizedFileType`, `DisallowedFileType`, or `FileReadError`.

## Security notes

Magic-byte validation identifies the format indicated by the beginning of a file; it is not a full parser or malware scanner. Continue to apply authentication, authorization, storage isolation, quotas, antivirus scanning, and safe content-disposition policies appropriate to the application.

## Development

Run the following commands from the package root:

```text
dart pub get
dart format .
dart analyze
dart test
```

## License

This package is distributed under the MIT License. See [LICENSE](LICENSE).
