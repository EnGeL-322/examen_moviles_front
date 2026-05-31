import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';

class Sale {
  final int id;
  final DateTime createdAt;
  final double total;
  final Client client;
  final Product product;

  Sale(this.id, this.createdAt, this.total, this.client, this.product);

  factory Sale.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as List<dynamic>;
    final firstDetail = details.first as Map<String, dynamic>;

    return Sale(
      json['id'] as int,
      DateTime.parse(json['created_at'].toString()),
      double.parse(json['total'].toString()),
      Client.fromJson(json['client']),
      Product.fromJson(firstDetail['product']),
    );
  }
}
