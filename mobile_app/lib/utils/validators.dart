class Validators {
  static String? required(String? value, {String? error}) {
    if (value == null || value.trim().isEmpty) {
      return error ?? 'This field is required';
    }
    return null;
  }

  static String? identity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Identity is required';
    }
    // Allow either email format OR username code format (3+ characters)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value) && value.trim().length < 3) {
      return 'Please enter a valid email or username code';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Value'} is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    final numError = number(value, fieldName: fieldName);
    if (numError != null) return numError;

    final val = double.parse(value!);
    if (val <= 0) {
      return '${fieldName ?? 'Value'} must be greater than zero';
    }
    return null;
  }
}
