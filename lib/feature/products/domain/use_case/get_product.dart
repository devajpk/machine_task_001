import 'package:shop_app/feature/products/domain/entities/product_entity.dart';
import 'package:shop_app/feature/products/domain/rep/repo.dart';



class GetProducts {
  final ProductRepository _repo;
  GetProducts(this._repo);

  Future<List<Product>> call({String? category}) =>
      _repo.getProducts(category: category);
}