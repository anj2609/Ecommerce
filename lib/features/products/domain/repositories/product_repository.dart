import 'package:ecommerce_app/features/products/data/models/products_response.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Future<ProductsResponse> getProducts({int limit, int skip});
  Future<Product> getProductById(int id);
  Future<ProductsResponse> searchProducts(String query, {int limit, int skip});
  Future<List<dynamic>> getCategories();
  Future<ProductsResponse> getProductsByCategory(String category, {int limit, int skip});
  List<Product> getCachedProducts();
  void cacheProducts(List<Product> products);
}
