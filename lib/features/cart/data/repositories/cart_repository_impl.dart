import 'package:ecommerce_app/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;
  List<CartItem> _items = [];

  CartRepositoryImpl(this._localDataSource) {
    _items = _localDataSource.getCartItems();
  }

  @override
  List<CartItem> getCartItems() => List.unmodifiable(_items);

  @override
  void addToCart(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(item);
    }
    _localDataSource.saveCartItems(_items);
  }

  @override
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    _localDataSource.saveCartItems(_items);
  }

  @override
  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      _localDataSource.saveCartItems(_items);
    }
  }

  @override
  void clearCart() {
    _items.clear();
    _localDataSource.clearCart();
  }

  @override
  bool isInCart(int productId) {
    return _items.any((item) => item.productId == productId);
  }
}
