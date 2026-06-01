import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/category.dart';
import 'package:sales/providers/category_provider.dart';
import 'package:sales/screens/category/form.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int idCategory;

  const CategoryDetailScreen({super.key, required this.idCategory});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  Category? _findCategory(List<Category> categories) {
    for (final category in categories) {
      if (category.id == widget.idCategory) return category;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final category = _findCategory(categories);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Categorias"),
        backgroundColor: Colors.orange,
      ),
      body: category == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [const Text("ID: "), Text(category.id.toString())]),
                  Row(children: [const Text("Nombre: "), Text(category.name)]),
                  Row(
                    children: [
                      const Text("Descripcion: "),
                      Text(category.description),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.red),
                        ),
                        onPressed: () async {
                          await context
                              .read<CategoryProvider>()
                              .delete(category.id);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Eliminar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoryFormScreen(category: category),
                            ),
                          );
                        },
                        child: const Text("Editar"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
