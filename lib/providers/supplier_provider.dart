import 'package:flutter/material.dart';
import 'package:sales/database/database_helper.dart';
import 'package:sales/models/supplier.dart';
import 'package:sales/services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _suppliers = [];

  List<Supplier> get suppliers => _suppliers;

  final DatabaseHelper _db = DatabaseHelper();
  final SupplierService _service = SupplierService();

  Future<void> loadAll() async {
    try {
      final apiSuppliers = await _service.all();
      for (final supplier in apiSuppliers) {
        await _db.upsertProviderFromApi(supplier.toMap());
      }
    } catch (_) {
      // Offline-first: si no hay conexion, se conserva la lista local.
    }

    final rows = await _db.queryAllProviders();
    _suppliers = rows.map((row) => Supplier.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> save(Supplier supplier) async {
    await _db.insertProvider(supplier.toMap());
    await loadAll();
  }

  Future<void> edit(int id, Supplier supplier) async {
    await _db.updateProvider(id, {
      'name': supplier.name,
      'ruc': supplier.ruc,
      'phone': supplier.phone,
      'is_synced': 0,
      'server_id': supplier.serverId,
    });
    await loadAll();
  }

  Supplier getById(int id) {
    return _suppliers.firstWhere((supplier) => supplier.id == id);
  }

  Future<void> delete(Supplier supplier) async {
    if (supplier.isSynced && supplier.serverId != null) {
      await _service.delete(supplier.serverId!);
    }
    await _db.deleteProvider(supplier.id);
    await loadAll();
  }

  Future<Map<String, int>> sincronizar() async {
    final rows = await _db.queryPendingProviders();
    final pending = rows.map((row) => Supplier.fromMap(row)).toList();

    int sincronizados = 0;
    int actualizados = 0;
    int duplicados = 0;
    int errores = 0;

    for (final supplier in pending) {
      if (supplier.serverId == null) {
        final (result, serverId) = await _service.save(supplier);
        if (result == SupplierSyncResult.created && serverId != null) {
          await _db.updateProviderSynced(supplier.id, serverId);
          sincronizados++;
        } else if (result == SupplierSyncResult.duplicate) {
          duplicados++;
        } else {
          errores++;
        }
      } else {
        final result = await _service.edit(supplier);
        if (result == SupplierSyncResult.updated) {
          await _db.updateProviderSyncedOnly(supplier.id);
          actualizados++;
        } else if (result == SupplierSyncResult.duplicate) {
          duplicados++;
        } else {
          errores++;
        }
      }
    }

    await loadAll();
    return {
      'sincronizados': sincronizados,
      'actualizados': actualizados,
      'duplicados': duplicados,
      'errores': errores,
    };
  }
}
