import 'package:shop_app/feature/products/domain/entities/product_entity.dart';

 
abstract interface class ProductRepository {
  Future<List<Product>> getProducts({String? category});
  Future<List<String>> getCategories();
}