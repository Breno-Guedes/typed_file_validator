sealed class FileValidationError {
  const FileValidationError({required this.message});

  final String message;

  @override
  String toString() => message;
}

final class FileTooLargeError extends FileValidationError {
  const FileTooLargeError({required this.actualSize, required this.maxSize})
      : super(message: 'File size exceeds the configured limit.');

  final int actualSize;
  final int maxSize;
}

final class ExtensionSpoofingError extends FileValidationError {
  const ExtensionSpoofingError({
    required this.declaredExtension,
    required this.detectedType,
  }) : super(
            message:
                'Declared extension does not match the detected file type.');

  final String declaredExtension;
  final String detectedType;
}

final class UnrecognizedFileType extends FileValidationError {
  const UnrecognizedFileType()
      : super(message: 'The file type could not be recognized.');
}

final class DisallowedFileType extends FileValidationError {
  const DisallowedFileType({required this.fileType})
      : super(message: 'The detected file type is not allowed.');

  final String fileType;
}

final class FileReadError extends FileValidationError {
  const FileReadError({required this.cause})
      : super(message: 'The file could not be read.');

  final Object cause;
}
