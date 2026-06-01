import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/services/client_service.dart';
import 'package:sales/services/product_service.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final ClientService _clientService = ClientService();
  final ProductService _productService = ProductService();

  List<Client> _clients = [];
  List<Product> _products = [];
  Client? _selectedClient;
  Product? _selectedProduct;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final clients = await _clientService.all();
      final products = await _productService.all();

      if (!mounted) return;
      setState(() {
        _clients = clients;
        _products = products;
        _selectedClient = clients.isNotEmpty ? clients.first : null;
        _selectedProduct = products.isNotEmpty ? products.first : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    if (_selectedClient == null || _selectedProduct == null) {
      _showMessage('Selecciona un cliente y un producto');
      return;
    }

    setState(() => _saving = true);

    try {
      await context.read<SaleProvider>().save(
        _selectedClient!,
        _selectedProduct!,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Venta'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
                    children: [
                      DropdownButtonFormField<Client>(
                        initialValue: _selectedClient,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          border: OutlineInputBorder(),
                        ),
                        items: _clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client,
                                child: Text(client.name),
                              ),
                            )
                            .toList(),
                        onChanged: (client) {
                          setState(() => _selectedClient = client);
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<Product>(
                        initialValue: _selectedProduct,
                        decoration: const InputDecoration(
                          labelText: 'Producto',
                          border: OutlineInputBorder(),
                        ),
                        items: _products
                            .map(
                              (product) => DropdownMenuItem(
                                value: product,
                                child: Text(
                                  '${product.name} - S/ ${product.price.toStringAsFixed(2)}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (product) {
                          setState(() => _selectedProduct = product);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Total',
                          border: const OutlineInputBorder(),
                          hintText: _selectedProduct == null
                              ? 'S/ 0.00'
                              : 'S/ ${(_selectedProduct!.price * 1.18).toStringAsFixed(2)}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Guardando...' : 'Guardar'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
