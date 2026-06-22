import 'package:shop_app/features/products/data/sources/product_remote_source.dart';
import 'package:shop_app/features/products/domain/entities/product.dart';
import 'package:shop_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteSource _remote;

  ProductRepositoryImpl(this._remote);

  @override
  Future<List<Product>> getProducts({String? category}) =>
      _remote.getProducts(category: category)

  @override
  Future<List<String>> getCategories() => _remote.getCategories();
}