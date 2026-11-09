class LocalizationFile {
  LocalizationFile({
    required this.name,
    required this.data,
    required Set<String> allKeyPaths,
  })  : _usedKeyPaths = <String>{},
        _allKeyPaths = allKeyPaths;

  final String name;
  final Map<String, dynamic> data;
  final Set<String> _usedKeyPaths;
  final Set<String> _allKeyPaths;

  Set<String> get unusedKeys => _allKeyPaths.difference(_usedKeyPaths);

  void markKeyPathUsed(String keyPath) => _usedKeyPaths.add(keyPath);

  dynamic getLastValue(String keyPath) {
    final keys = keyPath.split('.');
    Map<String, dynamic>? currentData = data;

    for (final key in keys.sublist(0, keys.length - 1)) {
      currentData = currentData?[key] as Map<String, dynamic>?;
      if (currentData == null) return null;
    }

    return currentData![keys.last];
  }
}
