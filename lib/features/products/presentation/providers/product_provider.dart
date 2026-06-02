import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/core/network/dio_client.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_local_datasource.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:ecommerce_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.watch(dioClientProvider));
});

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ref.watch(productRemoteDataSourceProvider),
    ref.watch(productLocalDataSourceProvider),
  );
});

enum SortOption { none, priceLowToHigh, priceHighToLow, rating }

class ProductListState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int skip;
  final String searchQuery;
  final String? selectedCategory;
  final SortOption sortOption;
  final List<dynamic> categories;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.skip = 0,
    this.searchQuery = '',
    this.selectedCategory,
    this.sortOption = SortOption.none,
    this.categories = const [],
  });

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? skip,
    String? searchQuery,
    String? selectedCategory,
    SortOption? sortOption,
    List<dynamic>? categories,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      skip: skip ?? this.skip,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      sortOption: sortOption ?? this.sortOption,
      categories: categories ?? this.categories,
    );
  }

  List<Product> get sortedProducts {
    final sorted = List<Product>.from(products);
    switch (sortOption) {
      case SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.none:
        break;
    }
    return sorted;
  }
}

class ProductNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _repository;
  bool _isFetching = false;

  ProductNotifier(this._repository) : super(const ProductListState()) {
    loadProducts();
    loadCategories();
  }

  Future<void> loadProducts() async {
    if (_isFetching) return;
    _isFetching = true;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.getProducts(skip: 0);
      state = state.copyWith(
        products: response.products,
        isLoading: false,
        hasMore: response.hasMore,
        skip: response.products.length,
      );
    } catch (e) {
      final cached = _repository.getCachedProducts();
      if (cached.isNotEmpty) {
        state = state.copyWith(
          products: cached,
          isLoading: false,
          hasMore: false,
          error: 'Showing cached data. Pull to refresh.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(e),
        );
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || !state.hasMore || state.isLoadingMore) return;
    _isFetching = true;

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = state.searchQuery.isNotEmpty
          ? await _repository.searchProducts(state.searchQuery, skip: state.skip)
          : state.selectedCategory != null
              ? await _repository.getProductsByCategory(state.selectedCategory!, skip: state.skip)
              : await _repository.getProducts(skip: state.skip);

      final allProducts = [...state.products, ...response.products];
      state = state.copyWith(
        products: allProducts,
        isLoadingMore: false,
        hasMore: response.hasMore,
        skip: allProducts.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: _getErrorMessage(e),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    _isFetching = false;
    state = state.copyWith(skip: 0, hasMore: true, clearError: true);

    if (state.searchQuery.isNotEmpty) {
      await searchProducts(state.searchQuery);
    } else if (state.selectedCategory != null) {
      await filterByCategory(state.selectedCategory!);
    } else {
      await loadProducts();
    }
  }

  Future<void> searchProducts(String query) async {
    if (_isFetching) return;
    _isFetching = true;

    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      clearError: true,
      clearCategory: true,
      skip: 0,
    );

    try {
      if (query.isEmpty) {
        _isFetching = false;
        await loadProducts();
        return;
      }

      final response = await _repository.searchProducts(query);
      state = state.copyWith(
        products: response.products,
        isLoading: false,
        hasMore: response.hasMore,
        skip: response.products.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> filterByCategory(String category) async {
    if (_isFetching) return;
    _isFetching = true;

    state = state.copyWith(
      isLoading: true,
      selectedCategory: category,
      searchQuery: '',
      clearError: true,
      skip: 0,
    );

    try {
      final response = await _repository.getProductsByCategory(category);
      state = state.copyWith(
        products: response.products,
        isLoading: false,
        hasMore: response.hasMore,
        skip: response.products.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    } finally {
      _isFetching = false;
    }
  }

  void clearFilters() {
    state = state.copyWith(
      clearCategory: true,
      searchQuery: '',
      sortOption: SortOption.none,
    );
    _isFetching = false;
    loadProducts();
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(categories: categories);
    } catch (_) {}
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socketexception') || errorStr.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}

final productNotifierProvider = StateNotifierProvider<ProductNotifier, ProductListState>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(id);
});
