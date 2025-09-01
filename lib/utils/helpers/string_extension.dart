extension StringCasingExtension on String {
  /// Capitalizes only the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Capitalizes the first letter of each word in the string
  String capitalizeEachWord() {
    return split(" ")
        .map((word) => word.capitalize())
        .join(" ");
  }
}
