import 'file_type.dart';
import 'magic_signature.dart';

class SignatureRegistry {
  const SignatureRegistry._();

  static const List<FileSignature> all = [
    FileSignature(
      type: FileType.jpeg,
      signatures: [
        MagicSignature(offset: 0, bytes: [0xFF, 0xD8, 0xFF]),
      ],
    ),
    FileSignature(
      type: FileType.png,
      signatures: [
        MagicSignature(
          offset: 0,
          bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
        ),
      ],
    ),
    FileSignature(
      type: FileType.pdf,
      signatures: [
        MagicSignature(offset: 0, bytes: [0x25, 0x50, 0x44, 0x46, 0x2D]),
      ],
    ),
  ];

  static FileType? detect(List<int> header) {
    for (final signature in all) {
      if (signature.matches(header)) return signature.type;
    }
    return null;
  }

  static int get maxSignatureLength => all
      .expand((signature) => signature.signatures)
      .map((signature) => signature.offset + signature.bytes.length)
      .fold(0, (max, length) => length > max ? length : max);
}
