import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/providers/cart_manager.dart';
import 'package:nodhapp/models/cart_item_model.dart';
import 'checkout_page.dart';
import 'package:nodhapp/widgets/shimmer_widget.dart';
import 'package:nodhapp/services/supabase_service.dart';
import 'package:nodhapp/screens/login/login_page.dart';
class CartPage extends StatefulWidget {
  final CartManager cartManager;
  const CartPage({super.key, required this.cartManager});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cartManager,
      builder: (context, child) {
        if (_supabaseService.currentUser == null) {
          return _buildLoggedOutState();
        }
        return Scaffold(
          backgroundColor: AppConstant.BACKGROUND_COLOR,
          body: widget.cartManager.isLoading
              ? _buildLoadingState()
              : widget.cartManager.cartItems.isEmpty
                  ? _buildEmptyState()
                  : _buildCartContent(),
        );
      },
    );
  }

  Widget _buildLoggedOutState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.login, size: 80, color: AppConstant.TEXT_SECONDARY),
          const SizedBox(height: AppConstant.PADDING_MEDIUM),
          Text(
            'Login to View Your Cart',
            style: GoogleFonts.playfairDisplay(fontSize: AppConstant.FONT_TITLE, color: AppConstant.TEXT_PRIMARY),
          ),
          const SizedBox(height: AppConstant.PADDING_MEDIUM),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstant.PRIMARY_COLOR,
              foregroundColor: AppConstant.BACKGROUND_COLOR,
            ),
            child: const Text('Login / Sign Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
        child: Row(
          children: [
            const ShimmerWidget(width: 80, height: 80),
            const SizedBox(width: AppConstant.PADDING_MEDIUM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerWidget(width: 150, height: 20),
                  SizedBox(height: AppConstant.PADDING_SMALL),
                  ShimmerWidget(width: 100, height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: AppConstant.TEXT_SECONDARY,
          ),
          const SizedBox(height: AppConstant.PADDING_MEDIUM),
          Text(
            'Your Cart is Empty',
            style: GoogleFonts.playfairDisplay(
              fontSize: AppConstant.FONT_TITLE,
              color: AppConstant.TEXT_PRIMARY,
            ),
          ),
          const SizedBox(height: AppConstant.PADDING_SMALL),
          Text(
            'Looks like you haven\'t added anything yet.',
            style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
            itemCount: widget.cartManager.cartItems.length,
            itemBuilder: (context, index) {
              final item = widget.cartManager.cartItems[index];
              return _buildCartItemCard(item).animate().fadeIn(delay: (100 * index).ms).slideX(begin: -0.2);
            },
          ),
        ),
        _buildSummaryAndCheckout(),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      color: AppConstant.SURFACE_COLOR,
      margin: const EdgeInsets.only(bottom: AppConstant.PADDING_MEDIUM),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstant.PADDING_SMALL),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS / 2),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                placeholder: (context, url) => const ShimmerWidget(width: 80, height: 80),
              ),
            ),
            const SizedBox(width: AppConstant.PADDING_MEDIUM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: AppConstant.TEXT_PRIMARY),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.brand} • ${item.size}',
                    style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY, fontSize: AppConstant.FONT_CAPTION),
                  ),
                  const SizedBox(height: AppConstant.PADDING_SMALL),
                  Text(
                    '${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.playfairDisplay(
                        color: AppConstant.PRIMARY_COLOR, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _buildQuantityControl(item),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstant.BACKGROUND_COLOR,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16, color: AppConstant.TEXT_PRIMARY),
            onPressed: item.id != null ? () {
              widget.cartManager.updateQuantity(item.id!, item.quantity - 1);
            } : null,
          ),
          Text(
            item.quantity.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstant.TEXT_PRIMARY),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16, color: AppConstant.TEXT_PRIMARY),
            onPressed: item.id != null ? () {
              widget.cartManager.updateQuantity(item.id!, item.quantity + 1);
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryAndCheckout() {
    return Container(
      padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + AppConstant.PADDING_SMALL,
      ),
      decoration: BoxDecoration(
        color: AppConstant.SURFACE_COLOR,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstant.BORDER_RADIUS * 2),
          topRight: Radius.circular(AppConstant.BORDER_RADIUS * 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY, fontSize: AppConstant.FONT_SUBTITLE),
              ),
              Text(
                '${widget.cartManager.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.playfairDisplay(
                    color: AppConstant.TEXT_PRIMARY,
                    fontSize: AppConstant.FONT_TITLE,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppConstant.PADDING_MEDIUM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutPage(cartManager: widget.cartManager)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstant.PRIMARY_COLOR,
                foregroundColor: AppConstant.BACKGROUND_COLOR,
                padding: const EdgeInsets.symmetric(vertical: AppConstant.PADDING_MEDIUM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: GoogleFonts.lato(fontSize: AppConstant.FONT_SUBTITLE, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, duration: 400.ms);
  }
}