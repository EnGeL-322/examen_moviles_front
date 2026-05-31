import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/supplier.dart';

enum SupplierSyncResult { created, updated, duplicate, error }

class SupplierService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Supplier>> all() async {
    final url = Uri.http(apiUrl, '/provider/providers/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse
          .map((supplierJson) => Supplier.fromJson(supplierJson))
          .toList();
    }

    throw Exception('Error al cargar proveedores');
  }

  Future<(SupplierSyncResult, int?)> save(Supplier supplier) async {
    final url = Uri.http(apiUrl, '/provider/providers/');
    final response = await http.post(
      url,
      body: convert.jsonEncode(supplier.toApiMap()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final json = convert.jsonDecode(response.body);
      return (SupplierSyncResult.created, json['id'] as int);
    }

    if (response.statusCode == 400) {
      return (SupplierSyncResult.duplicate, null);
    }

    return (SupplierSyncResult.error, null);
  }

  Future<SupplierSyncResult> edit(Supplier supplier) async {
    final url = Uri.http(apiUrl, '/provider/providers/${supplier.serverId}/');
    final response = await http.put(
      url,
      body: convert.jsonEncode(supplier.toApiMap()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) return SupplierSyncResult.updated;
    if (response.statusCode == 400) return SupplierSyncResult.duplicate;
    return SupplierSyncResult.error;
  }

  Future<void> delete(int serverId) async {
    final url = Uri.http(apiUrl, '/provider/providers/$serverId/');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar proveedor');
    }
  }
}
