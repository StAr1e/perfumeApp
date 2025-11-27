import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/models/perfume_models.dart';
import 'package:nodhapp/widgets/shimmer_widget.dart';
import 'package:nodhapp/providers/cart_manager.dart';

class ProductDetailPage extends StatefulWidget {
  final Perfume perfume;
  final CartManager cartManager;

  const ProductDetailPage({
    super.key,
    required this.perfume,
    required this.cartManager,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String _selectedSize = '50ml';
  final int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.55,
            pinned: true,
            backgroundColor: AppConstant.BACKGROUND_COLOR,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppConstant.TEXT_PRIMARY),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.perfume.id,
                child: Container(
                  color: AppConstant.SECONDARY_COLOR.withOpacity(0.2),
                  child: CachedNetworkImage(
                    imageUrl: widget.perfume.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const ShimmerWidget(
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: 0,
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppConstant.PADDING_LARGE),
              decoration: const BoxDecoration(
                color: AppConstant.SURFACE_COLOR,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConstant.BORDER_RADIUS * 2),
                  topRight: Radius.circular(AppConstant.BORDER_RADIUS * 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppConstant.PADDING_MEDIUM),
                  _buildDescription(),
                  const SizedBox(height: AppConstant.PADDING_LARGE),
                  _buildSizeSelector(),
                  const SizedBox(height: AppConstant.PADDING_LARGE),
                  _buildNotesSection(),
                  const SizedBox(height: AppConstant.PADDING_LARGE * 2),
                ],
              ),
            ).animate().slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.perfume.brand.toUpperCase(),
          style: GoogleFonts.lato(
            color: AppConstant.TEXT_SECONDARY,
            fontSize: AppConstant.FONT_BODY,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppConstant.PADDING_SMALL),
        Text(
          widget.perfume.name,
          style: GoogleFonts.playfairDisplay(
            color: AppConstant.TEXT_PRIMARY,
            fontSize: AppConstant.FONT_DISPLAY,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.perfume.description,
      style: GoogleFonts.lato(
        color: AppConstant.TEXT_SECONDARY,
        fontSize: AppConstant.FONT_SUBTITLE,
        height: 1.6,
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: GoogleFonts.playfairDisplay(
              fontSize: AppConstant.FONT_TITLE, fontWeight: FontWeight.w600, color: AppConstant.TEXT_PRIMARY),
        ),
        const SizedBox(height: AppConstant.PADDING_MEDIUM),
        Row(
          children: widget.perfume.prices.keys.map((size) {
            bool isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: AppConstant.PADDING_MEDIUM),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstant.PRIMARY_COLOR : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
                  border: Border.all(color: isSelected ? AppConstant.PRIMARY_COLOR : AppConstant.TEXT_SECONDARY),
                ),
                child: Text(
                  size,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppConstant.BACKGROUND_COLOR : AppConstant.TEXT_PRIMARY,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scent Profile',
          style: GoogleFonts.playfairDisplay(
            fontSize: AppConstant.FONT_TITLE,
            fontWeight: FontWeight.w600,
            color: AppConstant.TEXT_PRIMARY,
          ),
        ),
        const SizedBox(height: AppConstant.PADDING_MEDIUM),
        _buildNoteRow('Top Notes', widget.perfume.notes['top']!),
        const Divider(height: AppConstant.PADDING_LARGE, color: AppConstant.BACKGROUND_COLOR),
        _buildNoteRow('Heart Notes', widget.perfume.notes['heart']!),
        const Divider(height: AppConstant.PADDING_LARGE, color: AppConstant.BACKGROUND_COLOR),
        _buildNoteRow('Base Notes', widget.perfume.notes['base']!),
      ],
    );
  }

  Widget _buildNoteRow(String title, String notes) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: GoogleFonts.lato(
              color: AppConstant.TEXT_PRIMARY,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            notes,
            style: GoogleFonts.lato(
              color: AppConstant.TEXT_SECONDARY,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + AppConstant.PADDING_SMALL,
      ),
      decoration: BoxDecoration(
        color: AppConstant.SURFACE_COLOR,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY, fontSize: AppConstant.FONT_BODY),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '\$${widget.perfume.prices[_selectedSize]!.toStringAsFixed(2)}',
                    key: ValueKey<String>(_selectedSize),
                    style: GoogleFonts.playfairDisplay(
                      color: AppConstant.TEXT_PRIMARY,
                      fontSize: AppConstant.FONT_HEADLINE,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.cartManager.addToCart(widget.perfume, _selectedSize, _quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.perfume.name} ($_selectedSize) added to cart!'),
                  backgroundColor: AppConstant.PRIMARY_COLOR,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstant.PRIMARY_COLOR,
              foregroundColor: AppConstant.BACKGROUND_COLOR,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstant.PADDING_LARGE,
                vertical: AppConstant.PADDING_MEDIUM,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20),
                const SizedBox(width: AppConstant.PADDING_SMALL),
                Text(
                  'Add to Cart',
                  style: GoogleFonts.lato(
                    fontSize: AppConstant.FONT_SUBTITLE,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, delay: 200.ms, duration: 400.ms);
  }
}