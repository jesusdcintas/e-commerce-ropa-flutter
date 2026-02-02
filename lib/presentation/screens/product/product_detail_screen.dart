import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_store/core/constants/app_colors.dart';
import 'package:fashion_store/core/utils/app_utils.dart';
import 'package:fashion_store/data/models/models.dart';
import 'package:fashion_store/presentation/providers/products_provider.dart';
import 'package:fashion_store/presentation/providers/cart_provider.dart';
import 'package:fashion_store/presentation/providers/favorites_provider.dart';
import 'package:fashion_store/presentation/widgets/common_widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int? _selectedVariantId;
  String? _selectedSize;
  int _quantity = 1;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    if (_selectedVariantId == null || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una talla'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Buscar la variante seleccionada
    final variant = product.variants.firstWhere(
      (v) => v.id == _selectedVariantId,
    );

    final success = ref.read(cartProvider.notifier).addItem(
      product: product,
      variant: variant,
      quantity: _quantity,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Añadido al carrito'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Ver carrito',
              textColor: Colors.white,
              onPressed: () => context.go('/cart'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay suficiente stock'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: productAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorState(
          message: 'Error al cargar el producto',
          onRetry: () => ref.invalidate(productByIdProvider(widget.productId)),
        ),
        data: (product) {
          if (product == null) {
            return const ErrorState(message: 'Producto no encontrado');
          }

          final isFavorite = ref.watch(isFavoriteProvider(product.id));
          final hasVariants = product.variants.isNotEmpty;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // App Bar con imagen
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.5,
                    pinned: true,
                    backgroundColor: AppColors.background,
                    leading: IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          ref.read(favoritesProvider.notifier)
                              .toggleFavorite(product.id);
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.error : AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Compartir producto
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.share_outlined,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _ImageGallery(
                        images: product.images,
                        pageController: _pageController,
                        currentIndex: _currentImageIndex,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                      ),
                    ),
                  ),

                  // Contenido
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Categoría
                          if (product.categoryName != null)
                            Text(
                              product.categoryName!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),

                          const SizedBox(height: 8),

                          // Nombre
                          Text(
                            product.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Precio
                          PriceWidget(
                            price: product.price,
                            originalPrice: product.hasOffer ? product.originalPrice : null,
                            large: true,
                          ),

                          if (product.hasOffer && product.originalPrice != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Ahorras ${AppUtils.formatPrice(product.originalPrice! - product.price)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Selector de talla
                          if (hasVariants) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Talla',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showSizeGuide(context, product),
                                  child: Text(
                                    'Guía de tallas',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SizeSelector(
                              variants: product.variants,
                              selectedVariantId: _selectedVariantId,
                              onSelected: (variant) {
                                setState(() {
                                  _selectedVariantId = variant.id;
                                  _selectedSize = variant.size;
                                  _quantity = 1;
                                });
                              },
                            ),
                          ],

                          // Selector de cantidad
                          if (_selectedVariantId != null) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Text(
                                  'Cantidad',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                _QuantitySelector(
                                  quantity: _quantity,
                                  maxQuantity: product.variants
                                      .firstWhere((v) => v.id == _selectedVariantId)
                                      .stock,
                                  onChanged: (qty) {
                                    setState(() => _quantity = qty);
                                  },
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Descripción
                          if (product.description != null) ...[
                            Text(
                              'Descripción',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],

                          // Espacio para el botón fijo
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Botón añadir al carrito fijo
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
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
                    child: Row(
                      children: [
                        // Total
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                AppUtils.formatPrice(product.finalPrice * _quantity),
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Botón
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: product.isInStock 
                                ? () => _addToCart(product)
                                : null,
                            child: Text(
                              product.isInStock 
                                  ? 'Añadir al carrito'
                                  : 'Agotado',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSizeGuide(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SizeGuideSheet(product: product),
    );
  }
}

/// Galería de imágenes
class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ImageGallery({
    required this.images,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          },
        ),

        // Indicadores
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  width: currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.secondary
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// Selector de talla
class _SizeSelector extends StatelessWidget {
  final List<ProductVariant> variants;
  final int? selectedVariantId;
  final ValueChanged<ProductVariant> onSelected;

  const _SizeSelector({
    required this.variants,
    required this.selectedVariantId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: variants.map((variant) {
        final isSelected = variant.id == selectedVariantId;
        final isAvailable = variant.stock > 0;

        return GestureDetector(
          onTap: isAvailable ? () => onSelected(variant) : null,
          child: Container(
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isAvailable
                      ? AppColors.surface
                      : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : isAvailable
                        ? AppColors.border
                        : AppColors.divider,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  variant.size,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isAvailable
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                    decoration: isAvailable ? null : TextDecoration.lineThrough,
                  ),
                ),
                if (variant.stock <= 3 && variant.stock > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Últimas ${variant.stock}',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: isSelected ? Colors.white70 : AppColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Selector de cantidad
class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
            color: AppColors.textSecondary,
            disabledColor: AppColors.divider,
          ),
          SizedBox(
            width: 40,
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: quantity < maxQuantity ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add, size: 18),
            color: AppColors.textSecondary,
            disabledColor: AppColors.divider,
          ),
        ],
      ),
    );
  }
}

/// Guía de tallas
class _SizeGuideSheet extends StatelessWidget {
  final Product product;

  const _SizeGuideSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Guía de Tallas',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recomendador de Talla',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Introduce tu altura y peso para obtener una recomendación personalizada.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // TODO: Implementar recomendador interactivo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.straighten, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Talla recomendada',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        product.variants.isNotEmpty 
                            ? product.variants.first.size 
                            : 'M',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
