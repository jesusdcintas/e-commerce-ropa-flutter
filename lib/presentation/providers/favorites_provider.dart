import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store/data/models/models.dart';
import 'package:fashion_store/services/supabase_service.dart';

/// Provider para favoritos del usuario
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Product>>>((ref) {
  return FavoritesNotifier();
});

/// Provider para verificar si un producto está en favoritos
final isFavoriteProvider = Provider.family<bool, int>((ref, productId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.maybeWhen(
    data: (products) => products.any((p) => p.id == productId),
    orElse: () => false,
  );
});

/// Provider para el conteo de favoritos
final favoritesCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.maybeWhen(
    data: (products) => products.length,
    orElse: () => 0,
  );
});

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  FavoritesNotifier() : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!SupabaseService.instance.isAuthenticated) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final data = await SupabaseService.instance.getFavorites();
      final products = data
          .where((f) => f['products'] != null)
          .map((f) => Product.fromJson(f['products'] as Map<String, dynamic>))
          .toList();
      state = AsyncValue.data(products);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadFavorites();
  }

  Future<bool> toggleFavorite(int productId) async {
    if (!SupabaseService.instance.isAuthenticated) return false;

    final currentFavorites = state.value ?? [];
    final isFavorite = currentFavorites.any((p) => p.id == productId);

    try {
      if (isFavorite) {
        // Eliminar de favoritos
        await SupabaseService.instance.removeFavorite(productId);
        state = AsyncValue.data(
          currentFavorites.where((p) => p.id != productId).toList(),
        );
      } else {
        // Añadir a favoritos
        await SupabaseService.instance.addFavorite(productId);
        // Recargar para obtener el producto completo
        await _loadFavorites();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Añadir a favoritos
  Future<bool> addFavorite(int productId) async {
    if (!SupabaseService.instance.isAuthenticated) return false;
    try {
      await SupabaseService.instance.addFavorite(productId);
      await _loadFavorites();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Eliminar de favoritos
  Future<bool> removeFavorite(int productId) async {
    if (!SupabaseService.instance.isAuthenticated) return false;
    try {
      await SupabaseService.instance.removeFavorite(productId);
      final currentFavorites = state.value ?? [];
      state = AsyncValue.data(
        currentFavorites.where((p) => p.id != productId).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
