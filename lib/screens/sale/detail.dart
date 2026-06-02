import 'package:flutter/material.dart';
import 'package:sales/models/sale.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailScreen({super.key, required this.sale});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta #${sale.id}'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Cliente: ${sale.client.name}'),
          Text('Documento: ${sale.client.documentNumber}'),
          Text('Fecha: ${_formatDate(sale.createdAt)}'),
          const SizedBox(height: 12),
          const Text(
            'Productos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...sale.details.map(
            (detail) => Card(
              child: ListTile(
                title: Text(detail.product.name),
                subtitle: Text(
                  '${detail.quantity} x S/ ${detail.price.toStringAsFixed(2)}',
                ),
                trailing: Text('S/ ${detail.subtotal.toStringAsFixed(2)}'),
              ),
            ),
          ),
          const Divider(),
          _TotalRow(label: 'Subtotal', value: sale.subtotal),
          _TotalRow(label: 'IGV', value: sale.igv),
          _TotalRow(label: 'Total', value: sale.total, bold: true),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 18 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('S/ ${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
