import 'package:fashion_store/core/utils/app_utils.dart';

/// Modelo de producto
class Product {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int price; // en céntimos
  final int? originalPrice; // precio original si tiene oferta (en céntimos)
  final int? categoryId;
  final String? categoryName;
  final List<String> images;
  final List<ProductVariant> variants;
  final bool isActive;
  final bool isFeatured;
  final bool isNew;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.originalPrice,
    this.categoryId,
    this.categoryName,
    this.images = const [],
    this.variants = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.isNew = false,
    this.createdAt,
    this.updatedAt,
  });

  /// ¿Tiene oferta activa?
  bool get hasOffer => originalPrice != null && originalPrice! > price;

  /// Porcentaje de descuento
  int get discountPercentage {
    if (!hasOffer) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  /// Precio formateado
  String get formattedPrice => AppUtils.formatPrice(price);

  /// Precio original formateado
  String get formattedOriginalPrice =>
      originalPrice != null ? AppUtils.formatPrice(originalPrice!) : '';

  /// Imagen principal
  String get mainImage => images.isNotEmpty ? images.first : '';

  /// Stock total de todas las variantes
  int get totalStock =>
      variants.fold(0, (sum, variant) => sum + variant.stock);

  /// ¿Está agotado?
  bool get isOutOfStock => totalStock <= 0;

  /// Tallas disponibles (con stock)
  List<String> get availableSizes => variants
      .where((v) => v.stock > 0)
      .map((v) => v.size)
      .toSet()
      .toList();

  /// ¿Es talla única? (accesorios)
  bool get isSingleSize =>
      variants.length == 1 && 
      (variants.first.size.toLowerCase() == 'única' ||
       variants.first.size.toLowerCase() == 'unica' ||
       variants.first.size.toUpperCase() == 'TU');

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price'] as int,
      originalPrice: json['original_price'] as int?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category']?['name'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      variants: json['product_variants'] != null
          ? (json['product_variants'] as List)
              .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
              .toList()
          : [],
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      isNew: json['is_new'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'category_id': categoryId,
      'images': images,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_new': isNew,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    int? price,
    int? originalPrice,
    int? categoryId,
    String? categoryName,
    List<String>? images,
    List<ProductVariant>? variants,
    bool? isActive,
    bool? isFeatured,
    bool? isNew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
      variants: variants ?? this.variants,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de variante de producto (talla/color)
class ProductVariant {
  final int id;
  final int productId;
  final String size;
  final String? color;
  final int stock;
  final String? sku;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.size,
    this.color,
    required this.stock,
    this.sku,
  });

  bool get isAvailable => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 3;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      size: json['size'] as String? ?? '',
      color: json['color'] as String?,
      stock: json['stock'] as int? ?? 0,
      sku: json['sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'size': size,
      'color': color,
      'stock': stock,
      'sku': sku,
    };
  }
}
