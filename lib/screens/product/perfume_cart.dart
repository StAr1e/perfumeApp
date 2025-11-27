import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/models/perfume_models.dart';
import 'package:nodhapp/screens/product/product_page_details.dart';
import 'package:nodhapp/widgets/shimmer_widget.dart';
import 'package:nodhapp/providers/cart_manager.dart';

class PerfumeCard extends StatelessWidget {
  final Perfume perfume;
  final CartManager cartManager;

  const PerfumeCard({
    super.key,
    required this.perfume,
    required this.cartManager,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(perfume: perfume, cartManager: cartManager),
          ),
        );
      },
      child: Card(
        color: AppConstant.SURFACE_COLOR,
        elevation: AppConstant.ELEVATION,
        shadowColor: AppConstant.PRIMARY_COLOR.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: perfume.id,
                child: Container(
                  color: AppConstant.SECONDARY_COLOR.withOpacity(0.1),
                  child: CachedNetworkImage(
                    imageUrl: perfume.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (context, url) => const ShimmerWidget(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 0,
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, color: AppConstant.TEXT_SECONDARY),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perfume.name,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstant.FONT_SUBTITLE,
                      color: AppConstant.TEXT_PRIMARY,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    perfume.brand,
                    style: GoogleFonts.lato(
                      color: AppConstant.TEXT_SECONDARY,
                      fontSize: AppConstant.FONT_CAPTION,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${perfume.prices['50ml']!.toStringAsFixed(2)}',
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w700,
                          fontSize: AppConstant.FONT_SUBTITLE,
                          color: AppConstant.PRIMARY_COLOR,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Add the default size (50ml) to the cart
                          cartManager.addToCart(perfume, '50ml', 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${perfume.name} (50ml) added to cart!'),
                              backgroundColor: AppConstant.PRIMARY_COLOR,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, color: AppConstant.TEXT_SECONDARY, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}