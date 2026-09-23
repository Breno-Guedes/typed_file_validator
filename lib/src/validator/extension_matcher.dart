import '../signatures/file_type.dart';

class ExtensionMatcher {
  const ExtensionMatcher._();

  static bool matches(String? declaredName, FileType detectedType) {
    if (declaredName == null || declaredName.trim().isEmpty) return true;
    final value = declaredName.split(RegExp(r'[\\/]')).last;
    final dot = value.lastIndexOf('.');
    if (dot < 0 || dot == value.length - 1) return false;
    final extension = value.substring(dot + 1).toLowerCase();
    return extension == detectedType.extension ||
        (detectedType == FileType.jpeg && extension == 'jpeg');
  }
}
