extension DateTimeExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  String toFormattedString() {
    if (isToday()) return 'Hari ini';
    if (isYesterday()) return 'Kemarin';

    final now = DateTime.now();
    final difference = now.difference(this).inDays;

    if (difference < 7) return '$difference hari yang lalu';

    final months = (difference / 30).floor();
    if (months < 12) return '$months bulan yang lalu';

    final years = (difference / 365).floor();
    return '$years tahun yang lalu';
  }
}

extension StringExtensions on String {
  bool isValidEmail() {
    final pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(this);
  }

  bool isValidPhone() {
    final pattern = r'^(\+62|0)[0-9]{9,12}$';
    return RegExp(pattern).hasMatch(this);
  }

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String capitalizeEachWord() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension DoubleExtensions on double {
  bool isZero() => this == 0;

  bool isNegative() => this < 0;

  bool isPositive() => this > 0;

  String toStringWithPrecision(int precision) {
    return toStringAsFixed(precision);
  }
}
