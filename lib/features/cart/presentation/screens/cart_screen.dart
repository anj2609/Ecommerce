import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/core/widgets/error_display.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (cartState.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text('Clear Cart', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    content: Text(
                      'Are you sure you want to remove all items?',
                      style: GoogleFonts.inter(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).clearCart();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                        child: Text('Clear', style: GoogleFonts.inter()),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Clear All',
                style: GoogleFonts.inter(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? const EmptyState(
              message: 'Your cart is empty\nStart shopping to add items!',
              icon: Icons.shopping_cart_outlined,
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      return _CartItemCard(item: cartState.items[index]);
                    },
                  ),
                ),
                _buildCartSummary(context, cartState),
              ],
            ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartState cartState) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal (${cartState.totalItems} items)', '\$${cartState.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Discount',
            '-\$${cartState.totalDiscount.toStringAsFixed(2)}',
            valueColor: AppTheme.successColor,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '\$${cartState.totalPayable.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Checkout functionality coming soon!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Proceed to Checkout',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        ref.read(cartNotifierProvider.notifier).removeFromCart(item.productId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.thumbnail,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.shimmerBase,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.shimmerBase,
                  child: const Icon(Icons.image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.brand,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${item.discountedPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (item.discountPercentage > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => ref.read(cartNotifierProvider.notifier).incrementQuantity(item.productId),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(color: AppTheme.dividerColor),
                          ),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(cartNotifierProvider.notifier).decrementQuantity(item.productId),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(9)),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            item.quantity > 1 ? Icons.remove_rounded : Icons.delete_rounded,
                            size: 18,
                            color: item.quantity > 1 ? AppTheme.primaryColor : AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
