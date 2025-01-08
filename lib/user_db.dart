import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dummyItems.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tblName = "user_tbl";
  final String _idColumn = "id";
  final String _nameColumn = "item_name";
  final String _priceColumn = "item_price";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "user_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_tblName (
          $_idColumn INTEGER PRIMARY KEY,
          $_nameColumn TEXT NOT NULL,
          $_priceColumn REAL NOT NUll
        )
        ''');
      }
    );
    return database;
  }

  Future<bool> checkItemExistsInFirebase(String itemName) async {
    try {
      // First, check if the item exists in SQLite
      final itemsFromSQLite = await DatabaseService.instance.getAllItems();
      bool itemExistsInSQLite = itemsFromSQLite.any((item) => item.item_name!.toLowerCase() == itemName.toLowerCase());

      if (itemExistsInSQLite) {
        return true;  // Item found in SQLite
      }

      // If not found in SQLite, check Firebase
      final snapshot = await FirebaseDatabase.instance.ref().child('products/').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        for (var category in data.values) {
          final items = Map<String, dynamic>.from(category['items']);
          if (items.values.any((item) => item['name'] == itemName)) {
            return true;  // Item found in Firebase
          }
        }
      }
    } catch (e) {
      print("Error checking item existence: $e");
    }
    return false;  // Item not found in both SQLite and Firebase
  }


  Future<void> addItem(String name, double price) async {
    final db = await database;
    try {
      await db.insert(
        _tblName,
        {
          _nameColumn: name,
          _priceColumn: price
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Optional: To handle duplicate entries
      );
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> items = await db.query(_tblName);

      // Convert the raw maps into Item objects
      List<Item> itemList = items.map((row) => Item.fromSQLite(row)).toList();

      return itemList;
    } catch (e) {
      print("Error fetching all items: $e");
      return [];
    }
  }

}