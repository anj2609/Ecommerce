import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:ecommerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource();
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartLocalDataSourceProvider));
});

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get totalDiscount => items.fold(0.0, (sum, item) => sum + item.totalDiscount);

  double get totalPayable => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool isInCart(int productId) => items.any((item) => item.productId == productId);

  int getQuantity(int productId) {
    final item = items.where((item) => item.productId == productId);
    return item.isEmpty ? 0 : item.first.quantity;
  }

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartNotifier(this._repository)
      : super(CartState(items: _repository.getCartItems()));

  void addToCart(Product product) {
    final item = CartItem(
      productId: product.id,
      title: product.title,
      thumbnail: product.thumbnail,
      price: product.price,
      discountPercentage: product.discountPercentage,
      brand: product.brand,
    );
    _repository.addToCart(item);
    state = CartState(items: _repository.getCartItems());
  }

  void removeFromCart(int productId) {
    _repository.removeFromCart(productId);
    state = CartState(items: _repository.getCartItems());
  }

  void updateQuantity(int productId, int quantity) {
    _repository.updateQuantity(productId, quantity);
    state = CartState(items: _repository.getCartItems());
  }

  void incrementQuantity(int productId) {
    final current = state.getQuantity(productId);
    updateQuantity(productId, current + 1);
  }

  void decrementQuantity(int productId) {
    final current = state.getQuantity(productId);
    if (current > 1) {
      updateQuantity(productId, current - 1);
    } else {
      removeFromCart(productId);
    }
  }

  void clearCart() {
    _repository.clearCart();
    state = const CartState();
  }
}

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.watch(cartRepositoryProvider));
});
