import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/core/router.dart';
import 'package:shop_app/core/theme.dart';
import 'package:shop_app/feature/cart/presnetation/bloc/cart_bloc.dart';
import 'package:shop_app/feature/products/domains/entities/product_entity.dart';
import 'package:shop_app/feature/products/presentation/widget/shared_widget.dart';
class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero image ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: size.height * 0.42,
                pinned: true,
                backgroundColor: cs.surface,
                leading: _BackButton(),
                actions: [_CartButton()],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: cs.surface,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: AppNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // ── Content ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      Chip(label: Text(product.category)),
                      const SizedBox(height: AppSpacing.sm),
                      // Title
                      Text(product.title,
                          style: tt.headlineMedium?.copyWith(height: 1.25)),
                      const SizedBox(height: AppSpacing.sm),
                      // Rating + count
                      StarRating(
                        rating: product.rating,
                        count: product.ratingCount,
                        iconSize: 18,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Price
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: tt.displayMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Description heading
                      Text('Description',
                          style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        product.description,
                        style: tt.bodyLarge?.copyWith(
                          height: 1.65,
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      // Bottom padding so the floating button doesn't cover
                      // text on short devices.
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Floating add-to-cart bar ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _AddToCartBar(product: product),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.cart),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: BlocBuilder<CartBloc, CartState>(
            builder: (_, state) {
              final count = state is CartLoaded ? state.totalQuantity : 0;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: const Icon(Icons.shopping_bag_outlined, size: 20),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final Product product;
  const _AddToCartBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final inCart = state is CartLoaded &&
              state.items.any((i) => i.product.id == product.id);
          final quantity = state is CartLoaded
              ? state.items
                  .where((i) => i.product.id == product.id)
                  .fold(0, (sum, i) => sum + i.quantity)
              : 0;

          return Row(
            children: [
              if (inCart) _QuantitySelector(product: product, qty: quantity),
              if (!inCart)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<CartBloc>()
                          .add(AddToCartEvent(product: product));
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Add to Cart'),
                  ),
                ),
              if (inCart) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.cart),
                    icon: const Icon(Icons.shopping_bag_rounded),
                    label: const Text('View Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.secondary,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final Product product;
  final int qty;
  const _QuantitySelector({required this.product, required this.qty});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove_rounded,
            onTap: () => context
                .read<CartBloc>()
                .add(UpdateQuantityEvent(productId: product.id, quantity: qty - 1)),
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                '$qty',
                style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add_rounded,
            onTap: () => context
                .read<CartBloc>()
                .add(UpdateQuantityEvent(productId: product.id, quantity: qty + 1)),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}