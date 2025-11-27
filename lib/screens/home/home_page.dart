import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/models/perfume_models.dart';
import 'package:nodhapp/models/perfume_data.dart';
// Note: This file will no longer be used if we define our own PerfumeCard
// import 'package:nodhapp/screens/product/perfume_cart.dart'; 
import 'package:nodhapp/providers/cart_manager.dart';

// Import the new custom widget
import 'package:nodhapp/widgets/perfume_card.dart'; // <--- NEW IMPORT

class HomePage extends StatefulWidget {
  final CartManager cartManager;
  const HomePage({super.key, required this.cartManager});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Perfume> perfumes = PerfumeData.getPerfumes();
  final List<String> categories = ['All', 'HOTHI', 'QAZI', 'MISK', 'QAZI', 'DASHT'];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.BACKGROUND_COLOR,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeroBanner(),
            _buildSectionHeader('Collections'),
            _buildCategoryList(),
            _buildSectionHeader('Popular'),
            _buildPerfumeGrid(),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeroBanner() {
  return SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
      padding: const EdgeInsets.all(AppConstant.PADDING_LARGE),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstant.BORDER_RADIUS * 1.5),
        image: const DecorationImage(
          image: AssetImage('assets/logo.jpg'),
          fit: BoxFit.cover, // 💥 CHANGED: Use BoxFit.cover to fill the box 💥
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstant.PRIMARY_COLOR.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '',
            style: GoogleFonts.playfairDisplay(
              fontSize: AppConstant.FONT_TITLE,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppConstant.PADDING_SMALL),
          Text(
            'New Collections',
            style: GoogleFonts.lato(
              fontSize: AppConstant.FONT_BODY,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
  );
}

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstant.PADDING_MEDIUM,
          AppConstant.PADDING_LARGE,
          AppConstant.PADDING_MEDIUM,
          AppConstant.PADDING_MEDIUM,
        ),
        child: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: AppConstant.FONT_HEADLINE,
            fontWeight: FontWeight.w600,
            color: AppConstant.TEXT_PRIMARY,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategoryList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          padding: const EdgeInsets.symmetric(horizontal: AppConstant.PADDING_MEDIUM),
          itemBuilder: (context, index) {
            bool isSelected = _selectedCategoryIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: AppConstant.PADDING_SMALL),
                padding: const EdgeInsets.symmetric(horizontal: AppConstant.PADDING_MEDIUM),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstant.PRIMARY_COLOR : AppConstant.SURFACE_COLOR,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppConstant.BACKGROUND_COLOR : AppConstant.TEXT_SECONDARY,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms).slideX(begin: 0.5);
          },
        ),
      ),
    );
  }

  SliverPadding _buildPerfumeGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppConstant.PADDING_MEDIUM,
          crossAxisSpacing: AppConstant.PADDING_MEDIUM,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Using the new PerfumeCard widget
            return PerfumeCard( 
              perfume: perfumes[index],
              cartManager: widget.cartManager,
            ).animate().fadeIn(delay: (150 * (index % 2)).ms).slideY(begin: 0.3);
          },
          childCount: perfumes.length,
        ),
      ),
    );
  }
}