import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/sale.dart';
import 'package:sales/services/api_exception.dart';

class SaleService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Sale>> all() async {
    final url = Uri.http(apiUrl, '/sale/sales/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse.map((saleJson) => Sale.fromJson(saleJson)).toList();
    }

    throw ApiException.fromResponse('Error al cargar ventas', response.body);
  }

  Future<Sale> save(Client client, List<SaleCartItem> items) async {
    final url = Uri.http(apiUrl, '/sale/sales/');
    final response = await http.post(
      url,
      body: convert.jsonEncode({
        'client': client.serverId ?? client.id,
        'details': items.map((item) => item.toJson()).toList(),
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw ApiException.fromResponse('Error al guardar venta', response.body);
    }

    final jsonResponse = convert.jsonDecode(response.body);
    return Sale.fromJson(jsonResponse);
  }
}
