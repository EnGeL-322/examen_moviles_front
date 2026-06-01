import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:sales/models/category.dart";
import "package:sales/providers/category_provider.dart";

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    if (category != null) {
      controllerName.text = category.name;
      controllerDescription.text = category.description;
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerDescription.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    final name = controllerName.text.trim();
    final description = controllerDescription.text.trim();

    if (name.isEmpty || description.isEmpty) {
      _showMessage('Completa todos los campos');
      return;
    }

    setState(() => _saving = true);

    try {
      final provider = context.read<CategoryProvider>();
      if (widget.category == null) {
        await provider.save(Category(0, name, description));
      } else {
        await provider.edit(
          widget.category!.id,
          Category(widget.category!.id, name, description),
        );
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
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Categoria" : "Formulario"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: controllerName,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerDescription,
              decoration: const InputDecoration(
                labelText: "Descripcion",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving ? "Guardando..." : (isEditing ? "Editar" : "Crear"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
