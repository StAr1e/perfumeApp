import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nodhapp/utils/app_constant.dart';
import 'package:nodhapp/models/perfume_models.dart';
import 'package:nodhapp/providers/cart_manager.dart';
import 'package:nodhapp/models/perfume_data.dart';

class PerfumeSearchDelegate extends SearchDelegate<Perfume?> {
  final List<Perfume> perfumes;
  final CartManager cartManager;

  PerfumeSearchDelegate({required this.perfumes, required this.cartManager});

  @override
  String get searchFieldLabel => 'Search perfumes or brands...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstant.BACKGROUND_COLOR,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstant.TEXT_PRIMARY),
        toolbarTextStyle: GoogleFonts.lato(color: AppConstant.TEXT_PRIMARY),
        titleTextStyle: GoogleFonts.lato(color: AppConstant.TEXT_PRIMARY),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = perfumes.where((p) {
      final queryLower = query.toLowerCase();
      return p.name.toLowerCase().contains(queryLower) ||
          p.brand.toLowerCase().contains(queryLower);
    }).toList();

    return _buildResultsGrid(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = perfumes.where((p) {
      final queryLower = query.toLowerCase();
      if (query.isEmpty) return false;
      return p.name.toLowerCase().contains(queryLower) ||
          p.brand.toLowerCase().contains(queryLower);
    }).toList();

    return _buildResultsGrid(suggestions);
  }

  Widget _buildResultsGrid(List<Perfume> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results found for "$query".',
          style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstant.PADDING_MEDIUM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstant.PADDING_MEDIUM,
        crossAxisSpacing: AppConstant.PADDING_MEDIUM,
        childAspectRatio: 0.65,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final perfume = results[index];
        return GestureDetector(
          onTap: () {
            // Return the selected perfume from the search delegate
            close(context, perfume);
          },
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.local_florist, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    perfume.name,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    perfume.brand,
                    style: GoogleFonts.lato(color: AppConstant.TEXT_SECONDARY, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}