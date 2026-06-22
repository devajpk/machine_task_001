import 'package:shop_app/feature/products/domain/rep/repo.dart';


class GetCategories {
  final ProductRepository _repo;
  GetCategories(this._repo);

  Future<List<String>> call() => _repo.getCategories();
}