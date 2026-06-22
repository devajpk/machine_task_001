import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/core/theme.dart';
import 'package:shop_app/feature/cart/presnetation/bloc/cart_bloc.dart';
import 'package:shop_app/feature/cart/presnetation/widget/cart_item.dart';
import 'package:shop_app/feature/products/presentation/widget/shared_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartError) {
              return ErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<CartBloc>().add(LoadCartEvent()),
              );
            }

            if (state is! CartLoaded || state.items.isEmpty) {
              return Column(
                children: [
                  _CartAppBar(),
                  Expanded(
                    child: EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Your cart is empty',
                      subtitle:
                          'Looks like you haven\'t added anything yet.',
                      ctaLabel: 'Start Shopping',
                      onCta: () => context.pop(),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _CartAppBar(count: state.items.length),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) =>
                        _CartItemCard(item: state.items[i]),
                  ),
                ),
                _OrderSummary(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartAppBar extends StatelessWidget {
  final int count;
  const _CartAppBar({this.count = 0});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Cart', style: tt.headlineMedium),
                if (count > 0)
                  Text(
                    '$count ${count == 1 ? 'item' : 'items'}',
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
              ],
            ),
          ),
          if (count > 0)
            TextButton(
              onPressed: () => _confirmClear(context),
              child: Text(
                'Clear all',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear cart?'),
        content:
            const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(ClearCartEvent());
              Navigator.pop(context);
            },
            child: Text('Clear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(item.product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context
          .read<CartBloc>()
          .add(RemoveFromCartEvent(productId: item.product.id)),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 26),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.lg)),
              child: Container(
                width: 88,
                height: 88,
                color: cs.surface,
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: AppNetworkImage(
                  url: item.product.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                          color: cs.onSurface, height: 1.3),
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)}',
                      style: tt.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _InlineQtyBtn(
                          icon: Icons.remove_rounded,
                          onTap: () => context.read<CartBloc>().add(
                                UpdateQuantityEvent(
                                  productId: item.product.id,
                                  quantity: item.quantity - 1,
                                ),
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm),
                          child: Text(
                            '${item.quantity}',
                            style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        _InlineQtyBtn(
                          icon: Icons.add_rounded,
                          onTap: () => context.read<CartBloc>().add(
                                UpdateQuantityEvent(
                                  productId: item.product.id,
                                  quantity: item.quantity + 1,
                                ),
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          style: tt.titleMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _InlineQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 16, color: cs.primary),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartLoaded state;
  const _OrderSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    const shipping = 4.99;
    final subtotal = state.total;
    final tax = subtotal * 0.08;
    final grandTotal = subtotal + shipping + tax;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
              label: 'Subtotal',
              value: '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
              label: 'Shipping',
              value: '\$${shipping.toStringAsFixed(2)}'),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
              label: 'Tax (8%)',
              value: '\$${tax.toStringAsFixed(2)}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(color: cs.outline.withValues(alpha: 0.2)),
          ),
          Row(
            children: [
              Text('Total', style: tt.titleLarge),
              const Spacer(),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: tt.headlineMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCheckoutConfirm(context, grandTotal),
              icon: const Icon(Icons.payment_rounded),
              label: Text('Proceed to Checkout — '
                  '\$${grandTotal.toStringAsFixed(2)}'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutConfirm(BuildContext context, double total) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(total: total),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(label,
            style: tt.bodyMedium?.copyWith(color: cs.outline)),
        const Spacer(),
        Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CheckoutSheet extends StatelessWidget {
  final double total;
  const _CheckoutSheet({required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Confirm Order', style: tt.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your order of \$${total.toStringAsFixed(2)} will be placed.',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartBloc>().add(ClearCartEvent());
                    Navigator.pop(context);
                    _showSuccess(context);
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text('Order Placed!',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thank you! Your order is on its way.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop(); // back to listing
                },
                child: const Text('Continue Shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}