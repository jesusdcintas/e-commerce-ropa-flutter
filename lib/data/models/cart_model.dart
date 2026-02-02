import 'package:fashion_store/data/models/product_model.dart';
import 'package:fashion_store/core/utils/app_utils.dart';

/// Modelo de item del carrito
class CartItem {
  final int productId;
  final int variantId;
  final Product product;
  final ProductVariant variant;
  int quantity;

  CartItem({
    required this.productId,
    required this.variantId,
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  /// Precio unitario (el precio actual del producto)
  int get unitPrice => product.price;

  /// Precio original (si tiene oferta)
  int? get originalPrice => product.originalPrice;

  /// Subtotal del item
  int get subtotal => unitPrice * quantity;

  /// Subtotal formateado
  String get formattedSubtotal => AppUtils.formatPrice(subtotal);

  /// Precio unitario formateado
  String get formattedUnitPrice => AppUtils.formatPrice(unitPrice);

  /// Precio original formateado
  String get formattedOriginalPrice =>
      originalPrice != null ? AppUtils.formatPrice(originalPrice!) : '';

  /// ¿Tiene oferta?
  bool get hasOffer => product.hasOffer;

  /// Imagen del producto
  String get imageUrl => product.mainImage;

  /// Nombre del producto
  String get productName => product.name;

  /// Talla
  String get size => variant.size;

  /// ¿Hay stock suficiente?
  bool get hasEnoughStock => variant.stock >= quantity;

  /// Stock máximo disponible
  int get maxQuantity => variant.stock;

  /// Clave única para el item (producto + variante)
  String get key => '${productId}_$variantId';

  CartItem copyWith({
    int? productId,
    int? variantId,
    Product? product,
    ProductVariant? variant,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      product: product ?? this.product,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
    };
  }

  /// Para almacenamiento local
  Map<String, dynamic> toLocalJson() {
    return {
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
      'product': product.toJson(),
      'variant': variant.toJson(),
    };
  }

  factory CartItem.fromLocalJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] as int,
      variantId: json['variant_id'] as int,
      quantity: json['quantity'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      variant: ProductVariant.fromJson(json['variant'] as Map<String, dynamic>),
    );
  }
}

/// Modelo del carrito completo
class Cart {
  final List<CartItem> items;
  final String? couponCode;
  final int? discountPercentage;

  Cart({
    this.items = const [],
    this.couponCode,
    this.discountPercentage,
  });

  /// ¿El carrito está vacío?
  bool get isEmpty => items.isEmpty;

  /// Número total de items
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal antes de descuento
  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Monto del descuento (en céntimos)
  int get discountAmount {
    if (discountPercentage == null || discountPercentage == 0) return 0;
    return (subtotal * discountPercentage! / 100).round();
  }

  /// Total después de descuento
  int get total => subtotal - discountAmount;

  /// Subtotal formateado
  String get formattedSubtotal => AppUtils.formatPrice(subtotal);

  /// Descuento formateado
  String get formattedDiscount => AppUtils.formatPrice(discountAmount);

  /// Total formateado
  String get formattedTotal => AppUtils.formatPrice(total);

  /// ¿Tiene cupón aplicado?
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  Cart copyWith({
    List<CartItem>? items,
    String? couponCode,
    int? discountPercentage,
  }) {
    return Cart(
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }

  /// Quitar cupón
  Cart removeCoupon() {
    return Cart(
      items: items,
      couponCode: null,
      discountPercentage: null,
    );
  }
}
