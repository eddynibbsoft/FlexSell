import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/customer.dart';
import '../models/product.dart';
import '../providers/customer_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/stats_provider.dart';

class EnhancedSaleForm extends StatefulWidget {
  @override
  _EnhancedSaleFormState createState() => _EnhancedSaleFormState();
}

class _EnhancedSaleFormState extends State<EnhancedSaleForm>
    with TickerProviderStateMixin {
  int? selectedCustomerId;
  int? selectedProductId;
  int quantity = 1;
  String paymentMethod = 'wallet';
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final products = context.watch<ProductProvider>().products;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedCustomer = customers.firstWhere(
      (c) => c.id == selectedCustomerId,
      orElse: () => Customer(name: '', phone: '', prepaidBalance: 0),
    );

    final selectedProduct = products.firstWhere(
      (p) => p.id == selectedProductId,
      orElse: () => Product(name: '', cashPrice: 0, creditPrice: 0),
    );

    final totalAmount = _calculateTotal(selectedProduct);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Selection
              _buildAnimatedField(
                delay: 200,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_rounded, color: colorScheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'Select Customer',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: DropdownButtonFormField<int>(
                            value: selectedCustomerId,
                            hint: Text('Choose a customer'),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.people_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            isExpanded: true,
                            items: customers.map((customer) {
                              final balanceColor = customer.prepaidBalance < 0
                                  ? Colors.red
                                  : customer.prepaidBalance > 0
                                      ? Colors.green
                                      : Colors.grey;
                              
                              return DropdownMenuItem<int>(
                                value: customer.id,
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(maxHeight: 48), // Add height constraint
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: balanceColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center, // Center content
                                          children: [
                                            Flexible(
                                              child: Text(
                                                customer.name,
                                                style: TextStyle(fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            SizedBox(height: 4), // Reduced spacing
                                            // Flexible(
                                            //   child: Text(
                                            //     'Balance: \$${customer.prepaidBalance.toStringAsFixed(2)}',
                                            //     style: TextStyle(
                                            //       fontSize: 11, // Reduced font size
                                            //       color: balanceColor,
                                            //     ),
                                            //     overflow: TextOverflow.ellipsis,
                                            //     maxLines: 1,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCustomerId = val;
                              });
                            },
                          ),
                        ),
                        if (selectedCustomerId != null) ...[
                          SizedBox(height: 12),
                          _buildCustomerInfo(selectedCustomer),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Product Selection
              _buildAnimatedField(
                delay: 300,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory_2_rounded, color: Colors.green[600]),
                            SizedBox(width: 8),
                            Text(
                              'Select Product',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: DropdownButtonFormField<int>(
                            value: selectedProductId,
                            hint: Text('Choose a product'),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.shopping_bag_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            isExpanded: true,
                            items: products.map((product) {
                              return DropdownMenuItem<int>(
                                value: product.id,
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(maxHeight: 48), // Add height constraint
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center, // Center content
                                    children: [
                                      Flexible(
                                        child: Text(
                                          product.name,
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(height: 2), // Reduced spacing
                                      // Flexible(
                                      //   child: Row(
                                      //     children: [
                                      //       // Flexible(
                                      //       //   child: Text(
                                      //       //     'Cash: \$${product.cashPrice.toStringAsFixed(2)}',
                                      //       //     style: TextStyle(
                                      //       //       fontSize: 11, // Reduced font size
                                      //       //       color: Colors.green[600],
                                      //       //     ),
                                      //       //     overflow: TextOverflow.ellipsis,
                                      //       //   ),
                                      //       // ),
                                      //       SizedBox(width: 8), // Reduced spacing
                                      //       // Flexible(
                                      //       //   child: Text(
                                      //       //     'Credit: \$${product.creditPrice.toStringAsFixed(2)}',
                                      //       //     style: TextStyle(
                                      //       //       fontSize: 11, // Reduced font size
                                      //       //       color: Colors.orange[600],
                                      //       //     ),
                                      //       //     overflow: TextOverflow.ellipsis,
                                      //       //   ),
                                      //       // ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedProductId = val;
                              });
                            },
                          ),
                        ),
                        if (selectedProductId != null) ...[
                          SizedBox(height: 16),
                          _buildQuantitySelector(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Payment Method
              if (selectedCustomerId != null && selectedProductId != null)
                _buildAnimatedField(
                  delay: 400,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payment_rounded, color: Colors.blue[600]),
                              SizedBox(width: 8),
                              Text(
                                'Payment Method',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildPaymentMethodSelector(selectedCustomer),
                        ],
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // Order Summary
              if (selectedCustomerId != null && selectedProductId != null)
                _buildAnimatedField(
                  delay: 500,
                  child: _buildOrderSummary(selectedProduct, totalAmount),
                ),

              SizedBox(height: 24),

              // Complete Sale Button
              if (selectedCustomerId != null && selectedProductId != null)
                _buildAnimatedField(
                  delay: 600,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _completeSale,
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.check_circle_rounded),
                      label: Text(
                        _isLoading ? 'Processing...' : 'Complete Sale',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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

  Widget _buildCustomerInfo(Customer customer) {
    final balanceColor = customer.prepaidBalance < 0
        ? Colors.red
        : customer.prepaidBalance > 0
            ? Colors.green
            : Colors.grey;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: balanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: balanceColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: balanceColor, size: 20),
          SizedBox(width: 8),
          Text(
            'Current Balance: \$${customer.prepaidBalance.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: balanceColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Text('Quantity:', style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: Icon(Icons.remove_rounded),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: Icon(Icons.add_rounded),
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(Customer customer) {
    return Column(
      children: [
        RadioListTile<String>(
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text('Wallet Payment')),
              Text(
                '\$${customer.prepaidBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: customer.prepaidBalance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          value: 'wallet',
          groupValue: paymentMethod,
          onChanged: (value) => setState(() => paymentMethod = value!),
        ),
        // RadioListTile<String>(
        //   title: Row(
        //     children: [
        //       Icon(Icons.attach_money_rounded, size: 20),
        //       SizedBox(width: 8),
        //       Text('Cash Payment'),
        //     ],
        //   ),
        //   value: 'cash',
        //   groupValue: paymentMethod,
        //   onChanged: (value) => setState(() => paymentMethod = value!),
        // ),
        RadioListTile<String>(
          title: Row(
            children: [
              Icon(Icons.credit_card_rounded, size: 20),
              SizedBox(width: 8),
              Text('Credit Payment'),
            ],
          ),
          value: 'credit',
          groupValue: paymentMethod,
          onChanged: (value) => setState(() => paymentMethod = value!),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(Product product, double totalAmount) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_rounded, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Product:'),
                Expanded(
                  child: Text(
                    product.name,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity:'),
                Text(
                  quantity.toString(),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unit Price:'),
                Text(
                  '\$${_getUnitPrice(product).toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Method:'),
                Text(
                  paymentMethod.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getUnitPrice(Product product) {
    switch (paymentMethod) {
      case 'cash':
        return product.cashPrice;
      case 'credit':
        return product.creditPrice;
      case 'wallet':
      default:
        return product.cashPrice; // Use cash price for wallet payments
    }
  }

  double _calculateTotal(Product product) {
    return _getUnitPrice(product) * quantity;
  }

  Future<void> _completeSale() async {
    if (selectedCustomerId == null || selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both customer and product'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<SaleProvider>().createSale(
        customerId: selectedCustomerId!,
        productId: selectedProductId!,
      );

      // Refresh all providers
      await context.read<CustomerProvider>().loadCustomers();
      await context.read<StatsProvider>().loadStats();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Sale completed successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      setState(() {
        selectedCustomerId = null;
        selectedProductId = null;
        quantity = 1;
        paymentMethod = 'wallet';
      });
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
