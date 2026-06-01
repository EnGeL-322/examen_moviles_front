import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/category.dart';
import 'package:sales/services/api_exception.dart';

class CategoryService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Category>> all() async {
    final url = Uri.http(apiUrl, '/product/categories/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse
          .map((catJson) => Category.fromJson(catJson))
          .toList();
    }

    throw ApiException.fromResponse('Error al cargar categorias', response.body);
  }

  Future<Category> getById(int id) async {
    final url = Uri.http(apiUrl, '/product/categories/$id/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);
      return Category.fromJson(jsonResponse);
    }

    throw ApiException.fromResponse('Error al cargar categoria', response.body);
  }

  Future<void> save(Category category) async {
    final url = Uri.http(apiUrl, '/product/categories/');
    final response = await http.post(
      url,
      body: convert.jsonEncode(category.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw ApiException.fromResponse(
        'Error al guardar categoria',
        response.body,
      );
    }
  }

  Future<void> edit(int id, Category category) async {
    final url = Uri.http(apiUrl, '/product/categories/$id/');
    final response = await http.put(
      url,
      body: convert.jsonEncode(category.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(
        'Error al editar categoria',
        response.body,
      );
    }
  }

  Future<void> delete(int id) async {
    final url = Uri.http(apiUrl, '/product/categories/$id/');
    final response = await http.delete(url);

    if (response.statusCode != 204 && response.statusCode != 404) {
      throw ApiException.fromResponse(
        'Error al eliminar categoria',
        response.body,
      );
    }
  }
}
