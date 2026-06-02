import 'package:ecommerce_app/core/constants/api_constants.dart';
import 'package:ecommerce_app/core/network/dio_client.dart';
import 'package:ecommerce_app/features/products/data/models/products_response.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSource(this._dioClient);

  Future<ProductsResponse> getProducts({int limit = ApiConstants.defaultLimit, int skip = 0}) async {
    final response = await _dioClient.get(
      ApiConstants.productsEndpoint,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductsResponse.fromJson(response.data);
  }

  Future<Product> getProductById(int id) async {
    final response = await _dioClient.get('${ApiConstants.productsEndpoint}/$id');
    return Product.fromJson(response.data);
  }

  Future<ProductsResponse> searchProducts(String query, {int limit = ApiConstants.defaultLimit, int skip = 0}) async {
    final response = await _dioClient.get(
      ApiConstants.searchEndpoint,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return ProductsResponse.fromJson(response.data);
  }

  Future<List<dynamic>> getCategories() async {
    final response = await _dioClient.get(ApiConstants.categoriesEndpoint);
    return response.data as List<dynamic>;
  }

  Future<ProductsResponse> getProductsByCategory(String category, {int limit = ApiConstants.defaultLimit, int skip = 0}) async {
    final response = await _dioClient.get(
      '${ApiConstants.productsEndpoint}/category/$category',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductsResponse.fromJson(response.data);
  }
}
