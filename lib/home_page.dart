//
// import 'package:flutter/material.dart';
// import 'package:news_app/centred_view.dart';
// import 'auth.dart';
// import 'package:provider/provider.dart';
// import 'custom_appbar.dart';
//
// class HomePage extends StatelessWidget {
//   final VoidCallback? toggleTheme;
//   const HomePage({super.key, this.toggleTheme});
//
//   @override
//   Widget build(BuildContext context) {
//     final authStore = Provider.of<AuthStore>(context);
//     final theme = Theme.of(context);
//
//     List<Map<String, String>> tileList = [];
//
//     if (authStore.role == 'ROLE_MANAGER') {
//       tileList = [
//         {'title': 'Purchases', 'route': '/purchases'},
//         {'title': 'QC', 'route': '/qc'},
//         {'title': 'Factory', 'route': '/factory'},
//         {'title': 'Listing', 'route': '/listing'},
//         {'title': 'Inventory', 'route': '/inventory'},
//         {'title': 'Sales', 'route': '/sales'},
//         {'title': 'Scrap', 'route': '/scrap'},
//         {'title': 'All Products', 'route': '/all_products'},
//         {'title': 'Credit', 'route': '/credit'},
//         {'title': 'Invoices' , 'route': '/all_invoices'},
//         {'title': 'Bills' , 'route': '/all_bills'},
//       ];
//     } else if (authStore.role == 'user') {
//       tileList = [
//         {'title': 'Sales', 'route': '/sales'},
//         {'title': 'Listing', 'route': '/listing'},
//       ];
//     }
//
//     return CentredView(
//       child: Scaffold(
//         appBar: CustomAppBar(
//           appBarTitle: 'Dashboard',
//         ),
//         body: Container(
//           color: theme.colorScheme.background,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // User Info Section
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 28,
//                     backgroundColor: theme.colorScheme.primary,
//                     child: Text(
//                       (authStore.username?.isNotEmpty ?? false)
//                           ? authStore.username![0].toUpperCase()
//                           : 'U',
//                       style: const TextStyle(fontSize: 28, color: Colors.white),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Welcome, ${authStore.username ?? 'User'}',
//                         style: theme.textTheme.titleLarge,
//                       ),
//                       Text(
//                         authStore.role,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Spacer(),
//
//                 ],
//               ),
//               const SizedBox(height: 32),
//               // Dashboard Stats (optional, placeholder)
//               Row(
//                 children: [
//                   _buildStatCard('Total Tickets', "${authStore.totalTickets}", theme ),
//                   const SizedBox(width: 16),
//                   _buildStatCard('Pending', "${authStore.pendingTickets}", theme),
//                   const SizedBox(width: 16),
//                   _buildStatCard('Completed', "${authStore.completedTickets}", theme),
//                   const SizedBox(width: 16),
//                   _buildStatCard('QC', "${authStore.qc}", theme),
//                   const SizedBox(width: 16),
//                   _buildStatCard('Factory', "${authStore.factory}", theme),
//                   const SizedBox(width: 16),
//                   _buildStatCard('Listed', "${authStore.listed}", theme),
//                 ],
//               ),
//               const SizedBox(height: 32),
//               // Navigation Grid
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 24.0,
//                     mainAxisSpacing: 24.0,
//                     childAspectRatio: 2.5,
//                   ),
//                   itemCount: tileList.length,
//                   itemBuilder: (context, index) {
//                     return _buildTile(context, tileList[index]);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _buildTile(BuildContext context, Map<String, String> tile) {
//     final theme = Theme.of(context);
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
//         ),
//         child: InkWell(
//           onTap: () => Navigator.pushNamed(context, tile['route']!),
//           borderRadius: BorderRadius.circular(12),
//           onHover: (hovering) {
//             // Optionally, you can use setState if you want to change color on hover
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             child: Row(
//               children: [
//                 Icon(
//                   _getIconForTitle(tile['title']!),
//                   color: theme.colorScheme.primary,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     tile['title']!,
//                     style: theme.textTheme.titleMedium,
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   color: theme.colorScheme.primary,
//                   size: 20,
//
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   IconData _getIconForTitle(String title) {
//     switch (title.toLowerCase()) {
//       case 'purchases':
//         return Icons.shopping_cart;
//       case 'qc1':
//       case 'qc2':
//         return Icons.check_circle;
//       case 'factory':
//         return Icons.factory;
//       case 'listing':
//         return Icons.list;
//       case 'sales':
//         return Icons.point_of_sale;
//       case 'scrap':
//         return Icons.delete;
//       case 'gst calculation':
//         return Icons.calculate;
//       case 'all products':
//         return Icons.inventory_sharp;
//       case 'inventory':
//         return Icons.inventory;
//         case 'qc' :
//         return Icons.safety_check_rounded;
//       case 'credit' :
//         return Icons.credit_card;
//       case 'invoices' :
//         return Icons.receipt_long;
//       case 'bills' :
//         return Icons.receipt;
//       default:
//         return Icons.circle;
//     }
//   }
//
//   Widget _buildStatCard(String label, String value, ThemeData theme) {
//     return Expanded(
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 value,
//                 style: theme.textTheme.displayMedium?.copyWith(
//                   color: theme.colorScheme.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 label, style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:news_app/centred_view.dart';
import 'auth.dart';
import 'package:provider/provider.dart';
import 'custom_appbar.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? toggleTheme;
  const HomePage({super.key, this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final theme = Theme.of(context);

    return CentredView(
      child: Scaffold(
        appBar: CustomAppBar(
          appBarTitle: 'Dashboard',
        ),
        body: Container(
          color: theme.colorScheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---------------- USER INFO ----------------
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (authStore.username?.isNotEmpty ?? false)
                          ? authStore.username![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authStore.username ?? 'User'}',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        authStore.role,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 32),

              // ---------------- STATS ----------------
              Row(
                children: [
                  _buildStatCard('Total Tickets', "${authStore.totalTickets}", theme),
                  const SizedBox(width: 16),
                  _buildStatCard('Pending', "${authStore.pendingTickets}", theme),
                  const SizedBox(width: 16),
                  _buildStatCard('Completed', "${authStore.completedTickets}", theme),
                  const SizedBox(width: 16),
                  _buildStatCard('QC', "${authStore.qc}", theme),
                  const SizedBox(width: 16),
                  _buildStatCard('Factory', "${authStore.factory}", theme),
                  const SizedBox(width: 16),
                  _buildStatCard('Listed', "${authStore.listed}", theme),
                ],
              ),

              const SizedBox(height: 32),

              // ---------------- COLLAPSIBLE SECTIONS ----------------
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [



                      _buildExpandableSection(
                        title: "Purchases",
                        icon: Icons.shopping_cart,
                        tiles: [
                          {'title': 'Purchases', 'route': '/purchases'},
                        ],
                      ),

                      _buildExpandableSection(
                        title: "Product Lifecycle",
                        icon: Icons.timeline,
                        tiles: [
                          {'title': 'QC', 'route': '/qc'},
                          {'title': 'Factory', 'route': '/factory'},
                          {'title': 'Listing', 'route': '/listing'},
                          {'title': 'Scrap', 'route': '/scrap'},

                        ],
                      ),

                      _buildExpandableSection(
                        title: "Sales & Credit",
                        icon: Icons.point_of_sale,
                        tiles: [
                          {'title': 'Sales', 'route': '/sales'},
                          {'title': 'Credit', 'route': '/credit'},
                        ],
                      ),

                      _buildExpandableSection(
                        title: "Invoices & Bills",
                        icon: Icons.receipt_long,
                        tiles: [
                          {'title': 'Invoices', 'route': '/all_invoices'},
                          {'title': 'Bills', 'route': '/all_bills'},
                        ],
                      ),

                      _buildExpandableSection(
                        title: "All Products",
                        icon: Icons.inventory_sharp,
                        tiles: [
                          {'title': 'All Products', 'route': '/all_products'},
                          {'title': 'Inventory', 'route': '/inventory'},
                        ],
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

  // ---------------- EXPANDABLE SECTION ----------------
  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required List<Map<String, String>> tiles,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        children: tiles.map((tile) => _buildDropdownTile(tile)).toList(),
      ),
    );
  }

  // ---------------- DROP-DOWN TILE ----------------
  Widget _buildDropdownTile(Map<String, String> tile) {
    return ListTile(
      leading: Icon(
        _getIconForTitle(tile['title']!),
        color: Colors.black87,
      ),
      title: Text(tile['title']!, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, tile['route']!),
    );
  }

  // ---------------- ICONS ----------------
  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'purchases': return Icons.shopping_cart;
      case 'qc': return Icons.safety_check_rounded;
      case 'factory': return Icons.factory;
      case 'listing': return Icons.list;
      case 'sales': return Icons.point_of_sale;
      case 'scrap': return Icons.delete;
      case 'inventory': return Icons.inventory;
      case 'all products': return Icons.inventory_sharp;
      case 'credit': return Icons.credit_card;
      case 'invoices': return Icons.receipt_long;
      case 'bills': return Icons.receipt;
      default: return Icons.circle;
    }
  }

  // ---------------- STAT CARD ----------------
  Widget _buildStatCard(String label, String value, ThemeData theme) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
