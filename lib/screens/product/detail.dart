import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/product.dart';
import 'package:sales/providers/product_provider.dart';
import 'package:sales/screens/product/form.dart';

class ProductDetailScreen extends StatefulWidget {
  final int idProduct;

  const ProductDetailScreen({super.key, required this.idProduct});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _findProduct(List<Product> products) {
    for (final product in products) {
      if (product.id == widget.idProduct) return product;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final product = _findProduct(products);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Producto"),
        backgroundColor: Colors.orange,
      ),
      body: product == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [const Text("ID: "), Text(product.id.toString())]),
                  Row(children: [const Text("Nombre: "), Text(product.name)]),
                  Row(
                    children: [
                      const Text("Categoria: "),
                      Text(product.category.name),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Precio: "),
                      Text(product.price.toString()),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Descripcion: "),
                      Text(product.description),
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
                              .read<ProductProvider>()
                              .delete(product.id);
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
                                  ProductFormScreen(product: product),
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
