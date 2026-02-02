import 'package:intl/intl.dart';

/// Utilidades de formato y helpers
class AppUtils {
  AppUtils._();

  /// Formatea precio de céntimos a euros con símbolo
  /// Ejemplo: 2999 -> "29,99 €"
  static String formatPrice(int priceInCents) {
    final price = priceInCents / 100;
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '€',
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  /// Formatea precio sin símbolo
  /// Ejemplo: 2999 -> "29,99"
  static String formatPriceNoSymbol(int priceInCents) {
    final price = priceInCents / 100;
    final formatter = NumberFormat.decimalPattern('es_ES');
    return formatter.format(price);
  }

  /// Formatea fecha legible
  /// Ejemplo: "2 de febrero de 2026"
  static String formatDate(DateTime date) {
    final formatter = DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES');
    return formatter.format(date);
  }

  /// Formatea fecha corta
  /// Ejemplo: "02/02/2026"
  static String formatDateShort(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'es_ES');
    return formatter.format(date);
  }

  /// Formatea fecha y hora
  /// Ejemplo: "02/02/2026 14:30"
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
    return formatter.format(date);
  }

  /// Formatea tiempo relativo
  /// Ejemplo: "Hace 5 minutos", "Hace 2 horas", "Ayer"
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return formatDateShort(date);
    }
  }

  /// Valida formato de email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valida longitud mínima de contraseña
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  /// Capitaliza primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Trunca texto con ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Genera saludo según hora del día
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 20) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  /// Calcula IMC (para recomendador de talla)
  static double calculateBMI(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Recomienda talla basada en altura y peso
  static String recommendSize({
    required double heightCm,
    required double weightKg,
    required String productType, // 'ropa', 'pantalon', 'cinturon', 'calzado'
  }) {
    final bmi = calculateBMI(heightCm, weightKg);

    if (productType == 'calzado') {
      // Para calzado usar solo altura
      if (heightCm < 165) return '39-40';
      if (heightCm < 175) return '41-42';
      if (heightCm < 185) return '43-44';
      return '45-46';
    }

    if (productType == 'cinturon') {
      // Para cinturón basado en peso aproximado
      if (weightKg < 65) return '85';
      if (weightKg < 80) return '95';
      if (weightKg < 95) return '105';
      return '115';
    }

    // Para ropa y pantalones usar IMC
    if (bmi < 18.5) return 'XS';
    if (bmi < 22) return 'S';
    if (bmi < 25) return 'M';
    if (bmi < 28) return 'L';
    if (bmi < 32) return 'XL';
    return 'XXL';
  }
}
