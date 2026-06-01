import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/product.dart';
import 'package:sales/services/api_exception.dart';

class ProductService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Product>> all() async {
    final url = Uri.http(apiUrl, '/product/products/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse
          .map((productJson) => Product.fromJson(productJson))
          .toList();
    }

    throw ApiException.fromResponse('Error al cargar productos', response.body);
  }

  Future<Product> getById(int id) async {
    final url = Uri.http(apiUrl, '/product/products/$id/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      return Product.fromJson(jsonResponse);
    }

    throw ApiException.fromResponse('Error al cargar producto', response.body);
  }

  Future<void> save(Product product) async {
    final url = Uri.http(apiUrl, '/product/products/');
    final response = await http.post(
      url,
      body: convert.jsonEncode(product.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw ApiException.fromResponse(
        'Error al guardar producto',
        response.body,
      );
    }
  }

  Future<void> edit(int id, Product product) async {
    final url = Uri.http(apiUrl, '/product/products/$id/');
    final response = await http.put(
      url,
      body: convert.jsonEncode(product.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        'Error al editar producto',
        response.body,
      );
    }
  }

  Future<void> delete(int id) async {
    final url = Uri.http(apiUrl, '/product/products/$id/');
    final response = await http.delete(url);

    if (response.statusCode != 204 && response.statusCode != 404) {
      throw ApiException.fromResponse(
        'Error al eliminar producto',
        response.body,
      );
    }
  }
}
