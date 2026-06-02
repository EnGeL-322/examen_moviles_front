import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/client.dart';
import 'package:sales/models/product.dart';
import 'package:sales/models/sale.dart';
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
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  List<Client> _clients = [];
  List<Product> _products = [];
  final List<SaleCartItem> _cart = [];
  Client? _selectedClient;
  int? _selectedProductId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  double get _subtotal {
    return _cart.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get _igv => _subtotal * 0.18;

  double get _total => _subtotal + _igv;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
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
        _selectedProductId = products.isNotEmpty ? products.first.id : null;
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

  Product? _selectedProduct() {
    for (final product in _products) {
      if (product.id == _selectedProductId) return product;
    }
    return null;
  }

  void _addProduct() {
    final product = _selectedProduct();
    final quantity = int.tryParse(_quantityController.text.trim());

    if (product == null) {
      _showMessage('Selecciona un producto');
      return;
    }

    if (quantity == null || quantity <= 0) {
      _showMessage('Ingresa una cantidad valida');
      return;
    }

    final existingIndex = _cart.indexWhere(
      (item) => item.product.id == product.id,
    );

    setState(() {
      if (existingIndex >= 0) {
        final existing = _cart[existingIndex];
        _cart[existingIndex] = SaleCartItem(
          existing.product,
          existing.quantity + quantity,
        );
      } else {
        _cart.add(SaleCartItem(product, quantity));
      }
      _quantityController.text = '1';
    });
  }

  void _changeQuantity(int index, int delta) {
    final item = _cart[index];
    final newQuantity = item.quantity + delta;

    setState(() {
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index] = SaleCartItem(item.product, newQuantity);
      }
    });
  }

  Future<void> _save() async {
    if (_selectedClient == null) {
      _showMessage('Selecciona un cliente');
      return;
    }

    if (_cart.isEmpty) {
      _showMessage('Agrega al menos un producto al carrito');
      return;
    }

    setState(() => _saving = true);

    try {
      final sale = await context.read<SaleProvider>().save(
        _selectedClient!,
        _cart,
      );

      if (!mounted) return;
      Navigator.pop(context, sale);
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
                        isExpanded: true,
                        initialValue: _selectedClient,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          border: OutlineInputBorder(),
                        ),
                        items: _clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client,
                                child: Text(
                                  client.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (client) {
                          setState(() => _selectedClient = client);
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              initialValue: _selectedProductId,
                              decoration: const InputDecoration(
                                labelText: 'Producto',
                                border: OutlineInputBorder(),
                              ),
                              items: _products
                                  .map(
                                    (product) => DropdownMenuItem(
                                      value: product.id,
                                      child: Text(
                                        '${product.name} - S/ ${product.price.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (productId) {
                                setState(() => _selectedProductId = productId);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 78,
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Cant.',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addProduct,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Agregar al carrito'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _cart.isEmpty
                            ? const Center(
                                child: Text('Agrega productos al carrito'),
                              )
                            : ListView.builder(
                                itemCount: _cart.length,
                                itemBuilder: (context, index) {
                                  final item = _cart[index];
                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        'S/ ${item.product.price.toStringAsFixed(2)} x ${item.quantity} = S/ ${item.subtotal.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: SizedBox(
                                        width: 128,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () =>
                                                  _changeQuantity(index, -1),
                                              icon: const Icon(Icons.remove),
                                            ),
                                            Text(item.quantity.toString()),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () =>
                                                  _changeQuantity(index, 1),
                                              icon: const Icon(Icons.add),
                                            ),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              onPressed: () {
                                                setState(
                                                  () => _cart.removeAt(index),
                                                );
                                              },
                                              icon: const Icon(Icons.delete),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const Divider(),
                      _SummaryRow(
                        label: 'Subtotal',
                        value: _subtotal,
                      ),
                      _SummaryRow(
                        label: 'IGV',
                        value: _igv,
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: _total,
                        bold: true,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: const Icon(Icons.save),
                          label: Text(_saving ? 'Guardando...' : 'Guardar'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 18 : 14,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('S/ ${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
