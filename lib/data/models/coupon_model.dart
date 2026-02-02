import 'package:fashion_store/core/utils/app_utils.dart';

/// Tipos de reglas de cupones
enum CouponRuleType {
  firstPurchase,    // primera_compra
  minSpend,         // gasto_minimo (en el pedido actual)
  totalSpend,       // gasto_total (histórico)
  purchaseCount,    // numero_compras
  periodSpend,      // gasto_periodo
  accountAge,       // antiguedad
  newsletter;       // newsletter

  String get displayName {
    switch (this) {
      case CouponRuleType.firstPurchase:
        return 'Primera compra';
      case CouponRuleType.minSpend:
        return 'Gasto mínimo en pedido';
      case CouponRuleType.totalSpend:
        return 'Gasto histórico total';
      case CouponRuleType.purchaseCount:
        return 'Número de compras';
      case CouponRuleType.periodSpend:
        return 'Gasto en periodo';
      case CouponRuleType.accountAge:
        return 'Antigüedad de cuenta';
      case CouponRuleType.newsletter:
        return 'Suscriptor newsletter';
    }
  }

  String get value {
    switch (this) {
      case CouponRuleType.firstPurchase:
        return 'primera_compra';
      case CouponRuleType.minSpend:
        return 'gasto_minimo';
      case CouponRuleType.totalSpend:
        return 'gasto_total';
      case CouponRuleType.purchaseCount:
        return 'numero_compras';
      case CouponRuleType.periodSpend:
        return 'gasto_periodo';
      case CouponRuleType.accountAge:
        return 'antiguedad';
      case CouponRuleType.newsletter:
        return 'newsletter';
    }
  }

  static CouponRuleType? fromString(String? value) {
    switch (value) {
      case 'primera_compra':
        return CouponRuleType.firstPurchase;
      case 'gasto_minimo':
        return CouponRuleType.minSpend;
      case 'gasto_total':
        return CouponRuleType.totalSpend;
      case 'numero_compras':
        return CouponRuleType.purchaseCount;
      case 'gasto_periodo':
        return CouponRuleType.periodSpend;
      case 'antiguedad':
        return CouponRuleType.accountAge;
      case 'newsletter':
        return CouponRuleType.newsletter;
      default:
        return null;
    }
  }
}

/// Modelo de regla de cupón
class CouponRule {
  final String id;
  final String name;
  final CouponRuleType type;
  final int? minAmount; // en céntimos (para gasto_minimo, gasto_total, gasto_periodo)
  final int? minPurchases; // para numero_compras
  final int? periodDays; // para gasto_periodo, antiguedad
  final DateTime? createdAt;

  CouponRule({
    required this.id,
    required this.name,
    required this.type,
    this.minAmount,
    this.minPurchases,
    this.periodDays,
    this.createdAt,
  });

  String get conditionDescription {
    switch (type) {
      case CouponRuleType.firstPurchase:
        return 'Solo para tu primera compra';
      case CouponRuleType.minSpend:
        return 'Pedido mínimo de ${AppUtils.formatPrice(minAmount ?? 0)}';
      case CouponRuleType.totalSpend:
        return 'Haber gastado más de ${AppUtils.formatPrice(minAmount ?? 0)} en total';
      case CouponRuleType.purchaseCount:
        return 'Haber realizado $minPurchases o más compras';
      case CouponRuleType.periodSpend:
        return 'Haber gastado ${AppUtils.formatPrice(minAmount ?? 0)} en los últimos $periodDays días';
      case CouponRuleType.accountAge:
        return 'Cuenta con más de $periodDays días de antigüedad';
      case CouponRuleType.newsletter:
        return 'Exclusivo para suscriptores de newsletter';
    }
  }

  factory CouponRule.fromJson(Map<String, dynamic> json) {
    return CouponRule(
      id: json['id'] as String,
      name: json['nombre'] as String? ?? '',
      type: CouponRuleType.fromString(json['tipo_regla'] as String?) ??
          CouponRuleType.firstPurchase,
      minAmount: json['monto_minimo'] as int?,
      minPurchases: json['min_compras'] as int?,
      periodDays: json['periodo_dias'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'tipo_regla': type.value,
      'monto_minimo': minAmount,
      'min_compras': minPurchases,
      'periodo_dias': periodDays,
    };
  }
}

/// Modelo de cupón
class Coupon {
  final String id;
  final String code;
  final int discountPercentage;
  final bool isActive;
  final bool isPublic;
  final bool isUsed;
  final String? clientId; // si es privado
  final String? ruleId;
  final CouponRule? rule;
  final bool onlyNewsletter;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final DateTime? createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercentage,
    this.isActive = true,
    this.isPublic = true,
    this.isUsed = false,
    this.clientId,
    this.ruleId,
    this.rule,
    this.onlyNewsletter = false,
    this.validFrom,
    this.validUntil,
    this.createdAt,
  });

  /// ¿El cupón está vigente?
  bool get isValid {
    if (!isActive || isUsed) return false;
    
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    
    return true;
  }

  /// Descripción del descuento
  String get discountText => '$discountPercentage% de descuento';

  /// Descripción de validez
  String? get validityText {
    if (validUntil == null) return null;
    return 'Válido hasta ${AppUtils.formatDateShort(validUntil!)}';
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['codigo'] as String,
      discountPercentage: json['descuento_porcentaje'] as int,
      isActive: json['activo'] as bool? ?? true,
      isPublic: json['es_publico'] as bool? ?? true,
      isUsed: json['usado'] as bool? ?? false,
      clientId: json['cliente_id'] as String?,
      ruleId: json['regla_id'] as String?,
      rule: json['reglas_cupones'] != null
          ? CouponRule.fromJson(json['reglas_cupones'] as Map<String, dynamic>)
          : null,
      onlyNewsletter: json['solo_newsletter'] as bool? ?? false,
      validFrom: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      validUntil: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': code,
      'descuento_porcentaje': discountPercentage,
      'activo': isActive,
      'es_publico': isPublic,
      'usado': isUsed,
      'cliente_id': clientId,
      'regla_id': ruleId,
      'solo_newsletter': onlyNewsletter,
      'fecha_inicio': validFrom?.toIso8601String(),
      'fecha_fin': validUntil?.toIso8601String(),
    };
  }
}
