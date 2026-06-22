import 'package:shop_app/features/products/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.imageUrl,
    required super.rating,
    required super.ratingCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'] as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['image'] as String,
      rating: (ratingMap['rate'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (ratingMap['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': imageUrl,
        'rating': {'rate': rating, 'count': ratingCount},
      };
}