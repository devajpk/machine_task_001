import 'package:shop_app/feature/cart/domain/repo/rep.dart';
import 'package:shop_app/feature/cart/presnetation/widget/cart_item.dart';
import 'package:shop_app/feature/products/domains/entities/product_entity.dart';


class GetCartItems {
  final CartRepository _repo;
  GetCartItems(this._repo);
  Future<List<CartItem>> call() => _repo.getItems();
}

class AddToCart {
  final CartRepository _repo;
  AddToCart(this._repo);
  Future<void> call(Product product) => _repo.addItem(product);
}

class RemoveFromCart {
  final CartRepository _repo;
  RemoveFromCart(this._repo);
  Future<void> call(int productId) => _repo.removeItem(productId);
}

class UpdateQuantity {
  final CartRepository _repo;
  UpdateQuantity(this._repo);
  Future<void> call(int productId, int quantity) =>
      _repo.updateQuantity(productId, quantity);
}

class ClearCart {
  final CartRepository _repo;
  ClearCart(this._repo);
  Future<void> call() => _repo.clear();
}