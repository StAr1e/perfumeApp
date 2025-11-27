import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/services/supabase_service.dart'; 
import 'package:nodhapp/models/order_model.dart';
import 'package:nodhapp/screens/cart/OrderDetailPage.dart'; 

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching orders when the widget is created
    _ordersFuture = _supabaseService.getMyOrders(); 
  }

  // ⭐ 2. ENHANCED STATUS COLOR FUNCTION
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return Colors.green.shade700; // Stronger Green
      case 'shipped':
        return AppConstant.PRIMARY_COLOR; // Primary Brand Color
      case 'cancelled':
        return AppConstant.ERROR_COLOR; // Red/Error Color
      case 'processing':
        return Colors.amber.shade700; // Amber/Warning for in-progress
      case 'pending':
      default:
        return AppConstant.TEXT_SECONDARY; // Neutral/Gray for waiting
    }
  }

  // Function to refresh the order list
  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _supabaseService.getMyOrders();
    });
  }

  // ⭐ 3. NAVIGATION FUNCTION
  void _navigateToDetails(OrderModel order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator( // Added RefreshIndicator for pull-to-refresh
      onRefresh: _refreshOrders,
      child: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (_supabaseService.currentUser == null) {
            return Center(
                child: Text('Please log in to view your orders.', style: GoogleFonts.lato()));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstant.PRIMARY_COLOR),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading orders: ${snapshot.error}', style: GoogleFonts.lato()),
            );
          }

          final orders = snapshot.data;

          if (orders == null || orders.isEmpty) {
            return Center(
              child: Text('You have no past orders.', style: GoogleFonts.playfairDisplay(fontSize: 18, color: AppConstant.TEXT_SECONDARY)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppConstant.PADDING_SMALL),
                color: AppConstant.SURFACE_COLOR,
                child: ListTile(
                  title: Text('Order ID: ${order.id.substring(0, 8)}',
                      style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: AppConstant.TEXT_PRIMARY)),
                  subtitle: Text('Total: ${order.totalAmount.toStringAsFixed(2)}\nDate: ${order.createdAt.toString().split(' ')[0]}',
                      style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY)),
                  trailing: Chip(
                    label: Text(
                      order.status.toUpperCase(), // Use upper case for better visibility
                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: _getStatusColor(order.status),
                  ),
                  // ⭐ 4. IMPLEMENT NAVIGATION ON TAP
                  onTap: () => _navigateToDetails(order),
                ),
              );
            },
          );
        },
      ),
    );
  }
}