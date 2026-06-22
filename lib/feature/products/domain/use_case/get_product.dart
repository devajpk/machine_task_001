import 'package:shop_app/features/products/domain/entities/product.dart';
import 'package:shop_app/features/products/domain/repositories/product_repository.dart';

class GetProducts {
  final ProductRepository _repo;
  GetProducts(this._repo);

  Future<List<Product>> call({String? category}) =>
      _repo.getProducts(category: category);
}