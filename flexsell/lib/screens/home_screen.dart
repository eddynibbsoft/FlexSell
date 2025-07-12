import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/stats_provider.dart';
import 'products_screen.dart';
import 'customers_screen.dart';
import 'sale_screen.dart';
import 'prepayment_screen.dart';
import 'statement_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
    
    // Load stats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadStats();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Logo and Theme Toggle
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            actions: [
              // Quick Actions Menu
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: Colors.white),
                      onSelected: (value) => _handleMenuAction(context, value),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_rounded),
                              SizedBox(width: 12),
                              Text('Settings'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'backup',
                          child: Row(
                            children: [
                              Icon(Icons.backup_rounded),
                              SizedBox(width: 12),
                              Text('Backup Data'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'help',
                          child: Row(
                            children: [
                              Icon(Icons.help_outline_rounded),
                              SizedBox(width: 12),
                              Text('Help & Support'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Theme Toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return IconButton(
                          icon: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              key: ValueKey(themeProvider.isDarkMode),
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            colorScheme.surface,
                            colorScheme.surface.withOpacity(0.8),
                          ]
                        : [
                            colorScheme.primary,
                            colorScheme.secondary,
                          ],
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          // Animated Logo Container
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        offset: Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/logo.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          // Animated Text
                          TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Column(
                                    children: [
                                      Text(
                                        'FlexSell',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Business Management Suite',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Card with Real Data
                  Consumer<StatsProvider>(
                    builder: (context, statsProvider, child) {
                      return _buildStatsCard(context, statsProvider);
                    },
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Quick Actions Title
                  Row(
                    children: [
                      Icon(
                        Icons.dashboard_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Access your business tools with shortcuts',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24),

                  // Action Cards Grid with Staggered Animation
                  _buildAnimatedGrid(context),

                  SizedBox(height: 32),

                  // Recent Activity Section

                  SizedBox(height: 32),

                  // Recent Activity Section
                  _buildRecentActivityCard(context),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Speed Dial
      floatingActionButton: _buildSpeedDial(context),
    );
  }

  Widget _buildStatsCard(BuildContext context, StatsProvider statsProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface,
                    colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.analytics_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Overview',
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              'Your business at a glance',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      // Refresh Button
                      IconButton(
                        onPressed: () => statsProvider.loadStats(),
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colorScheme.primary,
                        ),
                        tooltip: 'Refresh Stats',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Sales',
                        statsProvider.totalSales.toString(),
                        Icons.trending_up_rounded,
                        Colors.green,
                      ),
                      _buildStatItem(
                        context,
                        'Revenue',
                        '\$${statsProvider.totalRevenue.toStringAsFixed(2)}',
                        Icons.attach_money_rounded,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        context,
                        'Customers',
                        statsProvider.totalCustomers.toString(),
                        Icons.people_rounded,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGrid(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final actions = [
      {
        'title': 'Products',
        'subtitle': 'Manage inventory',
        'icon': Icons.inventory_2_rounded,
        'gradient': [Color(0xFF10B981), Color(0xFF059669)],
        'screen': ProductsScreen(),
      },
      {
        'title': 'Customers',
        'subtitle': 'Client management',
        'icon': Icons.people_rounded,
        'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
        'screen': CustomersScreen(),
      },
      {
        'title': 'Point of Sale',
        'subtitle': 'Process sales',
        'icon': Icons.point_of_sale_rounded,
        'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        'screen': SaleScreen(),
      },
      {
        'title': 'Wallet',
        'subtitle': 'Manage payments',
        'icon': Icons.account_balance_wallet_rounded,
        'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
        'screen': PrepaymentScreen(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 600 ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 200)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: _buildEnhancedActionCard(
                  context,
                  title: actions[index]['title'] as String,
                  subtitle: actions[index]['subtitle'] as String,
                  icon: actions[index]['icon'] as IconData,
                  gradient: actions[index]['gradient'] as List<Color>,
                  onTap: () => _navigateToScreen(context, actions[index]['screen'] as Widget),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shadowColor: gradient[0].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                gradient[0].withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: title,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradient[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 8,
              shadowColor: colorScheme.primary.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () => _navigateToScreen(context, StatementScreen()),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.surface,
                        colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'View detailed reports and analytics',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showQuickActionsBottomSheet(context),
      child: Icon(Icons.add_rounded),
      tooltip: 'Quick Actions',
    );
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  context,
                  'New Sale',
                  Icons.point_of_sale_rounded,
                  Colors.purple,
                  () => _navigateToScreen(context, SaleScreen()),
                ),
                _buildQuickActionButton(
                  context,
                  'Add Customer',
                  Icons.person_add_rounded,
                  Colors.orange,
                  () => _navigateToScreen(context, CustomersScreen()),
                ),
                _buildQuickActionButton(
                  context,
                  'Add Product',
                  Icons.add_box_rounded,
                  Colors.green,
                  () => _navigateToScreen(context, ProductsScreen()),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 28),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        _showSettingsDialog(context);
        break;
      case 'backup':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'help':
        _showHelpDialog(context);
        break;
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: Icon(Icons.palette_rounded),
                  title: Text('Theme'),
                  subtitle: Text(themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded),
            SizedBox(width: 8),
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to FlexSell!'),
            SizedBox(height: 12),
            Text('• Manage your products and inventory'),
            Text('• Track customer information and balances'),
            Text('• Process sales and payments'),
            Text('• Generate reports and analytics'),
            SizedBox(height: 12),
            Text('For support, contact: support@flexsell.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
      ),
    );
  }
}
