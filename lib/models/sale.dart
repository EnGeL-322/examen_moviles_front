import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';

class SaleDetail {
  final int id;
  final Product product;
  final int quantity;
  final double price;
  final double subtotal;

  SaleDetail(this.id, this.product, this.quantity, this.price, this.subtotal);

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      json['id'] as int,
      Product.fromJson(json['product']),
      json['quantity'] as int,
      double.parse(json['price'].toString()),
      double.parse(json['subtotal'].toString()),
    );
  }
}

class SaleCartItem {
  final Product product;
  final int quantity;

  SaleCartItem(this.product, this.quantity);

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.id,
      'quantity': quantity,
    };
  }
}

class Sale {
  final int id;
  final DateTime createdAt;
  final double subtotal;
  final double igv;
  final double total;
  final Client client;
  final List<SaleDetail> details;

  Sale(
    this.id,
    this.createdAt,
    this.subtotal,
    this.igv,
    this.total,
    this.client,
    this.details,
  );

  String get productsSummary {
    if (details.isEmpty) return 'Sin productos';
    return details
        .map((detail) => '${detail.quantity} x ${detail.product.name}')
        .join(', ');
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'] as List<dynamic>;

    return Sale(
      json['id'] as int,
      DateTime.parse(json['created_at'].toString()),
      double.parse(json['subtotal'].toString()),
      double.parse(json['igv'].toString()),
      double.parse(json['total'].toString()),
      Client.fromJson(json['client']),
      detailsJson
          .map((detailJson) => SaleDetail.fromJson(detailJson))
          .toList(),
    );
  }
}
