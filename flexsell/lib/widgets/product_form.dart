import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EnhancedProductForm extends StatefulWidget {
  final Product? product;

  const EnhancedProductForm({Key? key, this.product}) : super(key: key);

  @override
  _EnhancedProductFormState createState() => _EnhancedProductFormState();
}

class _EnhancedProductFormState extends State<EnhancedProductForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cashPriceController;
  late TextEditingController _creditPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _skuController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _showAdvancedFields = false;
  String _selectedCategory = 'General';
  
  final List<String> _categories = [
    'General',
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Books',
    'Home & Garden',
    'Sports',
    'Health & Beauty',
    'Automotive',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _cashPriceController = TextEditingController(
        text: widget.product?.cashPrice?.toString() ?? '');
    _creditPriceController = TextEditingController(
        text: widget.product?.creditPrice?.toString() ?? '');
    _descriptionController = TextEditingController();
    _skuController = TextEditingController();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cashPriceController.dispose();
    _creditPriceController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
 Widget build(BuildContext context) {
   final theme = Theme.of(context);
   final isEdit = widget.product != null;

   return FadeTransition(
     opacity: _fadeAnimation,
     child: SlideTransition(
       position: _slideAnimation,
       // Wrap everything in a SingleChildScrollView to ensure the form
       // is always scrollable if content exceeds the screen height.
       child: SingleChildScrollView(
         child: Column(
           // mainAxisSize.min ensures the column only takes up as much
           // vertical space as its children need.
           mainAxisSize: MainAxisSize.min,
           children: [
             // Header
             Container(
               padding: EdgeInsets.all(24),
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                     Colors.green[600]!,
                     Colors.green[500]!,
                   ],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                 ),
                 borderRadius: BorderRadius.vertical(
                   top: Radius.circular(20),
                 ),
               ),
               child: Row(
                 children: [
                   Container(
                     padding: EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Icon(
                       isEdit ? Icons.edit_rounded : Icons.add_box_rounded,
                       color: Colors.white,
                       size: 24,
                     ),
                   ),
                   SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           isEdit ? 'Edit Product' : 'Add New Product',
                           style: TextStyle(
                             fontSize: 20,
                             fontWeight: FontWeight.bold,
                             color: Colors.white,
                           ),
                         ),
                         Text(
                           isEdit ? 'Update product information' : 'Enter product details',
                           style: TextStyle(
                             fontSize: 14,
                             color: Colors.white.withOpacity(0.9),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
             // Form Fields
             Form(
               key: _formKey,
               child: Padding(
                 padding: EdgeInsets.all(24),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Product Name
                     _buildAnimatedField(
                       delay: 200,
                       child: TextFormField(
                         controller: _nameController,
                         decoration: InputDecoration(
                           labelText: 'Product Name *',
                           prefixIcon: Icon(Icons.inventory_2_rounded),
                           hintText: 'Enter product name',
                         ),
                         validator: (value) {
                           if (value == null || value.trim().isEmpty) {
                             return 'Please enter product name';
                           }
                           if (value.trim().length < 2) {
                             return 'Name must be at least 2 characters';
                           }
                           return null;
                         },
                         textCapitalization: TextCapitalization.words,
                       ),
                     ),

                     SizedBox(height: 20),

                     // Cash Price
                     _buildAnimatedField(
                       delay: 300,
                       child: TextFormField(
                         controller: _cashPriceController,
                         decoration: InputDecoration(
                           labelText: 'Cash Price *',
                           prefixIcon: Icon(Icons.attach_money_rounded),
                           hintText: '0.00',
                         ),
                         keyboardType: TextInputType.numberWithOptions(decimal: true),
                         inputFormatters: [
                           FilteringTextInputFormatter.allow(
                               RegExp(r'^\d+\.?\d{0,2}')),
                         ],
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return 'Required';
                           }
                           final price = double.tryParse(value);
                           if (price == null || price <= 0) {
                             return 'Invalid price';
                           }
                           return null;
                         },
                       ),
                     ),

                     SizedBox(height: 20),

                     // Credit Price
                     _buildAnimatedField(
                       delay: 400,
                       child: TextFormField(
                         controller: _creditPriceController,
                         decoration: InputDecoration(
                           labelText: 'Credit Price *',
                           prefixIcon: Icon(Icons.credit_card_rounded),
                           hintText: '0.00',
                         ),
                         keyboardType: TextInputType.numberWithOptions(decimal: true),
                         inputFormatters: [
                           FilteringTextInputFormatter.allow(
                               RegExp(r'^\d+\.?\d{0,2}')),
                         ],
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return 'Required';
                           }
                           final price = double.tryParse(value);
                           if (price == null || price <= 0) {
                             return 'Invalid price';
                           }
                           return null;
                         },
                       ),
                     ),

                     SizedBox(height: 20),

                     // Price Difference Indicator
                     _buildAnimatedField(
                       delay: 400,
                       child: _buildPriceDifferenceIndicator(),
                     ),

                     SizedBox(height: 20),

                     // Advanced Fields Toggle
                     _buildAnimatedField(
                       delay: 500,
                       child: InkWell(
                         onTap: () {
                           setState(() {
                             _showAdvancedFields = !_showAdvancedFields;
                           });
                         },
                         child: Container(
                           padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                           decoration: BoxDecoration(
                             color: Colors.green.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(
                               color: Colors.green.withOpacity(0.3),
                             ),
                           ),
                           child: Row(
                             children: [
                               Icon(
                                 Icons.tune_rounded,
                                 color: Colors.green[600],
                                 size: 20,
                               ),
                               SizedBox(width: 12),
                               Expanded(
                                 child: Text(
                                   'Advanced Options',
                                   style: TextStyle(
                                     fontWeight: FontWeight.w500,
                                     color: Colors.green[600],
                                   ),
                                 ),
                               ),
                               AnimatedRotation(
                                 turns: _showAdvancedFields ? 0.5 : 0,
                                 duration: Duration(milliseconds: 300),
                                 child: Icon(
                                   Icons.expand_more_rounded,
                                   color: Colors.green[600],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),

                     // Advanced Fields
                     AnimatedContainer(
                       duration: Duration(milliseconds: 300),
                       height: _showAdvancedFields ? null : 0,
                       child: _showAdvancedFields
                           ? Column(
                               children: [
                                 SizedBox(height: 20),
                                 
                                 // Category Dropdown
                                 _buildAnimatedField(
                                   delay: 600,
                                   child: DropdownButtonFormField<String>(
                                     value: _selectedCategory,
                                     decoration: InputDecoration(
                                       labelText: 'Category',
                                       prefixIcon: Icon(Icons.category_rounded),
                                     ),
                                     items: _categories.map((category) {
                                       return DropdownMenuItem(
                                         value: category,
                                         child: Text(category),
                                       );
                                     }).toList(),
                                     onChanged: (value) {
                                       setState(() {
                                         _selectedCategory = value!;
                                       });
                                     },
                                   ),
                                 ),

                                 SizedBox(height: 20),

                                 // SKU Field
                                 _buildAnimatedField(
                                   delay: 700,
                                   child: TextFormField(
                                     controller: _skuController,
                                     decoration: InputDecoration(
                                       labelText: 'SKU/Barcode',
                                       prefixIcon: Icon(Icons.qr_code_rounded),
                                       hintText: 'Enter product SKU',
                                     ),
                                     textCapitalization: TextCapitalization.characters,
                                   ),
                                 ),

                                 SizedBox(height: 20),

                                 // Description Field
                                 _buildAnimatedField(
                                   delay: 800,
                                   child: TextFormField(
                                     controller: _descriptionController,
                                     decoration: InputDecoration(
                                       labelText: 'Description',
                                       prefixIcon: Icon(Icons.description_rounded),
                                       hintText: 'Enter product description',
                                     ),
                                     maxLines: 3,
                                     textCapitalization: TextCapitalization.sentences,
                                   ),
                                 ),
                               ],
                             )
                           : SizedBox.shrink(),
                     ),
                   ],
                 ),
               ),
             ),
             SizedBox(height: 16), // Reduced bottom spacing
             // Action Buttons
             _buildAnimatedField(
               delay: 900,
               child: Padding(
                 padding: EdgeInsets.fromLTRB(24, 0, 24, 24), // Add bottom padding here
                 child: Row(
                   children: [
                     Expanded(
                       child: OutlinedButton.icon(
                         onPressed: _isLoading ? null : () => Navigator.pop(context),
                         icon: Icon(Icons.close_rounded),
                         label: Text('Cancel'),
                         style: OutlinedButton.styleFrom(
                           padding: EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                         ),
                       ),
                     ),
                     SizedBox(width: 16),
                     Expanded(
                       flex: 2,
                       child: ElevatedButton.icon(
                         onPressed: _isLoading ? null : _submitForm,
                         icon: _isLoading
                             ? SizedBox(
                                 width: 20,
                                 height: 20,
                                 child: CircularProgressIndicator(
                                   strokeWidth: 2,
                                   valueColor: AlwaysStoppedAnimation<Color>(
                                     Colors.white,
                                   ),
                                 ),
                               )
                             : Icon(isEdit ? Icons.update_rounded : Icons.add_rounded),
                         label: Text(_isLoading
                             ? 'Saving...'
                             : isEdit
                                 ? 'Update Product'
                                 : 'Add Product'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green[600],
                           padding: EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildPriceDifferenceIndicator() {
    final cashPrice = double.tryParse(_cashPriceController.text) ?? 0;
    final creditPrice = double.tryParse(_creditPriceController.text) ?? 0;
    
    if (cashPrice <= 0 || creditPrice <= 0) {
      return SizedBox.shrink();
    }

    final difference = creditPrice - cashPrice;
    final percentage = (difference / cashPrice * 100);
    final isHigher = difference > 0;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHigher 
            ? Colors.orange.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHigher 
              ? Colors.orange.withOpacity(0.3)
              : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHigher ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isHigher ? Colors.orange[700] : Colors.blue[700],
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Credit price is ${percentage.abs().toStringAsFixed(1)}% ${isHigher ? 'higher' : 'lower'} (\$${difference.abs().toStringAsFixed(2)})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isHigher ? Colors.orange[700] : Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      final name = _nameController.text.trim();
      final cashPrice = double.parse(_cashPriceController.text);
      final creditPrice = double.parse(_creditPriceController.text);

      final product = Product(
        id: widget.product?.id,
        name: name,
        cashPrice: cashPrice,
        creditPrice: creditPrice,
      );

      if (widget.product == null) {
        await productProvider.addProduct(product);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Product added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        await productProvider.updateProduct(product);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.update_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Product updated successfully!'),
              ],
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
