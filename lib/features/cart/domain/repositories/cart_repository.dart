import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> getCartItems();
  void addToCart(CartItem item);
  void removeFromCart(int productId);
  void updateQuantity(int productId, int quantity);
  void clearCart();
  bool isInCart(int productId);
}
