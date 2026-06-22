import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:shop_app/core/router/app_router.dart';
import 'package:shop_app/core/theme/app_theme.dart';
import 'package:shop_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shop_app/features/products/domain/entities/product.dart';
import 'package:shop_app/features/products/presentation/widgets/shared_widgets.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.productDetailPath(product.id),
        extra: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      color: cs.surface,
                      child: AppNetworkImage(
                        url: product.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm + 2,
                  AppSpacing.sm,
                  AppSpacing.sm + 2,
                  AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall?.copyWith(
                      color: cs.onSurface,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  StarRating(
                      rating: product.rating, count: product.ratingCount),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: tt.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      _AddButton(product: product),
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

class _AddButton extends StatelessWidget {
  final Product product;
  const _AddButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final inCart = state is CartLoaded &&
            state.items.any((i) => i.product.id == product.id);

        return GestureDetector(
          onTap: () {
            context
                .read<CartBloc>()
                .add(AddToCartEvent(product: product));
            if (!inCart) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added to cart'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1200),
                  backgroundColor: cs.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: inCart ? cs.primary : cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              inCart ? Icons.check_rounded : Icons.add_rounded,
              color: inCart ? Colors.white : cs.primary,
              size: 18,
            ),
          ),
        );
      },
    );
  }
}