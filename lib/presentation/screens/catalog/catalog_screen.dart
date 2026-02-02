import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fashion_store/core/constants/app_colors.dart';
import 'package:fashion_store/presentation/providers/products_provider.dart';
import 'package:fashion_store/presentation/providers/categories_provider.dart';
import 'package:fashion_store/presentation/widgets/product_card.dart';
import 'package:fashion_store/presentation/widgets/skeleton_loaders.dart';
import 'package:fashion_store/presentation/widgets/common_widgets.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(filteredProductsProvider);
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FiltersSheet(),
    );
  }

  void _openSort() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _SortSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(catalogFiltersProvider);
    final productsAsync = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(mainCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                  ),
                ),
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              )
            : Text(
                'Catálogo',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorías horizontales
          categoriesAsync.when(
            loading: () => const CategoriesRowSkeleton(itemCount: 4),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) => SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _CategoryChip(
                      label: 'Todos',
                      isSelected: filters.categoryId == null,
                      onTap: () {
                        ref.read(catalogFiltersProvider.notifier).clearCategory();
                      },
                    );
                  }
                  final category = categories[index - 1];
                  return _CategoryChip(
                    label: category.name,
                    isSelected: filters.categoryId == category.id,
                    onTap: () {
                      ref.read(catalogFiltersProvider.notifier)
                          .setCategory(category.id);
                    },
                  );
                },
              ),
            ),
          ),

          // Barra de filtros y ordenamiento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                productsAsync.when(
                  loading: () => const TextLineSkeleton(width: 80, height: 14),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (products) => Text(
                    '${products.length} productos',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _openSort,
                  icon: const Icon(Icons.sort, size: 18),
                  label: Text(_getSortLabel(filters.sortBy, filters.sortAscending)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    textStyle: GoogleFonts.inter(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _openFilters,
                  icon: Stack(
                    children: [
                      const Icon(Icons.filter_list, color: AppColors.textSecondary),
                      if (_hasActiveFilters(filters))
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de productos
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: productsAsync.when(
                loading: () => const ProductGridSkeleton(itemCount: 6),
                error: (error, stack) => ErrorState(
                  message: 'Error al cargar productos',
                  onRetry: _onRefresh,
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: 'No hay productos',
                      subtitle: filters.categoryId != null
                          ? 'No hay productos en esta categoría'
                          : 'Ajusta los filtros para ver más resultados',
                      buttonText: 'Limpiar filtros',
                      onButtonPressed: () {
                        ref.read(catalogFiltersProvider.notifier).clearAll();
                      },
                    );
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy, bool ascending) {
    switch (sortBy) {
      case 'price':
        return ascending ? 'Precio ↑' : 'Precio ↓';
      case 'name':
        return ascending ? 'Nombre A-Z' : 'Nombre Z-A';
      case 'created_at':
      default:
        return 'Novedades';
    }
  }

  bool _hasActiveFilters(CatalogFilters filters) {
    return filters.minPrice != null ||
        filters.maxPrice != null ||
        filters.size != null;
  }
}

/// Chip de categoría
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
        checkmarkColor: Colors.white,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/// Sheet de ordenamiento
class _SortSheet extends ConsumerWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(catalogFiltersProvider);

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
            'Ordenar por',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SortOption(
            label: 'Novedades',
            isSelected: filters.sortBy == 'created_at',
            onTap: () {
              ref.read(catalogFiltersProvider.notifier)
                  .setSorting('created_at', false);
              context.pop();
            },
          ),
          _SortOption(
            label: 'Precio: menor a mayor',
            isSelected: filters.sortBy == 'price' && filters.sortAscending,
            onTap: () {
              ref.read(catalogFiltersProvider.notifier)
                  .setSorting('price', true);
              context.pop();
            },
          ),
          _SortOption(
            label: 'Precio: mayor a menor',
            isSelected: filters.sortBy == 'price' && !filters.sortAscending,
            onTap: () {
              ref.read(catalogFiltersProvider.notifier)
                  .setSorting('price', false);
              context.pop();
            },
          ),
          _SortOption(
            label: 'Nombre A-Z',
            isSelected: filters.sortBy == 'name' && filters.sortAscending,
            onTap: () {
              ref.read(catalogFiltersProvider.notifier)
                  .setSorting('name', true);
              context.pop();
            },
          ),
          _SortOption(
            label: 'Nombre Z-A',
            isSelected: filters.sortBy == 'name' && !filters.sortAscending,
            onTap: () {
              ref.read(catalogFiltersProvider.notifier)
                  .setSorting('name', false);
              context.pop();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.secondary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.secondary)
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Sheet de filtros
class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  RangeValues _priceRange = const RangeValues(0, 500);
  String? _selectedSize;
  
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Única'];

  @override
  void initState() {
    super.initState();
    final filters = ref.read(catalogFiltersProvider);
    _priceRange = RangeValues(
      (filters.minPrice ?? 0).toDouble(),
      (filters.maxPrice ?? 50000).toDouble(),
    );
    _selectedSize = filters.size;
  }

  void _applyFilters() {
    final notifier = ref.read(catalogFiltersProvider.notifier);
    
    if (_priceRange.start > 0 || _priceRange.end < 50000) {
      notifier.setPriceRange(_priceRange.start.toInt(), _priceRange.end.toInt());
    } else {
      notifier.setPriceRange(null, null);
    }
    
    notifier.setSize(_selectedSize);
    
    context.pop();
  }

  void _clearFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 50000);
      _selectedSize = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Filtros',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Limpiar',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rango de precio
                  Text(
                    'Precio',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '€${_priceRange.start.toInt()}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '€${_priceRange.end.toInt()}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    activeColor: AppColors.secondary,
                    inactiveColor: AppColors.border,
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Tallas
                  Text(
                    'Talla',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSize = isSelected ? null : size;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            size,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Botón aplicar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Aplicar filtros'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
