import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:shop_app/core/router/app_router.dart';
import 'package:shop_app/core/theme/app_theme.dart';
import 'package:shop_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shop_app/features/products/presentation/bloc/product_bloc.dart';
import 'package:shop_app/features/products/presentation/widgets/product_card.dart';
import 'package:shop_app/features/products/presentation/widgets/shared_widgets.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts());
    context.read<CartBloc>().add(LoadCartEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Discover', style: tt.displayMedium),
                          Text('Find your perfect product',
                              style: tt.bodyMedium?.copyWith(
                                  color: cs.outline)),
                        ],
                      ),
                    ),
                    _CartBadgeButton(),
                    const SizedBox(width: AppSpacing.sm),
                    _ThemeToggleButton(),
                  ],
                ),
              ),
            ),
            // ── Search bar ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  onChanged: (q) =>
                      context.read<ProductBloc>().add(SearchProducts(q)),
                  decoration: InputDecoration(
                    hintText: 'Search products…',
                    prefixIcon: Icon(Icons.search_rounded,
                        color: cs.outline, size: 20),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (_, value, __) => value.text.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<ProductBloc>()
                                    .add(const SearchProducts(''));
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            // ── Category chips ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is! ProductLoaded) return const SizedBox.shrink();
                  return CategoryChips(
                    categories: state.categories,
                    selected: state.selectedCategory,
                    onTap: (cat) =>
                        context.read<ProductBloc>().add(FilterByCategory(cat)),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            // ── Product grid ──────────────────────────────────────────────
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return _ShimmerGrid();
                }
                if (state is ProductError) {
                  return SliverFillRemaining(
                    child: ErrorState(
                      message: state.message,
                      onRetry: () =>
                          context.read<ProductBloc>().add(const LoadProducts()),
                    ),
                  );
                }
                if (state is ProductLoaded) {
                  if (state.filteredProducts.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No results',
                        subtitle:
                            'Try a different search term or category.',
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ProductCard(
                            product: state.filteredProducts[i]),
                        childCount: state.filteredProducts.length,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart icon button with live badge count
// ─────────────────────────────────────────────────────────────────────────────
class _CartBadgeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final count =
            state is CartLoaded ? state.totalQuantity : 0;

        return GestureDetector(
          onTap: () => context.push(AppRoutes.cart),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Stack(
              children: [
                const Center(
                    child: Icon(Icons.shopping_bag_outlined, size: 22)),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Dark/light mode toggle — reads from nearest ThemeSwitcher ancestor
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => ThemeSwitcher.of(context).toggle(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          size: 20,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer loading grid
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => const ShimmerCard(),
          childCount: 8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme switcher — InheritedWidget so any descendant can toggle the theme
// without going through the BLoC.
// ─────────────────────────────────────────────────────────────────────────────
class ThemeSwitcher extends InheritedWidget {
  final VoidCallback toggle;

  const ThemeSwitcher({
    super.key,
    required this.toggle,
    required super.child,
  });

  static ThemeSwitcher of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>();
    assert(result != null, 'ThemeSwitcher not found in widget tree');
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeSwitcher old) => false;
