

import 'package:shop_app/feature/cart/data/cart_remote_data_Source/cart_remote_data_source.dart';
import 'package:shop_app/feature/cart/data/model/cart_model.dart';
import 'package:shop_app/feature/cart/domain/repo/rep.dart';
import 'package:shop_app/feature/cart/presnetation/widget/cart_item.dart';
import 'package:shop_app/feature/products/data/model/product_model.dart';
import 'package:shop_app/feature/products/domain/entities/product_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalSource _local;
  // In-memory cache so BLoC events are synchronous after the first load.
  List<CartItemModel> _cache = [];
  bool _loaded = false;

  CartRepositoryImpl(this._local);

  Future<void> _ensureLoaded() async {
    if (!_loaded) {
      _cache = await _local.getItems();
      _loaded = true;
    }
  }

  Future<void> _persist() => _local.saveItems(_cache);

  @override
  Future<List<CartItem>> getItems() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  @override
  Future<void> addItem(Product product) async {
    await _ensureLoaded();
    final idx = _cache.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _cache[idx] =
          CartItemModel(product: _cache[idx].product, quantity: _cache[idx].quantity + 1);
    } else {
      _cache.add(CartItemModel(product: _toModel(product), quantity: 1));
    }
    await _persist();
  }

  @override
  Future<void> removeItem(int productId) async {
    await _ensureLoaded();
    _cache.removeWhere((i) => i.product.id == productId);
    await _persist();
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    await _ensureLoaded();
    if (quantity <= 0) {
      return removeItem(productId);
    }
    final idx = _cache.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      _cache[idx] =
          CartItemModel(product: _cache[idx].product, quantity: quantity);
    }
    await _persist();
  }

  @override
  Future<void> clear() async {
    _cache = [];
    await _persist();
  }

  ProductModel _toModel(Product p) => ProductModel(
        id: p.id,
        title: p.title,
        price: p.price,
        description: p.description,
        category: p.category,
        imageUrl: p.imageUrl,
        rating: p.rating,
        ratingCount: p.ratingCount,
      );
}