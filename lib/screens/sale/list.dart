import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/screens/sale/form.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SaleProvider>().loadAll();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SaleProvider>().sales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Ventas'),
        backgroundColor: Colors.orange,
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SaleFormScreen()),
          );
          if (!context.mounted) return;
          context.read<SaleProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: sales.isEmpty
          ? const Center(child: Text('No hay ventas registradas'))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(
                    '${_formatDate(sale.createdAt)} - S/ ${sale.total.toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    'Cliente: ${sale.client.name}\nProducto: ${sale.product.name}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
