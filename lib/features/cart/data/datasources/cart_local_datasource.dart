import 'dart:convert';
import 'package:ecommerce_app/core/storage/local_storage.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';

class CartLocalDataSource {
  static const String _cartKey = 'cart_items';

  List<CartItem> getCartItems() {
    final data = LocalStorage.cartBox.get(_cartKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => CartItem.fromJson(json)).toList();
  }

  void saveCartItems(List<CartItem> items) {
    final jsonList = items.map((item) => item.toJson()).toList();
    LocalStorage.cartBox.put(_cartKey, jsonEncode(jsonList));
  }

  void clearCart() {
    LocalStorage.cartBox.delete(_cartKey);
  }
}
