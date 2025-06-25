# FlexSell
Flexible selling and payment tracking
To build this Flutter app, you'll need:

### 🔧 Tech Stack

* **Flutter** (frontend)
* **Firebase** or **Supabase** (backend and database) — ideal for quick prototyping
* Alternatively, **Django REST API** if you want full backend control
* **Provider** or **Riverpod** for state management

---

### 🧱 Feature Breakdown

#### 1. **Seller Product Management**

* Create product model with:

  * `name`, `description`, `cashPrice`, `creditPrice`
* Add/edit/delete products from the seller’s catalog

#### 2. **Customer Management**

* Create customer model with:

  * `name`, `phone`, `email`, `address`, `prepaidBalance`
* Add/edit/delete customer entries

#### 3. **Sales Transactions**

* Sale includes:

  * `productId`, `customerId`, `pricePaid`, `paymentType` (Cash/Credit), `date`
* Link sale to a customer

#### 4. **Balance Management**

* Credit sales add to `customer.debt`
* Prepayments reduce debt or increase `customer.prepaidBalance`
* Cash purchases don’t affect balance

#### 5. **Customer Statements**

* For a given date range, show:

  * All purchases (cash & credit)
  * Total credit owed
  * Prepayments made
  * Current balance = `credit - prepaidBalance`

---

### 🗃️ Data Models (Simplified)

```dart
class Product {
  String id;
  String name;
  double cashPrice;
  double creditPrice;
}

class Customer {
  String id;
  String name;
  String phone;
  double prepaidBalance;
  double creditOwed;
}

class Sale {
  String id;
  String productId;
  String customerId;
  double amountPaid;
  String paymentType; // 'Cash' or 'Credit'
  DateTime date;
}
```

---

### 📲 UI Pages

1. **Home/Dashboard**
2. **Products Page**

   * List of products
   * Add/Edit form
3. **Customers Page**

   * List of customers
   * Add/Edit form
4. **Make Sale Page**

   * Select customer
   * Select product
   * Choose payment type (Cash/Credit)
5. **Prepayment Page**

   * Add funds to customer balance
6. **Statement Page**

   * Select customer
   * Select date range
   * Generate summary

---

### 📌 Next Step

Would you like:

* A **Flutter UI project structure scaffold**?
* A **Firebase setup**?
* Or an **offline local-only version** using `sqflite`?

Let me know and I can generate the initial folder structure and code for you.




project_root/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── product.dart
│   │   ├── customer.dart
│   │   └── sale.dart
│   ├── db/
│   │   └── database_helper.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── products_screen.dart
│   │   ├── customers_screen.dart
│   │   ├── sale_screen.dart
│   │   ├── prepayment_screen.dart
│   │   └── statement_screen.dart
│   ├── widgets/
│   │   ├── product_form.dart
│   │   ├── customer_form.dart
│   │   └── sale_form.dart
│   ├── providers/
│   │   ├── product_provider.dart
│   │   ├── customer_provider.dart
│   │   └── sale_provider.dart
│   └── utils/
│       └── constants.dart
├── pubspec.yaml
└── assets/

// widgets/product_form.dart
class ProductForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cashPriceController = TextEditingController();
  final TextEditingController creditPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: nameController, decoration: InputDecoration(labelText: 'Product Name')),
        TextField(controller: cashPriceController, decoration: InputDecoration(labelText: 'Cash Price'), keyboardType: TextInputType.number),
        TextField(controller: creditPriceController, decoration: InputDecoration(labelText: 'Credit Price'), keyboardType: TextInputType.number),
        ElevatedButton(
          onPressed: () {
            final product = Product(
              name: nameController.text,
              cashPrice: double.parse(cashPriceController.text),
              creditPrice: double.parse(creditPriceController.text),
            );
            context.read<ProductProvider>().addProduct(product);
          },
          child: Text('Add Product'),
        )
      ],
    );
  }
}

// widgets/customer_form.dart
class CustomerForm extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: nameController, decoration: InputDecoration(labelText: 'Customer Name')),
        TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
        ElevatedButton(
          onPressed: () {
            final customer = Customer(
              name: nameController.text,
              phone: phoneController.text,
              prepaidBalance: 0,
              creditOwed: 0,
            );
            context.read<CustomerProvider>().addCustomer(customer);
          },
          child: Text('Add Customer'),
        )
      ],
    );
  }
}

// widgets/sale_form.dart
class SaleForm extends StatefulWidget {
  @override
  _SaleFormState createState() => _SaleFormState();
}

class _SaleFormState extends State<SaleForm> {
  String? selectedProductId;
  String? selectedCustomerId;
  String paymentType = 'Cash';

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final customers = context.watch<CustomerProvider>().customers;

    return Column(
      children: [
        DropdownButton<String>(
          hint: Text('Select Product'),
          value: selectedProductId,
          onChanged: (value) => setState(() => selectedProductId = value),
          items: products.map((p) => DropdownMenuItem(value: p.id.toString(), child: Text(p.name))).toList(),
        ),
        DropdownButton<String>(
          hint: Text('Select Customer'),
          value: selectedCustomerId,
          onChanged: (value) => setState(() => selectedCustomerId = value),
          items: customers.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name))).toList(),
        ),
        DropdownButton<String>(
          value: paymentType,
          onChanged: (value) => setState(() => paymentType = value!),
          items: ['Cash', 'Credit'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<SaleProvider>().createSale(
              productId: int.parse(selectedProductId!),
              customerId: int.parse(selectedCustomerId!),
              paymentType: paymentType,
            );
          },
          child: Text('Record Sale'),
        )
      ],
    );
  }
}

// screens/statement_screen.dart
class StatementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    Customer? selectedCustomer;

    return Column(
      children: [
        DropdownButton<Customer>(
          hint: Text('Select Customer'),
          value: selectedCustomer,
          onChanged: (c) => selectedCustomer = c,
          items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedCustomer != null) {
              final summary = context.read<SaleProvider>().getCustomerStatement(selectedCustomer!.id!);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Statement for ${selectedCustomer!.name}'),
                  content: Text(summary),
                ),
              );
            }
          },
          child: Text('Generate Statement'),
        )
      ],
    );
  }
}

// pubspec.yaml dependencies:
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.0.0+4
  path: ^1.8.0
  path_provider: ^2.0.2
  provider: ^6.0.0




project_root/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── product.dart
│   │   ├── customer.dart
│   │   └── sale.dart
│   ├── db/
│   │   └── database_helper.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── products_screen.dart
│   │   ├── customers_screen.dart
│   │   ├── sale_screen.dart
│   │   ├── prepayment_screen.dart
│   │   └── statement_screen.dart
│   ├── widgets/
│   │   ├── product_form.dart
│   │   ├── customer_form.dart
│   │   └── sale_form.dart
│   ├── providers/
│   │   ├── product_provider.dart
│   │   ├── customer_provider.dart
│   │   └── sale_provider.dart
│   └── utils/
│       └── constants.dart
├── pubspec.yaml
└── assets/

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper.instance;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => CustomerProvider(dbHelper)),
        ChangeNotifierProvider(create: (_) => SaleProvider(dbHelper)),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}

// screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seller Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Manage Products'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsScreen())),
          ),
          ListTile(
            title: Text('Manage Customers'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomersScreen())),
          ),
          ListTile(
            title: Text('Record Sale'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SaleScreen())),
          ),
          ListTile(
            title: Text('Prepayment'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrepaymentScreen())),
          ),
          ListTile(
            title: Text('Customer Statement'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StatementScreen())),
          ),
        ],
      ),
    );
  }
}

// providers/product_provider.dart
class ProductProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Product> _products = [];

  ProductProvider(this.db) {
    loadProducts();
  }

  List<Product> get products => _products;

  Future<void> loadProducts() async {
    _products = await db.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await db.insertProduct(product);
    await loadProducts();
  }
}

// providers/customer_provider.dart
class CustomerProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Customer> _customers = [];

  CustomerProvider(this.db) {
    loadCustomers();
  }

  List<Customer> get customers => _customers;

  Future<void> loadCustomers() async {
    _customers = await db.getAllCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await db.insertCustomer(customer);
    await loadCustomers();
  }
}

// providers/sale_provider.dart
class SaleProvider extends ChangeNotifier {
  final DatabaseHelper db;
  List<Sale> _sales = [];

  SaleProvider(this.db) {
    loadSales();
  }

  Future<void> loadSales() async {
    _sales = await db.getAllSales();
    notifyListeners();
  }

  Future<void> createSale({
    required int productId,
    required int customerId,
    required String paymentType,
  }) async {
    final product = await db.getProductById(productId);
    final customer = await db.getCustomerById(customerId);

    final amount = paymentType == 'Cash' ? product.cashPrice : product.creditPrice;
    final sale = Sale(
      productId: productId,
      customerId: customerId,
      amountPaid: amount,
      paymentType: paymentType,
      date: DateTime.now().toIso8601String(),
    );
    await db.insertSale(sale);

    if (paymentType == 'Credit') {
      customer.creditOwed += amount;
    } else if (paymentType == 'Cash' && customer.prepaidBalance >= amount) {
      customer.prepaidBalance -= amount;
    }
    await db.updateCustomer(customer);
    await loadSales();
  }

  String getCustomerStatement(int customerId) {
    final relevantSales = _sales.where((s) => s.customerId == customerId).toList();
    final totalCredit = relevantSales
        .where((s) => s.paymentType == 'Credit')
        .fold(0.0, (sum, s) => sum + s.amountPaid);
    final totalCash = relevantSales
        .where((s) => s.paymentType == 'Cash')
        .fold(0.0, (sum, s) => sum + s.amountPaid);

    return 'Cash Paid: \$${totalCash.toStringAsFixed(2)}\n'
           'Credit Owed: \$${totalCredit.toStringAsFixed(2)}';
  }
}

project_root/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── product.dart
│   │   ├── customer.dart
│   │   └── sale.dart
│   ├── db/
│   │   └── database_helper.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── products_screen.dart
│   │   ├── customers_screen.dart
│   │   ├── sale_screen.dart
│   │   ├── prepayment_screen.dart
│   │   └── statement_screen.dart
│   ├── widgets/
│   │   ├── product_form.dart
│   │   ├── customer_form.dart
│   │   └── sale_form.dart
│   ├── providers/
│   │   ├── product_provider.dart
│   │   ├── customer_provider.dart
│   │   └── sale_provider.dart
│   └── utils/
│       └── constants.dart
├── pubspec.yaml
└── assets/

// screens/prepayment_screen.dart
class PrepaymentScreen extends StatelessWidget {
  final TextEditingController amountController = TextEditingController();
  Customer? selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    return Scaffold(
      appBar: AppBar(title: Text('Add Prepayment')),
      body: Column(
        children: [
          DropdownButton<Customer>(
            hint: Text('Select Customer'),
            value: selectedCustomer,
            onChanged: (c) => selectedCustomer = c,
            items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedCustomer != null && amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text) ?? 0;
                selectedCustomer!.prepaidBalance += amount;
                await context.read<CustomerProvider>().updateCustomer(selectedCustomer!);
              }
            },
            child: Text('Add Balance'),
          )
        ],
      ),
    );
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

