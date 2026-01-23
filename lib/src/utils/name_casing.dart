extension NameCasingExtension on String {
  String toCapitalized() {
    return length > 0
      ? '${this[0].toUpperCase()}${substring(1)}'
      : '';
  }

  String toHumanReadable() {
    return replaceAllMapped(
      RegExp(r'^([a-z])|[A-Z]'),
      (Match m) => m[1] == null ? ' ${m[0]}' : m[1]!.toUpperCase()
    );
  }
}