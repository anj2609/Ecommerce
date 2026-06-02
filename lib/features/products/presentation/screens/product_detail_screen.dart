import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/products/presentation/providers/product_provider.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:ecommerce_app/core/widgets/error_display.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: product.images.length,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: product.images[index],
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: AppTheme.shimmerBase,
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppTheme.shimmerBase,
                              child: const Icon(Icons.broken_image_rounded, size: 48),
                            ),
                          );
                        },
                      ),
                      if (product.images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              product.images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentImageIndex == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == index
                                      ? AppTheme.primaryColor
                                      : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (product.discountPercentage > 0)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.brand,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${product.discountedPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (product.discountPercentage > 0) ...[
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  color: AppTheme.textLight,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppTheme.textLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Save \$${(product.price - product.discountedPrice).toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(Icons.category_rounded, 'Category', product.category),
                      _buildInfoRow(Icons.inventory_rounded, 'Availability', product.availabilityStatus),
                      _buildInfoRow(Icons.local_shipping_rounded, 'Shipping', product.shippingInformation),
                      _buildInfoRow(Icons.shield_rounded, 'Warranty', product.warrantyInformation),
                      _buildInfoRow(Icons.assignment_return_rounded, 'Returns', product.returnPolicy),
                      _buildInfoRow(Icons.shopping_bag_rounded, 'Min. Order', '${product.minimumOrderQuantity} units'),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      if (product.tags.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '#$tag',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorDisplay(
          message: 'Failed to load product details',
          onRetry: () => ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
      bottomNavigationBar: productAsync.whenOrNull(
        data: (product) {
          final isInCart = cartState.isInCart(product.id);
          final quantity = cartState.getQuantity(product.id);

          return Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (isInCart)
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.dividerColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => ref.read(cartNotifierProvider.notifier).decrementQuantity(product.id),
                            icon: const Icon(Icons.remove_rounded),
                            color: AppTheme.primaryColor,
                          ),
                          Text(
                            '$quantity',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref.read(cartNotifierProvider.notifier).incrementQuantity(product.id),
                            icon: const Icon(Icons.add_rounded),
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (isInCart) const SizedBox(width: 12),
                Expanded(
                  flex: isInCart ? 1 : 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!isInCart) {
                          ref.read(cartNotifierProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} added to cart'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInCart ? AppTheme.successColor : AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isInCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isInCart ? 'In Cart' : 'Add to Cart',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
