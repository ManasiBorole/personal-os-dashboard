/// String manipulation helpers.
abstract final class StringUtils {
  static String initials(String value, {int maxLength = 2}) {
    final parts = value.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return '';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return parts
        .take(maxLength)
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join();
  }

  static String slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  static String? nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }
}
