import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store/data/models/models.dart';
import 'package:fashion_store/services/supabase_service.dart';

/// Provider para obtener todas las categorías
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final data = await SupabaseService.instance.getCategories();
  return data.map((json) => Category.fromJson(json)).toList();
});

/// Provider para obtener solo categorías principales (sin parent)
final mainCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((c) => c.parentId == null).toList();
});

/// Provider para obtener subcategorías de una categoría
final subcategoriesProvider = FutureProvider.family<List<Category>, int>((ref, parentId) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((c) => c.parentId == parentId).toList();
});

/// Provider para obtener una categoría por slug
final categoryBySlugProvider = FutureProvider.family<Category?, String>((ref, slug) async {
  final categories = await ref.watch(categoriesProvider.future);
  try {
    return categories.firstWhere((c) => c.slug == slug);
  } catch (_) {
    return null;
  }
});

/// Provider para obtener una categoría por ID
final categoryByIdProvider = FutureProvider.family<Category?, int>((ref, id) async {
  final categories = await ref.watch(categoriesProvider.future);
  try {
    return categories.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
