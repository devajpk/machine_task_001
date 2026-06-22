import 'package:shop_app/features/cart/domain/entities/cart_item.dart';
import 'package:shop_app/features/products/domain/entities/product.dart';

abstract interface class CartRepository {
  Future<List<CartItem>> getItems();
  Future<void> addItem(Product product);
  Future<void> removeItem(int productId);
  Future<void> updateQuantity(int productId, int quantity);
  Future<void> clear();
}