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
  bool _saving = false;

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    final name = controllerName.text.trim();
    final ruc = controllerRuc.text.trim();
    final phone = controllerPhone.text.trim();
    final isEditing = widget.supplier != null;

    if (name.isEmpty || ruc.isEmpty || phone.isEmpty) {
      _showMessage('Completa todos los campos');
      return;
    }

    setState(() => _saving = true);

    try {
      final supplier = Supplier(
        widget.supplier?.id ?? 0,
        name,
        ruc,
        phone,
        false,
        widget.supplier?.serverId,
      );

      final provider = context.read<SupplierProvider>();
      if (isEditing) {
        await provider.edit(widget.supplier!.id, supplier);
      } else {
        await provider.save(supplier);
      }

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
              onPressed: _saving ? null : _save,
              child: Text(
                _saving ? 'Guardando...' : (isEditing ? 'Editar' : 'Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
