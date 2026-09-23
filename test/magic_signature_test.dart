import 'package:test/test.dart';
import 'package:typed_file_validator/typed_file_validator.dart';

void main() {
  test('matches bytes at the configured offset', () {
    const signature = MagicSignature(offset: 2, bytes: [1, 2, 3]);

    expect(signature.matches([9, 9, 1, 2, 3]), isTrue);
    expect(signature.matches([9, 9, 1, 2, 4]), isFalse);
    expect(signature.matches([9, 9]), isFalse);
  });

  test('detects supported file types', () {
    expect(SignatureRegistry.detect([0xFF, 0xD8, 0xFF]), FileType.jpeg);
    expect(
        SignatureRegistry.detect([0x25, 0x50, 0x44, 0x46, 0x2D]), FileType.pdf);
    expect(SignatureRegistry.detect([0, 1, 2]), isNull);
  });
}
