import 'dart:io';

import 'package:typed_file_validator/typed_file_validator.dart';

Future<void> validateUpload(HttpRequest request, String originalName) async {
  final result = await FileValidator()
      .allow([FileType.jpeg, FileType.png, FileType.pdf])
      .maxSizeInMB(25)
      .validateStream(request, fileName: originalName);

  switch (result) {
    case ValidFile(:final fileType):
      stdout.writeln('Accepted upload as ${fileType.mimeType}.');
    case InvalidFile(:final error):
      stdout.writeln('Rejected upload: ${error.message}');
  }
}

Future<void> main() async {
  stdout.writeln('Use validateUpload with an HttpRequest in a Dart server.');
}
