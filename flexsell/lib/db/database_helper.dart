import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flexsell.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cashPrice REAL NOT NULL,
        creditPrice REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        prepaidBalance REAL NOT NULL,
        creditOwed REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        customerId INTEGER NOT NULL,
        amountPaid REAL NOT NULL,
        paymentType TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}


// db/database_helper.dart additions
extension ProductDB on DatabaseHelper {
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product> getProductById(int id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return Product.fromMap(result.first);
  }
}

extension CustomerDB on DatabaseHelper {
  Future<void> insertCustomer(Customer customer) async {
    final db = await database;
    await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final result = await db.query('customers');
    return result.map((e) => Customer.fromMap(e)).toList();
  }

  Future<Customer> getCustomerById(int id) async {
    final db = await database;
    final result = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    return Customer.fromMap(result.first);
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await database;
    await db.update('customers', customer.toMap(), where: 'id = ?', whereArgs: [customer.id]);
  }
}

extension SaleDB on DatabaseHelper {
  Future<void> insertSale(Sale sale) async {
    final db = await database;
    await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final result = await db.query('sales');
    return result.map((e) => Sale.fromMap(e)).toList();
  }
}

