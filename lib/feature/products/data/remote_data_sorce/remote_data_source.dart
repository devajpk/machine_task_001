import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_app/features/products/data/models/product_model.dart';

abstract interface class ProductRemoteSource {
  Future<List<ProductModel>> getProducts({String? category});
  Future<List<String>> getCategories();
}

class ProductRemoteSourceImpl implements ProductRemoteSource {
  static const _base = 'https://fakestoreapi.com';
  final http.Client _client;

  ProductRemoteSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<ProductModel>> getProducts({String? category}) async {
    final path = category != null && category != 'all'
        ? '/products/category/${Uri.encodeComponent(category)}'
        : '/products';

    final response = await _client.get(Uri.parse('$_base$path'));
    _checkStatus(response);

    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final response =
        await _client.get(Uri.parse('$_base/products/categories'));
    _checkStatus(response);

    final list = jsonDecode(response.body) as List;
    return list.cast<String>();
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode != 200) {
      throw Exception(
          'API error ${res.statusCode}: ${res.reasonPhrase}');
    }
  }
}