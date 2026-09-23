import 'file_type.dart';

class MagicSignature {
  const MagicSignature({required this.offset, required this.bytes});

  final int offset;
  final List<int> bytes;

  bool matches(List<int> header) {
    if (header.length < offset + bytes.length) return false;
    for (var index = 0; index < bytes.length; index++) {
      if (header[offset + index] != bytes[index]) return false;
    }
    return true;
  }
}

class FileSignature {
  const FileSignature({required this.type, required this.signatures});

  final FileType type;
  final List<MagicSignature> signatures;

  bool matches(List<int> header) =>
      signatures.every((signature) => signature.matches(header));
}
