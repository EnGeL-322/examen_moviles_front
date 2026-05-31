import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _dbName = 'sales.db';
  static const int _version = 3;
  static const String _clientTable = 'clients';
  static const String _providerTable = 'providers';

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_clientTable (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        name             TEXT NOT NULL,
        document_number  TEXT NOT NULL,
        is_synced        INTEGER NOT NULL DEFAULT 0,
        server_id        INTEGER
      )
    ''');
    await _createProviderTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_clientTable ADD COLUMN server_id INTEGER');
    }
    if (oldVersion < 3) {
      await _createProviderTable(db);
    }
  }

  Future<void> _createProviderTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_providerTable (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT NOT NULL,
        ruc         TEXT NOT NULL,
        phone       TEXT NOT NULL,
        is_synced   INTEGER NOT NULL DEFAULT 0,
        server_id   INTEGER
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(_clientTable, row);
  }

  Future<int> update(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      _clientTable,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;
    return await db.query(_clientTable, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> queryPending() async {
    final db = await database;
    return await db.query(
      _clientTable,
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<int> updateSynced(int id, int serverId) async {
    final db = await database;
    return await db.update(
      _clientTable,
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateSyncedOnly(int id) async {
    final db = await database;
    return await db.update(
      _clientTable,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      _clientTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_clientTable);
  }

  Future<int> insertProvider(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(_providerTable, row);
  }

  Future<int> updateProvider(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      _providerTable,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> queryAllProviders() async {
    final db = await database;
    return await db.query(_providerTable, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> queryPendingProviders() async {
    final db = await database;
    return await db.query(
      _providerTable,
      where: 'is_synced = ?',
      whereArgs: [0],
    );
  }

  Future<int> updateProviderSynced(int id, int serverId) async {
    final db = await database;
    return await db.update(
      _providerTable,
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateProviderSyncedOnly(int id) async {
    final db = await database;
    return await db.update(
      _providerTable,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> upsertProviderFromApi(Map<String, dynamic> row) async {
    final db = await database;
    final serverId = row['server_id'];
    final existing = await db.query(
      _providerTable,
      where: 'server_id = ?',
      whereArgs: [serverId],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert(_providerTable, row);
      return;
    }

    await db.update(
      _providerTable,
      row,
      where: 'server_id = ? AND is_synced = ?',
      whereArgs: [serverId, 1],
    );
  }

  Future<int> deleteProvider(int id) async {
    final db = await database;
    return await db.delete(
      _providerTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
