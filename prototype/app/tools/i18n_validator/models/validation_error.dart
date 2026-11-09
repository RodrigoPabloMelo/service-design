class ValidationError {
  ValidationError({
    required this.keyPath,
    required this.codeFileName,
    required this.localizationFileName,
  });

  final String keyPath;
  final String codeFileName;
  final String localizationFileName;
}
