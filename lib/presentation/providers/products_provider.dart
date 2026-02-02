import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fashion_store/data/models/models.dart';
import 'package:fashion_store/services/supabase_service.dart';

/// Provider para obtener todos los productos
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final data = await SupabaseService.instance.getProducts();
  return data.map((json) => Product.fromJson(json)).toList();
});

/// Provider para obtener productos destacados
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final data = await SupabaseService.instance.getProducts(onlyFeatured: true);
  return data.map((json) => Product.fromJson(json)).toList();
});

/// Provider para obtener productos en oferta
final offerProductsProvider = FutureProvider<List<Product>>((ref) async {
  final data = await SupabaseService.instance.getProducts(onlyOffers: true);
  return data.map((json) => Product.fromJson(json)).toList();
});

/// Provider para obtener un producto específico por ID
final productByIdProvider = FutureProvider.family<Product?, int>((ref, id) async {
  final data = await SupabaseService.instance.getProductById(id);
  if (data == null) return null;
  return Product.fromJson(data);
});

/// Provider para productos por categoría
final productsByCategoryProvider = FutureProvider.family<List<Product>, int>((ref, categoryId) async {
  final data = await SupabaseService.instance.getProducts(categoryId: categoryId);
  return data.map((json) => Product.fromJson(json)).toList();
});

/// Provider para búsqueda de productos
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty || query.length < 2) return [];
  final data = await SupabaseService.instance.getProducts(search: query);
  return data.map((json) => Product.fromJson(json)).toList();
});

/// Provider para filtros de catálogo
final catalogFiltersProvider = StateNotifierProvider<CatalogFiltersNotifier, CatalogFilters>((ref) {
  return CatalogFiltersNotifier();
});

class CatalogFilters {
  final int? categoryId;
  final int? minPrice;
  final int? maxPrice;
  final String? size;
  final String sortBy;
  final bool sortAscending;

  CatalogFilters({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.size,
    this.sortBy = 'created_at',
    this.sortAscending = false,
  });

  CatalogFilters copyWith({
    int? categoryId,
    int? minPrice,
    int? maxPrice,
    String? size,
    String? sortBy,
    bool? sortAscending,
  }) {
    return CatalogFilters(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      size: size ?? this.size,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  CatalogFilters clearCategory() {
    return CatalogFilters(
      categoryId: null,
      minPrice: minPrice,
      maxPrice: maxPrice,
      size: size,
      sortBy: sortBy,
      sortAscending: sortAscending,
    );
  }

  CatalogFilters clearAll() {
    return CatalogFilters();
  }
}

class CatalogFiltersNotifier extends StateNotifier<CatalogFilters> {
  CatalogFiltersNotifier() : super(CatalogFilters());

  void setCategory(int? id) {
    state = CatalogFilters(
      categoryId: id,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      size: state.size,
      sortBy: state.sortBy,
      sortAscending: state.sortAscending,
    );
  }

  void clearCategory() {
    state = state.clearCategory();
  }

  void setPriceRange(int? min, int? max) {
    state = CatalogFilters(
      categoryId: state.categoryId,
      minPrice: min,
      maxPrice: max,
      size: state.size,
      sortBy: state.sortBy,
      sortAscending: state.sortAscending,
    );
  }

  void setSize(String? size) {
    state = CatalogFilters(
      categoryId: state.categoryId,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      size: size,
      sortBy: state.sortBy,
      sortAscending: state.sortAscending,
    );
  }

  void setSorting(String sortBy, bool ascending) {
    state = state.copyWith(sortBy: sortBy, sortAscending: ascending);
  }

  void clearAll() {
    state = state.clearAll();
  }
}

/// Provider para productos filtrados del catálogo
final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final filters = ref.watch(catalogFiltersProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  
  final data = await SupabaseService.instance.getProducts(
    categoryId: filters.categoryId,
    search: searchQuery.isNotEmpty ? searchQuery : null,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
  );
  
  List<Product> products = data.map((json) => Product.fromJson(json)).toList();

  // Aplicar filtro de talla (en cliente)
  if (filters.size != null) {
    products = products.where((p) {
      return p.variants.any((v) => v.size == filters.size && v.stock > 0);
    }).toList();
  }

  // Aplicar ordenamiento
  switch (filters.sortBy) {
    case 'price':
      products.sort((a, b) => filters.sortAscending 
        ? a.price.compareTo(b.price)
        : b.price.compareTo(a.price));
      break;
    case 'name':
      products.sort((a, b) => filters.sortAscending
        ? a.name.compareTo(b.name)
        : b.name.compareTo(a.name));
      break;
    case 'created_at':
    default:
      if (filters.sortAscending) {
        products = products.reversed.toList();
      }
      break;
  }

  return products;
});
