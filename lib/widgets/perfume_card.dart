import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/models/perfume_models.dart';
import 'package:nodhapp/providers/cart_manager.dart';

class PerfumeCard extends StatefulWidget {
  final Perfume perfume;
  final CartManager cartManager;

  PerfumeCard({
    super.key,
    required this.perfume,
    required this.cartManager,
  });

  @override
  State<PerfumeCard> createState() => _PerfumeCardState();
}

class _PerfumeCardState extends State<PerfumeCard> {
  bool isFavorited = false;
  // 1. New State variable to track the selected volume/size
  late String _selectedVolume;

  @override
  void initState() {
    super.initState();
    // Initialize with the first available volume key (e.g., '50ml')
    _selectedVolume = widget.perfume.prices.keys.first;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
    // SnackBar logic
  }

  void _addToCart() {
    // We can now show the selected volume in the SnackBar, 
    // and ideally, the CartManager.addItem should take the selected volume/price
    widget.cartManager.addItem(widget.perfume); 
    // SnackBar logic: You might want to show "Added X ml Y perfume to cart"
  }

  // Helper method to get the price for the currently selected volume
  double _getDisplayPrice() {
    return widget.perfume.prices[_selectedVolume] ?? 0.0;
  }

  // Method to get a list of DropdownMenuItem
  List<DropdownMenuItem<String>> _getVolumeDropdownItems() {
    return widget.perfume.prices.keys.map((String volume) {
      return DropdownMenuItem<String>(
        value: volume,
        child: Text(
          volume,
          style: GoogleFonts.lato(
            fontSize: AppConstant.FONT_CAPTION,
            color: AppConstant.TEXT_PRIMARY,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get the price for the selected volume
    final displayPrice = _getDisplayPrice();

    return Container(
      decoration: BoxDecoration(
        color: AppConstant.SURFACE_COLOR,
        borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image and Heart Button using Stack
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstant.BORDER_RADIUS),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Image
                  Image.network(
                    widget.perfume.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppConstant.PRIMARY_COLOR,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                  // Heart Button (Positioned at top right)
                  Positioned(
                    top: AppConstant.PADDING_SMALL,
                    right: AppConstant.PADDING_SMALL,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(AppConstant.PADDING_EXTRA_SMALL),
                        decoration: BoxDecoration(
                          color: AppConstant.BACKGROUND_COLOR.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.redAccent : AppConstant.TEXT_PRIMARY,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Product Details
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstant.PADDING_SMALL,
              AppConstant.PADDING_SMALL,
              AppConstant.PADDING_SMALL,
              AppConstant.PADDING_EXTRA_SMALL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.perfume.name,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstant.FONT_BODY + 2,
                    color: AppConstant.TEXT_PRIMARY,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.perfume.brand,
                  style: GoogleFonts.lato(
                    fontSize: AppConstant.FONT_CAPTION,
                    color: AppConstant.TEXT_SECONDARY,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 3. Volume, Price, and Add to Cart Button
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstant.PADDING_SMALL,
              right: AppConstant.PADDING_SMALL,
              bottom: AppConstant.PADDING_SMALL,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Volume Dropdown Selector
                    Container(
                      height: 25, // Restrict height for a clean look
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: AppConstant.BACKGROUND_COLOR,
                        borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS_SMALL),
                        border: Border.all(color: AppConstant.TEXT_SECONDARY.withOpacity(0.5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVolume,
                          items: _getVolumeDropdownItems(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedVolume = newValue;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: AppConstant.TEXT_PRIMARY,
                            size: 18,
                          ),
                          isDense: true, // Make the button take less vertical space
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstant.PADDING_EXTRA_SMALL),
                    // Price - using the calculated displayPrice
                    Text(
                      '${displayPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstant.FONT_BODY,
                        color: AppConstant.PRIMARY_COLOR,
                      ),
                    ),
                  ],
                ),
                // Add to Cart Button
                GestureDetector(
                  onTap: _addToCart,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstant.PADDING_EXTRA_SMALL),
                    decoration: BoxDecoration(
                      color: AppConstant.PRIMARY_COLOR,
                      borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS_SMALL),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}