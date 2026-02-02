/// Modelo de categoría
class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final int? parentId;
  final int displayOrder;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.parentId,
    this.displayOrder = 0,
    this.createdAt,
  });

  bool get isParent => parentId == null;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      parentId: json['parent_id'] as int?,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image_url': imageUrl,
      'parent_id': parentId,
      'display_order': displayOrder,
    };
  }
}
