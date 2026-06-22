import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/feature/cart/data/model/cart_model.dart';
import 'package:shop_app/feature/products/data/model/product_model.dart';
import 'package:shop_app/feature/products/domain/entities/product_entity.dart';


abstract interface class CartLocalSource {
  Future<List<CartItemModel>> getItems();
  Future<void> saveItems(List<CartItemModel> items);
}

class CartLocalSourceImpl implements CartLocalSource {
  static const _key = 'shop_cart_v1';
  final SharedPreferences _prefs;

  CartLocalSourceImpl(this._prefs);

  @override
  Future<List<CartItemModel>> getItems() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return CartItemModel.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveItems(List<CartItemModel> items) async {
    await _prefs.setString(_key, CartItemModel.encodeList(items));
  }
}

extension on Product {
  ProductModel toModel() => ProductModel(
        id: id,
        title: title,
        price: price,
        description: description,
        category: category,
        imageUrl: imageUrl,
        rating: rating,
        ratingCount: ratingCount,
      );
}