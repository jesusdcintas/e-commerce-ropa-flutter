import 'package:flutter/material.dart';

/// Colores de la aplicación - Paleta Premium
class AppColors {
  AppColors._();

  // Colores principales
  static const Color primary = Color(0xFF1A1A1A);      // Negro
  static const Color secondary = Color(0xFFB8860B);    // Dorado
  static const Color accent = Color(0xFFB8860B);       // Dorado (alias)

  // Fondos
  static const Color background = Color(0xFFFAFAFA);   // Gris muy claro
  static const Color surface = Color(0xFFFFFFFF);      // Blanco
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF1A1A1A);

  // Estados
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Bordes y divisores
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Estados de orden
  static const Color orderPending = Color(0xFFF59E0B);
  static const Color orderPaid = Color(0xFF3B82F6);
  static const Color orderShipped = Color(0xFF8B5CF6);
  static const Color orderDelivered = Color(0xFF16A34A);
  static const Color orderCancelled = Color(0xFFDC2626);

  // Sombras
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Shimmer (skeleton loading)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
