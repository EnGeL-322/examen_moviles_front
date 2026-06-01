import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/category.dart';
import 'package:sales/models/product.dart';
import 'package:sales/providers/category_provider.dart';
import 'package:sales/providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  final TextEditingController controllerPrice = TextEditingController();
  int? selectedCategoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().loadAll().catchError((_) {});

    final product = widget.product;
    if (product != null) {
      controllerName.text = product.name;
      controllerDescription.text = product.description;
      controllerPrice.text = product.price.toString();
      selectedCategoryId = product.category.id;
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerDescription.dispose();
    controllerPrice.dispose();
    super.dispose();
  }

  int? _currentCategoryId(List<Category> categories) {
    if (categories.isEmpty) return null;
    final hasSelected = categories.any((cat) => cat.id == selectedCategoryId);
    return hasSelected ? selectedCategoryId : categories.first.id;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save(List<Category> categories, int? currentCategoryId) async {
    final name = controllerName.text.trim();
    final description = controllerDescription.text.trim();
    final price = double.tryParse(controllerPrice.text.trim());

    if (currentCategoryId == null) {
      _showMessage('Registra una categoria primero');
      return;
    }

    if (name.isEmpty || description.isEmpty || price == null || price <= 0) {
      _showMessage('Completa todos los campos con un precio valido');
      return;
    }

    final selectedCategory = categories.firstWhere(
      (cat) => cat.id == currentCategoryId,
    );

    setState(() => _saving = true);

    try {
      final product = Product(
        widget.product?.id ?? 0,
        name,
        price,
        description,
        selectedCategory,
      );
      final provider = context.read<ProductProvider>();

      if (widget.product == null) {
        await provider.save(product);
      } else {
        await provider.edit(widget.product!.id, product);
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
    final categories = context.watch<CategoryProvider>().categories;
    final currentCategoryId = _currentCategoryId(categories);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulario de Producto"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (categories.isEmpty)
              const Text('No hay categorias disponibles')
            else
              DropdownButtonFormField<int>(
                initialValue: currentCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map(
                      (cat) => DropdownMenuItem<int>(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    )
                    .toList(),
                onChanged: (categoryId) {
                  setState(() => selectedCategoryId = categoryId);
                },
              ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerName,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerPrice,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Precio",
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
              onPressed: _saving
                  ? null
                  : () => _save(categories, currentCategoryId),
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
