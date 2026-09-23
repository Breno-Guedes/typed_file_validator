import 'dart:io';

import 'package:typed_file_validator/typed_file_validator.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln('Usage: dart run example/example.dart <path>');
    exitCode = 64;
    return;
  }

  final path = arguments.first;
  final file = File(path);
  final result = await FileValidator()
      .maxSizeInMB(10)
      .validate(FileBinarySource(file), fileName: path);

  switch (result) {
    case ValidFile(:final fileType, :final size):
      stdout.writeln('Valid ${fileType.label} file, size: $size bytes.');
    case InvalidFile(:final error):
      stderr.writeln('Invalid file: ${error.message}');
      exitCode = 1;
  }
}
