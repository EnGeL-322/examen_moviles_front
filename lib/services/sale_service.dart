import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';
import 'package:sales/models/sale.dart';

class SaleService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Sale>> all() async {
    final url = Uri.http(apiUrl, '/sale/sales/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse.map((saleJson) => Sale.fromJson(saleJson)).toList();
    }

    throw Exception('Error al cargar ventas');
  }

  Future<void> save(Client client, Product product) async {
    final url = Uri.http(apiUrl, '/sale/sales/');
    final response = await http.post(
      url,
      body: convert.jsonEncode({
        'client': client.serverId ?? client.id,
        'details': [
          {
            'product': product.id,
            'quantity': 1,
          }
        ],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Error al guardar venta');
    }
  }
}
