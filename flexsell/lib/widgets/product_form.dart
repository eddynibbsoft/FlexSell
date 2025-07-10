import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductForm extends StatefulWidget {
  final Product? product;

  ProductForm({this.product});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late TextEditingController nameController;
  late TextEditingController cashPriceController;
  late TextEditingController creditPriceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?.name ?? '');
    cashPriceController = TextEditingController(
        text: widget.product?.cashPrice.toString() ?? '');
    creditPriceController = TextEditingController(
        text: widget.product?.creditPrice.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    cashPriceController.dispose();
    creditPriceController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    final name = nameController.text.trim();
    final cashText = cashPriceController.text.trim();
    final creditText = creditPriceController.text.trim();

    if (name.isEmpty || cashText.isEmpty || creditText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    double? cashPrice = double.tryParse(cashText);
    double? creditPrice = double.tryParse(creditText);

    if (cashPrice == null || creditPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid numbers')),
      );
      return;
    }

    final product = Product(
      id: widget.product?.id,
      name: name,
      cashPrice: cashPrice,
      creditPrice: creditPrice,
    );

    final provider = context.read<ProductProvider>();

    if (widget.product != null) {
      provider.updateProduct(product);
    } else {
      provider.addProduct(product);
    }

    Navigator.of(context).pop(); // Close the dialog after submit
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Product Name'),
          ),
          TextField(
            controller: cashPriceController,
            decoration: InputDecoration(labelText: 'Cash Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          TextField(
            controller: creditPriceController,
            decoration: InputDecoration(labelText: 'Credit Price'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _submitForm(context),
            child: Text(isEdit ? 'Update Product' : 'Add Product'),
          ),
        ],
      ),
    );
  }
}
