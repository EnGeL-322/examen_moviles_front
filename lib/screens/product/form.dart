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
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().loadAll();

    final product = widget.product;
    if (product != null) {
      controllerName.text = product.name;
      controllerDescription.text = product.description;
      controllerPrice.text = product.price.toString();
      selectedCategoryId = product.category.id;
    }
  }

  int? _currentCategoryId(List<Category> categories) {
    if (categories.isEmpty) return null;
    final hasSelected = categories.any((cat) => cat.id == selectedCategoryId);
    return hasSelected ? selectedCategoryId : categories.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final currentCategoryId = _currentCategoryId(categories);

    return Scaffold(
      appBar: AppBar(
        title: Text("Formulario de Producto"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            if (categories.isEmpty)
              CircularProgressIndicator()
            else
              DropdownButton<int>(
                value: currentCategoryId,
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
            SizedBox(height: 10),
            TextField(
              controller: controllerName,
              decoration: InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controllerPrice,
              decoration: InputDecoration(
                labelText: "Precio",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: controllerDescription,
              decoration: InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: currentCategoryId == null
                  ? null
                  : () async {
                final selectedCategory = categories.firstWhere(
                  (cat) => cat.id == currentCategoryId,
                );
                if (widget.product == null) {
                  await context.read<ProductProvider>().save(
                    Product(
                      0,
                      controllerName.text,
                      double.parse(controllerPrice.text),
                      controllerDescription.text,
                      selectedCategory,
                    ),
                  );
                } else {
                  await context.read<ProductProvider>().edit(
                    widget.product!.id,
                    Product(
                      widget.product!.id,
                      controllerName.text,
                      double.parse(controllerPrice.text),
                      controllerDescription.text,
                      selectedCategory,
                    ),
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(widget.product == null ? "Crear" : "Editar"),
            ),
          ],
        ),
      ),
    );
  }
}
