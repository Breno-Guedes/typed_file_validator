import '../signatures/file_type.dart';
import 'errors.dart';

sealed class FileValidationResult {
  const FileValidationResult();

  bool get isValid => this is ValidFile;
}

final class ValidFile extends FileValidationResult {
  const ValidFile({required this.fileType, required this.size});

  final FileType fileType;
  final int size;
}

final class InvalidFile extends FileValidationResult {
  const InvalidFile(this.error);

  final FileValidationError error;
}
