import 'package:intl/intl.dart';

class Formatters {
  static const String _locale = 'id_ID';

  static String formatCurrency(double amount, {String symbol = 'Rp'}) {
    try {
      final formatter = NumberFormat.currency(
        locale: _locale,
        symbol: symbol,
        decimalDigits: 0,
      );
      return formatter.format(amount);
    } catch (e) {
      return '$symbol$amount';
    }
  }

  static String formatDate(DateTime date) {
    try {
      final formatter = DateFormat('dd MMM yyyy', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString().split(' ')[0];
    }
  }

  static String formatDateTime(DateTime dateTime) {
    try {
      final formatter = DateFormat('dd MMM yyyy HH:mm', _locale);
      return formatter.format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  static String formatTime(DateTime dateTime) {
    try {
      final formatter = DateFormat('HH:mm', _locale);
      return formatter.format(dateTime);
    } catch (e) {
      return dateTime.toString().split(' ')[1];
    }
  }

  static String formatMonth(DateTime date) {
    try {
      final formatter = DateFormat('MMMM yyyy', _locale);
      return formatter.format(date);
    } catch (e) {
      return '${date.month}/${date.year}';
    }
  }

  static String formatMonthShort(DateTime date) {
    try {
      final formatter = DateFormat('MMM yy', _locale);
      return formatter.format(date);
    } catch (e) {
      return '${date.month}/${date.year}';
    }
  }

  static String formatPercentage(
    double value, {
    int decimalPlaces = 1,
    bool includeSymbol = true,
  }) {
    final formatted = value.toStringAsFixed(decimalPlaces);
    return includeSymbol ? '$formatted%' : formatted;
  }
}
