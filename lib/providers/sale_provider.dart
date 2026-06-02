import 'package:flutter/material.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/sale.dart';
import 'package:sales/services/sale_service.dart';

class SaleProvider extends ChangeNotifier {
  List<Sale> _sales = [];

  List<Sale> get sales => _sales;

  final SaleService _service = SaleService();

  Future<void> loadAll() async {
    _sales = await _service.all();
    notifyListeners();
  }

  Future<Sale> save(Client client, List<SaleCartItem> items) async {
    final sale = await _service.save(client, items);
    await loadAll();
    return sale;
  }
}
