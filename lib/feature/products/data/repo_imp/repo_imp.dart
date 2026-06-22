import 'package:shop_app/feature/products/data/remote_data_sorce/remote_data_source.dart';
import 'package:shop_app/feature/products/domain/rep/repo.dart';
import 'package:shop_app/feature/products/domains/entities/product_entity.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteSource _remote;

  ProductRepositoryImpl(this._remote);

  @override
  Future<List<Product>> getProducts({String? category}) =>
      _remote.getProducts(category: category);

  @override
  Future<List<String>> getCategories() => _remote.getCategories();
}
