/// String Extension for Capitalization
extension StringCasingExtension on String {
  /// Capitalizes only the first letter of the string
  String capitalizeFirst() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalizes each word in the string (e.g., "john doe" -> "John Doe")
  String capitalizeEachWord() {
    return split(' ')
        .map((word) => word.capitalizeFirst())
        .join(' ');
  }
}