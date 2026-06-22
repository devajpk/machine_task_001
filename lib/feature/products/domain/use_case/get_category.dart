import 'package:shop_app/features/products/domain/repositories/product_repository.dart';

class GetCategories {
  final ProductRepository _repo;
  GetCategories(this._repo);

  Future<List<String>> call() => _repo.getCategories();
}