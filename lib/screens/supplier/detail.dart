import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/supplier_provider.dart';
import 'package:sales/screens/supplier/form.dart';

class SupplierDetailScreen extends StatelessWidget {
  final int idSupplier;

  const SupplierDetailScreen({super.key, required this.idSupplier});

  @override
  Widget build(BuildContext context) {
    final supplier = context.watch<SupplierProvider>().getById(idSupplier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Proveedor'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID local: ${supplier.id}'),
            Text('ID API: ${supplier.serverId ?? '-'}'),
            Text('Nombre: ${supplier.name}'),
            Text('RUC: ${supplier.ruc}'),
            Text('Telefono: ${supplier.phone}'),
            Text(
              'Estado: ${supplier.isSynced ? 'Sincronizado' : 'Pendiente'}',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                  ),
                  onPressed: () async {
                    await context.read<SupplierProvider>().delete(supplier);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SupplierFormScreen(supplier: supplier),
                      ),
                    );
                  },
                  child: const Text('Editar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
