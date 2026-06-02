import 'dart:convert';
import 'package:ecommerce_app/core/storage/local_storage.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class ProductLocalDataSource {
  void cacheProducts(List<Product> products) {
    final jsonList = products.map((p) => p.toJson()).toList();
    LocalStorage.productsBox.put('cached_products', jsonEncode(jsonList));
  }

  List<Product> getCachedProducts() {
    final data = LocalStorage.productsBox.get('cached_products');
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  bool get hasCachedProducts {
    return LocalStorage.productsBox.containsKey('cached_products');
  }
}
