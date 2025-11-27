import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/providers/cart_manager.dart';
import 'package:nodhapp/services/supabase_service.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'order_confirmation_page.dart';

// Converted to StatefulWidget to manage payment selection state
class CheckoutPage extends StatefulWidget {
  final CartManager cartManager;
  const CheckoutPage({super.key, required this.cartManager});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final SupabaseService _supabaseService = SupabaseService();
  
  // State to track the selected payment method
  String _selectedPaymentMethod = 'Card'; // Default to Credit Card

  // Controllers for address fields (for basic form handling)
  final _fullNameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Controllers for card fields (minimal)
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  // State for loading
  bool _isProcessingOrder = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressLine1Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total price including shipping
    final double shippingFee = 100;
    final double subtotal = widget.cartManager.totalPrice;
    final double total = subtotal + shippingFee;

    return Scaffold(
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.playfairDisplay(color: AppConstant.TEXT_PRIMARY),
        ),
        backgroundColor: AppConstant.SURFACE_COLOR,
        foregroundColor: AppConstant.TEXT_PRIMARY,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        children: [
          // 1. Shipping Address Section
          _buildSection('Shipping Address', [
            _buildTextField('Full Name', _fullNameController),
            _buildTextField('Address Line 1', _addressLine1Controller),
            Row(
              children: [
                Expanded(child: _buildTextField('City', _cityController)),
                const SizedBox(width: AppConstant.PADDING_MEDIUM),
                Expanded(child: _buildTextField('Postal Code', _postalCodeController)),
              ],
            ),
          ]),
          const SizedBox(height: AppConstant.PADDING_LARGE),

          // 2. Payment Method Selector
          _buildPaymentMethodSelector(),
          const SizedBox(height: AppConstant.PADDING_LARGE),

          // 3. Conditional Payment Fields based on selection
          _buildPaymentFields(),
          const SizedBox(height: AppConstant.PADDING_LARGE),

          // 4. Order Summary
          _buildOrderSummary(subtotal, shippingFee, total),
        ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.2),
      ),
      bottomNavigationBar: _buildConfirmButton(context, total),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Card(
      color: AppConstant.SURFACE_COLOR,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: GoogleFonts.playfairDisplay(
                fontSize: AppConstant.FONT_TITLE,
                color: AppConstant.PRIMARY_COLOR,
              ),
            ),
            const SizedBox(height: AppConstant.PADDING_MEDIUM),

            _buildPaymentOptionTile('Card', 'Credit/Debit Card (Visa, Mastercard)', Icons.credit_card_outlined),
            _buildPaymentOptionTile('COD', 'Cash on Delivery (Pay when you receive the order)', Icons.delivery_dining),
            _buildPaymentOptionTile('MobileWallet', 'JazzCash / EasyPaisa', Icons.mobile_friendly_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile(String value, String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        activeColor: AppConstant.PRIMARY_COLOR,
        onChanged: (String? newValue) {
          setState(() {
            _selectedPaymentMethod = newValue!;
          });
        },
      ),
      title: Text(
        title,
        style: GoogleFonts.lato(color: AppConstant.TEXT_PRIMARY),
      ),
      trailing: Icon(icon, color: AppConstant.TEXT_SECONDARY),
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
    );
  }

  Widget _buildPaymentFields() {
    String title;
    List<Widget> fields;

    switch (_selectedPaymentMethod) {
      case 'Card':
        title = 'Card Details';
        fields = [
          _buildTextField('Card Number', _cardNumberController, keyboardType: TextInputType.number),
          Row(
            children: [
              Expanded(child: _buildTextField('Expiry (MM/YY)', _expiryController, keyboardType: TextInputType.datetime)),
              const SizedBox(width: AppConstant.PADDING_MEDIUM),
              Expanded(child: _buildTextField('CVC', _cvcController, isSecret: true, keyboardType: TextInputType.number)),
            ],
          ),
        ];
        break;
      case 'COD':
        title = 'Cash on Delivery';
        fields = [
          Text(
            'You have selected Cash on Delivery. Please keep \$${(widget.cartManager.totalPrice + 5.00).toStringAsFixed(2)} ready at the time of delivery.',
            style: GoogleFonts.lato(color: AppConstant.TEXT_PRIMARY),
          ),
          const SizedBox(height: AppConstant.PADDING_SMALL),
          Text(
            'Note: COD orders may take slightly longer to process.',
            style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY, fontStyle: FontStyle.italic),
          ),
        ];
        break;
      case 'MobileWallet':
        title = 'Pay with JazzCash / EasyPaisa';
        fields = [
          _buildTextField('Mobile Wallet Number', TextEditingController(), keyboardType: TextInputType.phone),
          Text(
            'After placing the order, you will receive a payment request on your mobile number to complete the transaction via JazzCash or EasyPaisa.',
            style: GoogleFonts.lato(color: AppConstant.TEXT_PRIMARY),
          ),
        ];
        break;
      default:
        return const SizedBox.shrink();
    }

    return _buildSection(title, fields);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: AppConstant.SURFACE_COLOR,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: AppConstant.FONT_TITLE,
                color: AppConstant.PRIMARY_COLOR,
              ),
            ),
            const SizedBox(height: AppConstant.PADDING_MEDIUM),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isSecret = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstant.PADDING_MEDIUM),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isSecret,
        style: const TextStyle(color: AppConstant.TEXT_PRIMARY),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppConstant.TEXT_SECONDARY),
          filled: true,
          fillColor: AppConstant.BACKGROUND_COLOR,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
            borderSide: const BorderSide(color: AppConstant.PRIMARY_COLOR),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double shippingFee, double total) {
    return Card(
      color: AppConstant.SURFACE_COLOR,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: GoogleFonts.playfairDisplay(
                  fontSize: AppConstant.FONT_TITLE, color: AppConstant.PRIMARY_COLOR),
            ),
            const SizedBox(height: AppConstant.PADDING_MEDIUM),
            _summaryRow('Subtotal', subtotal),
            _summaryRow('Shipping', shippingFee),
            const Divider(color: AppConstant.TEXT_SECONDARY),
            _summaryRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstant.PADDING_SMALL / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              color: isTotal ? AppConstant.TEXT_PRIMARY : AppConstant.TEXT_SECONDARY,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}',
            style: GoogleFonts.lato(
              color: isTotal ? AppConstant.PRIMARY_COLOR : AppConstant.TEXT_PRIMARY,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? AppConstant.FONT_SUBTITLE : AppConstant.FONT_BODY,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, double total) {
    return Padding(
      padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + AppConstant.PADDING_SMALL,
      ),
      child: ElevatedButton(
        // Disable button while processing
        onPressed: _isProcessingOrder ? null : () => _processOrder(total),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstant.PRIMARY_COLOR,
          foregroundColor: AppConstant.BACKGROUND_COLOR,
          padding: const EdgeInsets.symmetric(vertical: AppConstant.PADDING_MEDIUM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
          ),
        ),
        child: _isProcessingOrder 
          ? const SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(
                color: AppConstant.BACKGROUND_COLOR, 
                strokeWidth: 3.0,
              )
            )
          : Text(
            'Confirm Order (${_selectedPaymentMethod == 'COD' ? 'COD' : 'Pay ${total.toStringAsFixed(2)}'})',
            style: GoogleFonts.lato(fontSize: AppConstant.FONT_SUBTITLE, fontWeight: FontWeight.bold),
          ),
      ),
    );
  }


  Future<void> _processOrder(double totalAmount) async {
    if (_isProcessingOrder) return;

    // 1. Basic Validation
    if (_fullNameController.text.isEmpty || _addressLine1Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full shipping address.'),
          backgroundColor: AppConstant.ERROR_COLOR,
        ),
      );
      return;
    }
    
    final User? user = _supabaseService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in before placing an order.'),
          backgroundColor: AppConstant.ERROR_COLOR,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      await _supabaseService.saveShippingAddress(
        fullName: _fullNameController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      );
      
    
      final orderItems = widget.cartManager.cartItems
          .map((item) => item.toMapForOrder()) 
          .toList();
      
  
      final String initialStatus = _selectedPaymentMethod == 'COD' ? 'Pending' : 'Processing';

      await _supabaseService.finalizeCheckout(
        totalAmount: totalAmount,
        orderItems: orderItems,
        initialStatus: initialStatus,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrderConfirmationPage()),
          (Route<dynamic> route) => false,
        );
      }

    } catch (e) {
      debugPrint('Order Processing Failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order. Please try again. Error: $e'),
            backgroundColor: AppConstant.ERROR_COLOR,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOrder = false;
        });
      }
    }
  }
}

