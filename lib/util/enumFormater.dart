class enumFormater {
  String formatWithSpace(String name) {
    return name.replaceAllMapped(
        RegExp(r'(?<=[a-z])[A-Z]'), (match) => ' ${match.group(0)}');
  }
}
