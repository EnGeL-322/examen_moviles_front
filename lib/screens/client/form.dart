import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/client.dart';
import 'package:sales/providers/client_provider.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDocumentNumber = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    if (client != null) {
      controllerName.text = client.name;
      controllerDocumentNumber.text = client.documentNumber;
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerDocumentNumber.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    final name = controllerName.text.trim();
    final documentNumber = controllerDocumentNumber.text.trim();
    final isEditing = widget.client != null;

    if (name.isEmpty || documentNumber.isEmpty) {
      _showMessage('Completa todos los campos');
      return;
    }

    setState(() => _saving = true);

    try {
      final provider = context.read<ClientProvider>();
      if (isEditing) {
        await provider.edit(
          widget.client!.id,
          Client(
            widget.client!.id,
            name,
            documentNumber,
            false,
            widget.client!.serverId,
          ),
        );
      } else {
        await provider.save(Client(0, name, documentNumber, false, null));
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
    final isEditing = widget.client != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Formulario de Cliente'),
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
              controller: controllerDocumentNumber,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Numero de documento',
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
