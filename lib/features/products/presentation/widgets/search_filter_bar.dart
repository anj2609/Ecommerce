import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/products/presentation/providers/product_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilterBar extends ConsumerStatefulWidget {
  const SearchFilterBar({super.key});

  @override
  ConsumerState<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends ConsumerState<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(productNotifierProvider.notifier).searchProducts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productNotifierProvider.notifier).searchProducts('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip(
                        label: 'All',
                        isSelected: productState.selectedCategory == null && productState.searchQuery.isEmpty,
                        onTap: () => ref.read(productNotifierProvider.notifier).clearFilters(),
                      ),
                      ...productState.categories.map((cat) {
                        final name = cat is Map ? cat['name'] ?? cat['slug'] ?? '' : cat.toString();
                        final slug = cat is Map ? cat['slug'] ?? cat['name'] ?? '' : cat.toString();
                        return _buildFilterChip(
                          label: name.toString(),
                          isSelected: productState.selectedCategory == slug.toString(),
                          onTap: () => ref.read(productNotifierProvider.notifier).filterByCategory(slug.toString()),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<SortOption>(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: productState.sortOption != SortOption.none
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Icon(
                      Icons.sort_rounded,
                      size: 20,
                      color: productState.sortOption != SortOption.none
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                  onSelected: (option) {
                    ref.read(productNotifierProvider.notifier).setSortOption(option);
                  },
                  itemBuilder: (context) => [
                    _buildSortMenuItem('Default', SortOption.none, productState.sortOption),
                    _buildSortMenuItem('Price: Low to High', SortOption.priceLowToHigh, productState.sortOption),
                    _buildSortMenuItem('Price: High to Low', SortOption.priceHighToLow, productState.sortOption),
                    _buildSortMenuItem('Rating', SortOption.rating, productState.sortOption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<SortOption> _buildSortMenuItem(String label, SortOption option, SortOption current) {
    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          Icon(
            current == option ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 18,
            color: current == option ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 14)),
        ],
      ),
    );
  }
}
