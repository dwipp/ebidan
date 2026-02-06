extension CapitalizeEachWord on String {
  String capitalizeWords() {
    return split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }
}
