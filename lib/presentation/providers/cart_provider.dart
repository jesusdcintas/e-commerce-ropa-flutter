import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store/data/models/models.dart';
import 'package:fashion_store/services/supabase_service.dart';

/// Provider para el carrito
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

/// Provider para el conteo de items en el carrito
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemCount;
});

/// Provider para verificar si un producto está en el carrito
final isInCartProvider = Provider.family<bool, int>((ref, productId) {
  final cart = ref.watch(cartProvider);
  return cart.items.any((item) => item.productId == productId);
});

/// Provider para obtener el subtotal del carrito
final cartSubtotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.subtotal;
});

/// Provider para obtener el total con descuento
final cartTotalProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.total;
});

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(Cart(items: []));

  /// Añadir producto al carrito
  bool addItem({
    required Product product,
    required ProductVariant variant,
    int quantity = 1,
  }) {
    // Verificar stock
    if (variant.stock < quantity) {
      return false;
    }

    // Verificar si ya existe en el carrito
    final existingIndex = state.items.indexWhere(
      (item) => item.productId == product.id && item.variantId == variant.id,
    );

    List<CartItem> newItems = List.from(state.items);

    if (existingIndex >= 0) {
      // Actualizar cantidad
      final existingItem = newItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      if (newQuantity > variant.stock) {
        return false;
      }

      newItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
    } else {
      // Añadir nuevo item
      final newItem = CartItem(
        productId: product.id,
        variantId: variant.id,
        product: product,
        variant: variant,
        quantity: quantity,
      );
      newItems.add(newItem);
    }

    state = state.copyWith(items: newItems);
    return true;
  }

  /// Actualizar cantidad de un item
  void updateQuantity(int variantId, int quantity) {
    if (quantity <= 0) {
      removeItem(variantId);
      return;
    }

    final newItems = state.items.map((item) {
      if (item.variantId == variantId) {
        final newQty = quantity.clamp(1, item.variant.stock);
        return item.copyWith(quantity: newQty);
      }
      return item;
    }).toList();

    state = state.copyWith(items: newItems);
  }

  /// Eliminar item del carrito
  void removeItem(int variantId) {
    final newItems = state.items.where((item) => item.variantId != variantId).toList();
    state = state.copyWith(items: newItems);
  }

  /// Limpiar carrito
  void clearCart() {
    state = Cart(items: []);
  }

  /// Aplicar cupón
  Future<bool> applyCoupon(String code) async {
    if (!SupabaseService.instance.isAuthenticated) return false;

    try {
      final result = await SupabaseService.instance.validateCoupon(
        code: code,
        orderTotal: state.subtotal,
      );

      if (result['valid'] == true) {
        final discount = result['discount_percentage'] as int? ?? 0;
        state = Cart(
          items: state.items,
          couponCode: code,
          discountPercentage: discount,
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Quitar cupón
  void removeCoupon() {
    state = state.removeCoupon();
  }
}
