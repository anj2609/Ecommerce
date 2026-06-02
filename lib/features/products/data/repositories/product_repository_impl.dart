import 'package:ecommerce_app/features/products/data/datasources/product_local_datasource.dart';
import 'package:ecommerce_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:ecommerce_app/features/products/data/models/products_response.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<ProductsResponse> getProducts({int limit = 10, int skip = 0}) async {
    final response = await _remoteDataSource.getProducts(limit: limit, skip: skip);
    if (skip == 0) {
      _localDataSource.cacheProducts(response.products);
    }
    return response;
  }

  @override
  Future<Product> getProductById(int id) async {
    return await _remoteDataSource.getProductById(id);
  }

  @override
  Future<ProductsResponse> searchProducts(String query, {int limit = 10, int skip = 0}) async {
    return await _remoteDataSource.searchProducts(query, limit: limit, skip: skip);
  }

  @override
  Future<List<dynamic>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }

  @override
  Future<ProductsResponse> getProductsByCategory(String category, {int limit = 10, int skip = 0}) async {
    return await _remoteDataSource.getProductsByCategory(category, limit: limit, skip: skip);
  }

  @override
  List<Product> getCachedProducts() {
    return _localDataSource.getCachedProducts();
  }

  @override
  void cacheProducts(List<Product> products) {
    _localDataSource.cacheProducts(products);
  }
}
