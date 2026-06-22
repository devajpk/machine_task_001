import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_app/features/cart/presentation/pages/cart_page.dart';
import 'package:shop_app/features/products/domain/entities/product.dart';
import 'package:shop_app/features/products/presentation/pages/product_detail_page.dart';
import 'package:shop_app/features/products/presentation/pages/product_list_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route names as typed constants so every call-site is refactor-safe.
// ─────────────────────────────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const home = '/';
  static const productDetail = '/product/:id';
  static const cart = '/cart';

  static String productDetailPath(int id) => '/product/$id';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const ProductListPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      pageBuilder: (context, state) {
        // Product is passed as an extra so we never need a second network call.
        final product = state.extra as Product;
        return _slideTransition(state, ProductDetailPage(product: product));
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      pageBuilder: (context, state) => _slideTransition(
        state,
        const CartPage(),
      ),
    ),
  ],
);

CustomTransitionPage<void> _fadeTransition(
  GoRouterState state,
  Widget child,
) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
    );

CustomTransitionPage<void> _slideTransition(
  GoRouterState state,
  Widget child,
) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, __, c) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: c);
      },
    );