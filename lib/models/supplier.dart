class Supplier {
  final int id;
  final String name;
  final String ruc;
  final String phone;
  final bool isSynced;
  final int? serverId;

  Supplier(
    this.id,
    this.name,
    this.ruc,
    this.phone,
    this.isSynced,
    this.serverId,
  );

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      map['id'],
      map['name'].toString(),
      map['ruc'].toString(),
      map['phone'].toString(),
      map['is_synced'] == 1,
      map['server_id'] as int?,
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      0,
      json['name'].toString(),
      json['ruc'].toString(),
      json['phone'].toString(),
      true,
      json['id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'ruc': ruc,
      'phone': phone,
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  Map<String, dynamic> toApiMap() {
    return {
      'name': name,
      'ruc': ruc,
      'phone': phone,
    };
  }
}
