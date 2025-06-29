// widgets/product_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

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