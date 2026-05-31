import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/supplier.dart';
import 'package:sales/providers/supplier_provider.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRuc = TextEditingController();
  final TextEditingController controllerPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    if (supplier != null) {
      controllerName.text = supplier.name;
      controllerRuc.text = supplier.ruc;
      controllerPhone.text = supplier.phone;
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerRuc.dispose();
    controllerPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Proveedor' : 'Formulario de Proveedor'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: controllerName,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerRuc,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'RUC',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefono',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (controllerName.text.trim().isEmpty ||
                    controllerRuc.text.trim().isEmpty ||
                    controllerPhone.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos')),
                  );
                  return;
                }

                final supplier = Supplier(
                  widget.supplier?.id ?? 0,
                  controllerName.text.trim(),
                  controllerRuc.text.trim(),
                  controllerPhone.text.trim(),
                  false,
                  widget.supplier?.serverId,
                );

                if (isEditing) {
                  await context
                      .read<SupplierProvider>()
                      .edit(widget.supplier!.id, supplier);
                } else {
                  await context.read<SupplierProvider>().save(supplier);
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Editar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
