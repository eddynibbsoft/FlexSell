// widgets/product_form.dart
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
        text: widget.product?.cashPrice?.toString() ?? '');
    creditPriceController = TextEditingController(
        text: widget.product?.creditPrice?.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    cashPriceController.dispose();
    creditPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Product Name')),
        TextField(
            controller: cashPriceController,
            decoration: InputDecoration(labelText: 'Cash Price'),
            keyboardType: TextInputType.number),
        TextField(
            controller: creditPriceController,
            decoration: InputDecoration(labelText: 'Credit Price'),
            keyboardType: TextInputType.number),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final newProduct = Product(
              id: widget.product?.id,
              name: nameController.text,
              cashPrice: double.parse(cashPriceController.text),
              creditPrice: double.parse(creditPriceController.text),
            );

            if (isEdit) {
              context.read<ProductProvider>().updateProduct(newProduct);
              Navigator.of(context).pop(); // Close the dialog
            } else {
              context.read<ProductProvider>().addProduct(newProduct);
            }
          },
          child: Text(isEdit ? 'Update Product' : 'Add Product'),
        )
      ],
    );
  }
}
