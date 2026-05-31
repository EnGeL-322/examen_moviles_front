import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/supplier_provider.dart';
import 'package:sales/screens/supplier/detail.dart';
import 'package:sales/screens/supplier/form.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    context.read<SupplierProvider>().loadAll();
  }

  Future<void> _sincronizar() async {
    setState(() => _syncing = true);
    final messenger = ScaffoldMessenger.of(context);
    final result = await context.read<SupplierProvider>().sincronizar();

    if (!mounted) return;
    setState(() => _syncing = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Sincronizacion: ${result['sincronizados']} creados, '
          '${result['actualizados']} actualizados, '
          '${result['duplicados']} duplicados, ${result['errores']} errores',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = context.watch<SupplierProvider>().suppliers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Proveedores'),
        backgroundColor: Colors.orange,
        actions: [
          _syncing
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sincronizar',
                  onPressed: _sincronizar,
                ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupplierFormScreen()),
          );
          if (!context.mounted) return;
          context.read<SupplierProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: suppliers.isEmpty
          ? const Center(child: Text('No hay proveedores registrados'))
          : ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return ListTile(
                  leading: Icon(
                    supplier.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    color: supplier.isSynced ? Colors.green : Colors.red,
                  ),
                  title: Text(supplier.name),
                  subtitle: Text(
                    'RUC: ${supplier.ruc} - Tel: ${supplier.phone}',
                  ),
                  trailing: Chip(
                    label: Text(
                      supplier.isSynced ? 'Sincronizado' : 'Pendiente',
                    ),
                    backgroundColor: supplier.isSynced
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SupplierDetailScreen(idSupplier: supplier.id),
                      ),
                    );
                    if (!context.mounted) return;
                    context.read<SupplierProvider>().loadAll();
                  },
                );
              },
            ),
    );
  }
}
