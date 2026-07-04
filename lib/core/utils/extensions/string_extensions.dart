extension StringExtension on String {
  bool get isNotNullOrEmpty => trim().isNotEmpty;

  String get capitalize {
    if (isEmpty) {
      return this;
    }

    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) {
      return this;
    }

    return '${substring(0, maxLength)}$suffix';
  }
}

extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
