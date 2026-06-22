import 'package:shop_app/feature/products/domain/rep/repo.dart';
import 'package:shop_app/feature/products/domains/entities/product_entity.dart';


class GetProducts {
  final ProductRepository _repo;
  GetProducts(this._repo);

  Future<List<Product>> call({String? category}) =>
      _repo.getProducts(category: category);
}