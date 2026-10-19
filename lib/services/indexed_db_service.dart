import 'dart:html';
import 'dart:indexed_db';

class IndexedDBService {
  static Database? _db;
  static const String _dbName = 'RealEstateCRM';
  static const String _storeName = 'data';

  static Future<Database> _getDB() async {
    if (_db != null) return _db!;

    final factory = window.indexedDB;
    if (factory == null) {
      throw Exception('IndexedDB no está disponible');
    }

    _db = await factory.open(
      _dbName,
      version: 1,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final db = event.target.result;
        if (db is Database) {
          if (!(db.objectStoreNames?.contains(_storeName) ?? false)) {
            db.createObjectStore(_storeName);
          }
        }
      },
    );

    return _db!;
  }

  static Future<void> put(String key, dynamic value) async {
    final db = await _getDB();
    final tx = db.transaction(_storeName, 'readwrite');
    final store = tx.objectStore(_storeName);
    await store.put(value, key);
    await tx.completed;
  }

  static Future<dynamic> get(String key) async {
    final db = await _getDB();
    final tx = db.transaction(_storeName, 'readonly');
    final store = tx.objectStore(_storeName);
    final result = await store.getObject(key);
    return result;
  }

  static Future<void> delete(String key) async {
    final db = await _getDB();
    final tx = db.transaction(_storeName, 'readwrite');
    final store = tx.objectStore(_storeName);
    await store.delete(key);
    await tx.completed;
  }

  static Future<void> clear() async {
    final db = await _getDB();
    final tx = db.transaction(_storeName, 'readwrite');
    final store = tx.objectStore(_storeName);
    await store.clear();
    await tx.completed;
  }
}