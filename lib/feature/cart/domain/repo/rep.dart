import 'package:shop_app/feature/cart/presnetation/widget/cart_item.dart';
import 'package:shop_app/feature/products/domains/entities/product_entity.dart';


abstract interface class CartRepository {
  Future<List<CartItem>> getItems();
  Future<void> addItem(Product product);
  Future<void> removeItem(int productId);
  Future<void> updateQuantity(int productId, int quantity);
  Future<void> clear();
}