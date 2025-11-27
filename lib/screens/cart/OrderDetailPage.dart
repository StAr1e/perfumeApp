// lib/screens/orders/order_detail_page.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodhapp/models/order_model.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/services/supabase_service.dart'; // Import service

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<Map<String, dynamic>?> _addressFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching the address when the page loads
    _addressFuture = _supabaseService.fetchShippingAddress();
  }

  // Helper to determine color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'received':
        return Colors.green.shade700;
      case 'shipped':
        return AppConstant.PRIMARY_COLOR;
      case 'cancelled':
        return AppConstant.ERROR_COLOR;
      case 'processing':
        return Colors.amber.shade700;
      case 'pending':
      default:
        return AppConstant.TEXT_SECONDARY;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      appBar: AppBar(
        title: Text(
          'Order #${widget.order.id.substring(0, 8)}',
          style: GoogleFonts.playfairDisplay(color: AppConstant.TEXT_PRIMARY),
        ),
        backgroundColor: AppConstant.SURFACE_COLOR,
        foregroundColor: AppConstant.TEXT_PRIMARY,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        children: [
          // Order Status Card
          Card(
            color: AppConstant.SURFACE_COLOR,
            child: ListTile(
              title: Text('Status', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              subtitle: Text('ID: ${widget.order.id}', style: GoogleFonts.lato(fontSize: 12)),
              trailing: Chip(
                label: Text(widget.order.status.toUpperCase(), style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: _getStatusColor(widget.order.status),
              ),
            ),
          ),
          const SizedBox(height: AppConstant.PADDING_MEDIUM),

          // ⭐ SHIPPING ADDRESS SECTION
          _buildAddressSection(),
          const SizedBox(height: AppConstant.PADDING_LARGE),

          // Order Items Section (Existing logic using widget.order)
          Text(
            'Order Details (${widget.order.items.length} items)',
            style: GoogleFonts.playfairDisplay(fontSize: AppConstant.FONT_TITLE, color: AppConstant.TEXT_PRIMARY),
          ),
          const Divider(),
          ...widget.order.items.map((item) => _buildOrderItemTile(item)).toList(),
          const SizedBox(height: AppConstant.PADDING_LARGE),
          
          // Total Summary Section
          _buildSummaryCard(),
        ],
      ),
    );
  }

  // ⭐ NEW WIDGET: ADDRESS SECTION
  Widget _buildAddressSection() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _addressFuture,
      builder: (context, snapshot) {
        String fullName = 'Loading...';
        String address = 'Loading...';

        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          final data = snapshot.data!;
          fullName = data['full_name'] ?? 'N/A';
          address = '${data['address_line_1'] ?? ''}, ${data['city'] ?? ''}, ${data['postal_code'] ?? ''}';
        } else if (snapshot.hasError) {
          address = 'Error loading address.';
        }

        return Card(
          color: AppConstant.SURFACE_COLOR,
          child: Padding(
            padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping Address',
                  style: GoogleFonts.playfairDisplay(fontSize: AppConstant.FONT_TITLE, color: AppConstant.PRIMARY_COLOR),
                ),
                const SizedBox(height: AppConstant.PADDING_SMALL),
                Text(fullName, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: AppConstant.TEXT_PRIMARY)),
                Text(address, style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY)),
              ],
            ),
          ),
        );
      },
    );
  }
  

  
  Widget _buildOrderItemTile(Map<String, dynamic> item) {
    // ... (Your existing item tile code using item['...'])
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstant.PADDING_SMALL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder or actual image widget here
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppConstant.BACKGROUND_COLOR,
              borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS / 2),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppConstant.TEXT_SECONDARY, size: 24),
          ),
          const SizedBox(width: AppConstant.PADDING_MEDIUM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product_name']?.toString() ?? 'Product Name',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: AppConstant.TEXT_PRIMARY),
                ),
                Text(
                  '${item['size']} | Qty: ${item['quantity']}',
                  style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY),
                ),
              ],
            ),
          ),
          Text(
            '${(item['subtotal'] as num?)?.toStringAsFixed(2) ?? 'N/A'}',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: AppConstant.PRIMARY_COLOR),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    const double shippingFee = 100; 
    final double subtotal = widget.order.totalAmount - shippingFee;

    return Card(
      color: AppConstant.SURFACE_COLOR,
      child: Padding(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Paid',
              style: GoogleFonts.playfairDisplay(fontSize: AppConstant.FONT_TITLE, color: AppConstant.PRIMARY_COLOR),
            ),
            const Divider(),
            _summaryRow('Subtotal:', subtotal),
            _summaryRow('Shipping Fee:', shippingFee),
            _summaryRow('Total:', widget.order.totalAmount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppConstant.TEXT_PRIMARY : AppConstant.TEXT_SECONDARY,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? AppConstant.FONT_SUBTITLE : AppConstant.FONT_BODY,
              color: isTotal ? AppConstant.PRIMARY_COLOR : AppConstant.TEXT_PRIMARY,
            ),
          ),
        ],
      ),
    );
  }
}