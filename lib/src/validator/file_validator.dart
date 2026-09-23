import 'dart:typed_data';

import '../core/errors.dart';
import '../core/result.dart';
import '../signatures/file_type.dart';
import '../signatures/registry.dart';
import '../sources/binary_source.dart';
import '../sources/memory_source.dart';
import '../sources/stream_source.dart';
import 'extension_matcher.dart';

class FileValidator {
  FileValidator._({
    required Set<FileType> allowedTypes,
    required int? maximumSize,
    required bool checkExtensionSpoofing,
  })  : _allowedTypes = Set.unmodifiable(allowedTypes),
        _maximumSize = maximumSize,
        _checkExtensionSpoofing = checkExtensionSpoofing;

  factory FileValidator() => FileValidator._(
        allowedTypes: FileType.values.toSet(),
        maximumSize: null,
        checkExtensionSpoofing: true,
      );

  final Set<FileType> _allowedTypes;
  final int? _maximumSize;
  final bool _checkExtensionSpoofing;

  FileValidator allow(Iterable<FileType> types) => FileValidator._(
        allowedTypes: types.toSet(),
        maximumSize: _maximumSize,
        checkExtensionSpoofing: _checkExtensionSpoofing,
      );

  FileValidator maxSizeInMB(num megabytes) {
    if (megabytes < 0) throw ArgumentError.value(megabytes, 'megabytes');
    return maxSizeBytes((megabytes * 1024 * 1024).round());
  }

  FileValidator maxSizeBytes(int bytes) {
    if (bytes < 0) throw ArgumentError.value(bytes, 'bytes');
    return FileValidator._(
      allowedTypes: _allowedTypes,
      maximumSize: bytes,
      checkExtensionSpoofing: _checkExtensionSpoofing,
    );
  }

  FileValidator checkExtensionSpoofing(bool enabled) => FileValidator._(
        allowedTypes: _allowedTypes,
        maximumSize: _maximumSize,
        checkExtensionSpoofing: enabled,
      );

  Future<FileValidationResult> validate(
    BinarySource source, {
    String? fileName,
  }) async {
    try {
      final size = source.length;
      if (size != null && _maximumSize != null && size > _maximumSize!) {
        return InvalidFile(
            FileTooLargeError(actualSize: size, maxSize: _maximumSize!));
      }
      final header =
          await source.readHeader(SignatureRegistry.maxSignatureLength);
      return _evaluate(header, size, fileName);
    } catch (error) {
      return InvalidFile(FileReadError(cause: error));
    }
  }

  Future<FileValidationResult> validateBytes(
    Uint8List bytes, {
    String? fileName,
  }) =>
      validate(MemoryBinarySource(bytes), fileName: fileName);

  Future<FileValidationResult> validateStream(
    Stream<List<int>> stream, {
    String? fileName,
  }) async {
    try {
      final source = StreamBinarySource(stream);
      final read = await source
          .readHeaderAndLength(SignatureRegistry.maxSignatureLength);
      if (_maximumSize != null && read.length > _maximumSize!) {
        return InvalidFile(
          FileTooLargeError(actualSize: read.length, maxSize: _maximumSize!),
        );
      }
      return _evaluate(read.header, read.length, fileName);
    } catch (error) {
      return InvalidFile(FileReadError(cause: error));
    }
  }

  FileValidationResult _evaluate(
      List<int> header, int? size, String? fileName) {
    final detected = SignatureRegistry.detect(header);
    if (detected == null) return const InvalidFile(UnrecognizedFileType());
    if (!_allowedTypes.contains(detected)) {
      return InvalidFile(DisallowedFileType(fileType: detected.label));
    }
    if (_checkExtensionSpoofing &&
        !ExtensionMatcher.matches(fileName, detected)) {
      return InvalidFile(ExtensionSpoofingError(
        declaredExtension: fileName ?? '',
        detectedType: detected.label,
      ));
    }
    return ValidFile(fileType: detected, size: size ?? header.length);
  }
}
