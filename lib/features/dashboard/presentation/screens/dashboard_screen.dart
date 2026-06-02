import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecommerce_app/features/location/presentation/providers/location_provider.dart';
import 'package:ecommerce_app/core/theme/theme_provider.dart';
import 'package:ecommerce_app/features/products/presentation/providers/product_provider.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:ecommerce_app/core/widgets/connectivity_banner.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_card.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/search_filter_bar.dart';
import 'package:ecommerce_app/core/widgets/shimmer_loading.dart';
import 'package:ecommerce_app/core/widgets/error_display.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationNotifierProvider.notifier).fetchLocation();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final productState = ref.watch(productNotifierProvider);
    final cartState = ref.watch(cartNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ConnectivityBanner(),
            _buildHeader(authState, locationState, cartState, isDark),
            const SearchFilterBar(),
            Expanded(
              child: _buildProductList(productState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthState authState, LocationState locationState, CartState cartState, bool isDark) {
    final user = authState.user;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              if (user?.photoURL != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: CachedNetworkImage(
                    imageUrl: user!.photoURL!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppTheme.primaryColor),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppTheme.primaryColor),
                    ),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.displayName?.split(' ').first ?? 'Guest'} 👋',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (locationState.isLoading)
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Fetching location...',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      )
                    else if (locationState.address != null)
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.accentColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationState.address!,
                              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else if (locationState.error != null)
                      GestureDetector(
                        onTap: () => ref.read(locationNotifierProvider.notifier).fetchLocation(),
                        child: Row(
                          children: [
                            const Icon(Icons.location_off_rounded, size: 14, color: AppTheme.errorColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Tap to retry location',
                                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.errorColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => context.push('/cart'),
                    icon: const Icon(Icons.shopping_cart_rounded),
                  ),
                  if (cartState.totalItems > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${cartState.totalItems}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  if (value == 'logout') {
                    ref.read(authNotifierProvider.notifier).signOut();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'email',
                    enabled: false,
                    child: Text(
                      authState.user?.email ?? '',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, size: 20, color: AppTheme.errorColor),
                        const SizedBox(width: 8),
                        Text('Logout', style: GoogleFonts.inter(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(ProductListState productState) {
    if (productState.isLoading) {
      return const ProductListShimmer();
    }

    if (productState.error != null && productState.products.isEmpty) {
      return ErrorDisplay(
        message: productState.error!,
        onRetry: () => ref.read(productNotifierProvider.notifier).refresh(),
      );
    }

    if (productState.products.isEmpty) {
      return ErrorDisplay(
        message: 'No products found',
        icon: Icons.inventory_2_rounded,
        onRetry: () => ref.read(productNotifierProvider.notifier).clearFilters(),
      );
    }

    final products = productState.sortedProducts;

    return RefreshIndicator(
      onRefresh: () => ref.read(productNotifierProvider.notifier).refresh(),
      color: AppTheme.primaryColor,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length + (productState.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            return const ProductCardShimmer();
          }
          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}
