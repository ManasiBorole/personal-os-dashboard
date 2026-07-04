import 'package:personal_os_dashboard/core/constants/app_constants.dart';

/// Input validation helpers for forms and use cases.
abstract final class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(
    String? value, {
    int minLength = AppConstants.minPasswordLength,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password must be at most ${AppConstants.maxPasswordLength} characters';
    }

    return null;
  }

  static String? strongPassword(String? value) {
    final baseValidation = password(value);
    if (baseValidation != null) {
      return baseValidation;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value!);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecial) {
      return 'Password must include uppercase, lowercase, number, and special character';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? minLength(
    String? value,
    int minLength, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  static String? maxLength(
    String? value,
    int maxLength, {
    String fieldName = 'This field',
  }) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-().]{7,20}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  static String? url(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL';
    }

    return null;
  }

  static String? numeric(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'This field'}) {
    final numericValidation = numeric(value, fieldName: fieldName);
    if (numericValidation != null) {
      return numericValidation;
    }

    if (double.parse(value!.trim()) <= 0) {
      return '$fieldName must be greater than zero';
    }

    return null;
  }

  static String? range(
    String? value, {
    required num min,
    required num max,
    String fieldName = 'This field',
  }) {
    final numericValidation = numeric(value, fieldName: fieldName);
    if (numericValidation != null) {
      return numericValidation;
    }

    final parsed = double.parse(value!.trim());

    if (parsed < min || parsed > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }

  /// Combines multiple validators; returns the first error found.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
