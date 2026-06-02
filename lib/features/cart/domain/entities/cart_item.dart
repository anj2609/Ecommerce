class CartItem {
  final int productId;
  final String title;
  final String thumbnail;
  final double price;
  final double discountPercentage;
  final String brand;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.discountPercentage,
    required this.brand,
    this.quantity = 1,
  });

  double get discountedPrice => price - (price * discountPercentage / 100);
  double get totalPrice => discountedPrice * quantity;
  double get totalDiscount => (price * discountPercentage / 100) * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? 0,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      brand: json['brand'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'thumbnail': thumbnail,
      'price': price,
      'discountPercentage': discountPercentage,
      'brand': brand,
      'quantity': quantity,
    };
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      title: title,
      thumbnail: thumbnail,
      price: price,
      discountPercentage: discountPercentage,
      brand: brand,
      quantity: quantity ?? this.quantity,
    );
  }
}
