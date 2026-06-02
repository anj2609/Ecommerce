class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final double weight;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final String thumbnail;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.thumbnail,
    required this.images,
  });

  double get discountedPrice => price - (price * discountPercentage / 100);

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      brand: json['brand'] ?? 'Unknown',
      sku: json['sku'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      warrantyInformation: json['warrantyInformation'] ?? '',
      shippingInformation: json['shippingInformation'] ?? '',
      availabilityStatus: json['availabilityStatus'] ?? '',
      returnPolicy: json['returnPolicy'] ?? '',
      minimumOrderQuantity: json['minimumOrderQuantity'] ?? 1,
      thumbnail: json['thumbnail'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'thumbnail': thumbnail,
      'images': images,
    };
  }
}
