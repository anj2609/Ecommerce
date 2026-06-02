import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class ProductsResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + limit < total;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      products: (json['products'] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
      total: json['total'] ?? 0,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
