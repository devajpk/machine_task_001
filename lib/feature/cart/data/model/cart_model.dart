import 'dart:convert';
import 'package:shop_app/feature/cart/presnetation/widget/cart_item.dart';
import 'package:shop_app/feature/products/data/model/product_model.dart';


class CartItemModel extends CartItem {
  const CartItemModel({
    required super.product,
    required super.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'product': (product as ProductModel).toJson(),
        'quantity': quantity,
      };

  static CartItemModel fromEntity(CartItem item) => CartItemModel(
        product: item.product,
        quantity: item.quantity,
      );

  static String encodeList(List<CartItemModel> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<CartItemModel> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}