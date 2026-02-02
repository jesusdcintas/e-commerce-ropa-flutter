import 'package:fashion_store/core/utils/app_utils.dart';
import 'package:fashion_store/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Estados comerciales del pedido
enum OrderStatus {
  pending,
  paid,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.paid:
        return 'Pagado';
      case OrderStatus.shipped:
        return 'En Proceso';
      case OrderStatus.delivered:
        return 'Finalizado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.orderPending;
      case OrderStatus.paid:
        return AppColors.orderPaid;
      case OrderStatus.shipped:
        return AppColors.orderShipped;
      case OrderStatus.delivered:
        return AppColors.orderDelivered;
      case OrderStatus.cancelled:
        return AppColors.orderCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.paid:
        return Icons.payment;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// Estados logísticos del envío
enum ShippingStatus {
  pending,
  inTransit,
  outForDelivery,
  delivered;

  String get displayName {
    switch (this) {
      case ShippingStatus.pending:
        return 'Pendiente de envío';
      case ShippingStatus.inTransit:
        return 'En tránsito';
      case ShippingStatus.outForDelivery:
        return 'En reparto';
      case ShippingStatus.delivered:
        return 'Entregado';
    }
  }

  String get value {
    switch (this) {
      case ShippingStatus.pending:
        return 'pending';
      case ShippingStatus.inTransit:
        return 'in_transit';
      case ShippingStatus.outForDelivery:
        return 'out_for_delivery';
      case ShippingStatus.delivered:
        return 'delivered';
    }
  }

  static ShippingStatus fromString(String? value) {
    switch (value) {
      case 'in_transit':
        return ShippingStatus.inTransit;
      case 'out_for_delivery':
        return ShippingStatus.outForDelivery;
      case 'delivered':
        return ShippingStatus.delivered;
      default:
        return ShippingStatus.pending;
    }
  }
}

/// Modelo de pedido
class Order {
  final int id;
  final String userId;
  final int totalAmount; // en céntimos
  final OrderStatus status;
  final ShippingStatus shippingStatus;
  final String? couponCode;
  final int? discountAmount; // en céntimos
  final String? shippingName;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingPostalCode;
  final String? shippingProvince;
  final String? shippingPhone;
  final String? stripePaymentId;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.shippingStatus = ShippingStatus.pending,
    this.couponCode,
    this.discountAmount,
    this.shippingName,
    this.shippingAddress,
    this.shippingCity,
    this.shippingPostalCode,
    this.shippingProvince,
    this.shippingPhone,
    this.stripePaymentId,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Total formateado
  String get formattedTotal => AppUtils.formatPrice(totalAmount);

  /// Descuento formateado
  String get formattedDiscount =>
      discountAmount != null ? AppUtils.formatPrice(discountAmount!) : '';

  /// ¿Se puede cancelar?
  bool get canBeCancelled =>
      shippingStatus == ShippingStatus.pending &&
      (status == OrderStatus.pending || status == OrderStatus.paid);

  /// Dirección completa de envío
  String get fullShippingAddress {
    final parts = [
      shippingAddress,
      shippingPostalCode,
      shippingCity,
      shippingProvince,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }

  /// Número de items
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      totalAmount: json['total_amount'] as int,
      status: _parseOrderStatus(json['status'] as String?),
      shippingStatus: ShippingStatus.fromString(json['shipping_status'] as String?),
      couponCode: json['coupon_code'] as String?,
      discountAmount: json['discount_amount'] as int?,
      shippingName: json['shipping_name'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingPostalCode: json['shipping_postal_code'] as String?,
      shippingProvince: json['shipping_province'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      stripePaymentId: json['stripe_payment_id'] as String?,
      items: json['order_items'] != null
          ? (json['order_items'] as List)
              .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static OrderStatus _parseOrderStatus(String? value) {
    switch (value) {
      case 'paid':
        return OrderStatus.paid;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': totalAmount,
      'status': status.name,
      'shipping_status': shippingStatus.value,
      'coupon_code': couponCode,
      'discount_amount': discountAmount,
      'shipping_name': shippingName,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_postal_code': shippingPostalCode,
      'shipping_province': shippingProvince,
      'shipping_phone': shippingPhone,
    };
  }
}

/// Modelo de item de pedido
class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int? variantId;
  final String productName;
  final String productSize;
  final String? productImage;
  final int quantity;
  final int unitPrice; // en céntimos
  final int? originalPrice; // precio original si tenía oferta

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.variantId,
    required this.productName,
    required this.productSize,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.originalPrice,
  });

  /// Subtotal del item
  int get subtotal => unitPrice * quantity;

  /// Precio formateado
  String get formattedPrice => AppUtils.formatPrice(unitPrice);

  /// Subtotal formateado
  String get formattedSubtotal => AppUtils.formatPrice(subtotal);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      variantId: json['variant_id'] as int?,
      productName: json['product_name'] as String? ?? '',
      productSize: json['product_size'] as String? ?? '',
      productImage: json['product_image'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as int? ?? json['price'] as int? ?? 0,
      originalPrice: json['original_price'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'variant_id': variantId,
      'product_name': productName,
      'product_size': productSize,
      'product_image': productImage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'original_price': originalPrice,
    };
  }
}
