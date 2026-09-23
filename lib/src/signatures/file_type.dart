enum FileType {
  jpeg(extension: 'jpg', mimeType: 'image/jpeg', label: 'JPEG'),
  png(extension: 'png', mimeType: 'image/png', label: 'PNG'),
  pdf(extension: 'pdf', mimeType: 'application/pdf', label: 'PDF');

  const FileType({
    required this.extension,
    required this.mimeType,
    required this.label,
  });

  final String extension;
  final String mimeType;
  final String label;

  static FileType? fromExtension(String value) {
    final normalized = value.toLowerCase().replaceFirst('.', '');
    for (final type in values) {
      if (type.extension == normalized ||
          (type == FileType.jpeg && normalized == 'jpeg')) {
        return type;
      }
    }
    return null;
  }
}
