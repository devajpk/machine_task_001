import 'package:shop_app/features/products/domain/entities/product.dart';
 
abstract interface class ProductRepository {
  Future<List<Product>> getProducts({String? category});
  Future<List<String>> getCategories();
}