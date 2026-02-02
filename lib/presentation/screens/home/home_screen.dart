import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fashion_store/core/constants/app_colors.dart';
import 'package:fashion_store/presentation/providers/products_provider.dart';
import 'package:fashion_store/presentation/providers/categories_provider.dart';
import 'package:fashion_store/presentation/widgets/product_card.dart';
import 'package:fashion_store/presentation/widgets/category_card.dart';
import 'package:fashion_store/presentation/widgets/skeleton_loaders.dart';
import 'package:fashion_store/presentation/widgets/common_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(featuredProductsProvider);
    ref.invalidate(offerProductsProvider);
    ref.invalidate(categoriesProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'FASHION STORE',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textPrimary),
                  onPressed: () {
                    // TODO: Abrir búsqueda
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                  onPressed: () {
                    // TODO: Ir a notificaciones
                  },
                ),
              ],
            ),

            // Hero Banner
            const SliverToBoxAdapter(
              child: _HeroBanner(),
            ),

            // Categorías
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SectionHeader(
                    title: 'Categorías',
                    onViewAll: () => context.go('/catalog'),
                  ),
                  const _CategoriesRow(),
                ],
              ),
            ),

            // Productos Destacados
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Destacados',
                    subtitle: 'Selección especial para ti',
                    onViewAll: () => context.go('/catalog'),
                  ),
                ],
              ),
            ),
            const _FeaturedProductsGrid(),

            // Ofertas
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Ofertas',
                    subtitle: 'Descuentos exclusivos',
                    onViewAll: () => context.push('/catalog?filter=offers'),
                  ),
                ],
              ),
            ),
            const _OfferProductsGrid(),

            // Espaciado final
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner Hero promocional
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Patrón decorativo
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NUEVA COLECCIÓN',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Primavera\n2026',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'EXPLORAR',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila horizontal de categorías
class _CategoriesRow extends ConsumerWidget {
  const _CategoriesRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(mainCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const CategoriesRowSkeleton(),
      error: (error, stack) => const SizedBox(
        height: 100,
        child: Center(
          child: Text('Error al cargar categorías'),
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const SizedBox(height: 100);
        }
        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                onTap: () {
                  ref.read(catalogFiltersProvider.notifier)
                      .setCategory(category.id);
                  context.go('/catalog');
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Grid de productos destacados
class _FeaturedProductsGrid extends ConsumerWidget {
  const _FeaturedProductsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(featuredProductsProvider);

    return productsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: ProductGridSkeleton(itemCount: 4),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: ErrorState(
          message: 'Error al cargar productos',
          onRetry: () => ref.invalidate(featuredProductsProvider),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No hay productos destacados'),
              ),
            ),
          );
        }
        
        // Mostrar máximo 4 productos
        final displayProducts = products.take(4).toList();
        
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(product: displayProducts[index]),
              childCount: displayProducts.length,
            ),
          ),
        );
      },
    );
  }
}

/// Grid de productos en oferta
class _OfferProductsGrid extends ConsumerWidget {
  const _OfferProductsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(offerProductsProvider);

    return productsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: ProductGridSkeleton(itemCount: 4),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: ErrorState(
          message: 'Error al cargar ofertas',
          onRetry: () => ref.invalidate(offerProductsProvider),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No hay ofertas activas'),
              ),
            ),
          );
        }
        
        // Mostrar máximo 4 productos en oferta
        final displayProducts = products.take(4).toList();
        
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(product: displayProducts[index]),
              childCount: displayProducts.length,
            ),
          ),
        );
      },
    );
  }
}
