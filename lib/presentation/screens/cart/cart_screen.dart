import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_store/core/constants/app_colors.dart';
import 'package:fashion_store/core/utils/app_utils.dart';
import 'package:fashion_store/data/models/models.dart';
import 'package:fashion_store/presentation/providers/cart_provider.dart';
import 'package:fashion_store/presentation/providers/auth_provider.dart';
import 'package:fashion_store/presentation/widgets/common_widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    if (_couponController.text.isEmpty) return;

    setState(() => _isApplyingCoupon = true);

    final success = await ref.read(cartProvider.notifier)
        .applyCoupon(_couponController.text.trim().toUpperCase());

    setState(() => _isApplyingCoupon = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Cupón aplicado correctamente' : 'Cupón no válido',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) {
        _couponController.clear();
      }
    }
  }

  void _goToCheckout() {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login');
      return;
    }
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Carrito',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('¿Vaciar carrito?'),
                    content: const Text(
                      'Se eliminarán todos los productos del carrito.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Vaciar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Vaciar',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Lista de items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartItemCard(
                        item: item,
                        onQuantityChanged: (qty) {
                          ref.read(cartProvider.notifier)
                              .updateQuantity(item.variantId, qty);
                        },
                        onRemove: () {
                          ref.read(cartProvider.notifier)
                              .removeItem(item.variantId);
                        },
                      );
                    },
                  ),
                ),

                // Sección de cupón y totales
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo de cupón
                        if (!cart.hasCoupon)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  decoration: InputDecoration(
                                    hintText: 'Código de cupón',
                                    prefixIcon: const Icon(
                                      Icons.local_offer_outlined,
                                      size: 20,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _isApplyingCoupon ? null : _applyCoupon,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: _isApplyingCoupon
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Aplicar'),
                              ),
                            ],
                          )
                        else
                          // Cupón aplicado
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cart.couponCode!,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      Text(
                                        '${cart.discountPercentage}% de descuento',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).removeCoupon();
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Resumen de precios
                        _PriceSummary(cart: cart),

                        const SizedBox(height: 16),

                        // Botón de checkout
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _goToCheckout,
                            child: Text(
                              'Proceder al pago (${AppUtils.formatPrice(cart.total)})',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Tu carrito está vacío',
      subtitle: 'Añade productos para empezar a comprar',
      buttonText: 'Explorar catálogo',
      onButtonPressed: () => context.go('/catalog'),
    );
  }
}

/// Card de item del carrito
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 80,
                height: 100,
                color: AppColors.surfaceVariant,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 80,
                height: 100,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Talla: ${item.size}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Precio
                    Text(
                      item.formattedUnitPrice,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.hasOffer && item.originalPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        item.formattedOriginalPrice,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Selector de cantidad
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: item.quantity > 1
                                ? () => onQuantityChanged(item.quantity - 1)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: item.quantity > 1
                                    ? AppColors.textSecondary
                                    : AppColors.divider,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              item.quantity.toString(),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: item.quantity < item.maxQuantity
                                ? () => onQuantityChanged(item.quantity + 1)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: item.quantity < item.maxQuantity
                                    ? AppColors.textSecondary
                                    : AppColors.divider,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Resumen de precios
class _PriceSummary extends StatelessWidget {
  final Cart cart;

  const _PriceSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal (${cart.itemCount} artículos)',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              cart.formattedSubtotal,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Descuento
        if (cart.hasCoupon) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Descuento (${cart.discountPercentage}%)',
                style: GoogleFonts.inter(
                  color: AppColors.success,
                ),
              ),
              Text(
                '-${cart.formattedDiscount}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],

        // Envío
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Envío',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              cart.subtotal >= 5000 ? 'Gratis' : AppUtils.formatPrice(495),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: cart.subtotal >= 5000 ? AppColors.success : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              cart.formattedTotal,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
