import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shop_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shop_app/features/cart/data/sources/cart_local_source.dart';
import 'package:shop_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_app/features/cart/domain/usecases/add_to_cart.dart';
import 'package:shop_app/features/cart/domain/usecases/clear_cart.dart';
import 'package:shop_app/features/cart/domain/usecases/get_cart_items.dart';
import 'package:shop_app/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:shop_app/features/cart/domain/usecases/update_quantity.dart';
import 'package:shop_app/features/cart/presentation/bloc/cart_bloc.dart';

import 'package:shop_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:shop_app/features/products/data/sources/product_remote_source.dart';
import 'package:shop_app/features/products/domain/repositories/product_repository.dart';
import 'package:shop_app/features/products/domain/usecases/get_categories.dart';
import 'package:shop_app/features/products/domain/usecases/get_products.dart';
import 'package:shop_app/features/products/presentation/bloc/product_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  // ── External ─────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ── Data sources ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProductRemoteSource>(
      () => ProductRemoteSourceImpl());
  sl.registerLazySingleton<CartLocalSource>(
      () => CartLocalSourceImpl(sl<SharedPreferences>()));

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ProductRemoteSource>()));
  sl.registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(sl<CartLocalSource>()));

  // ── Use-cases — products ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetProducts(sl<ProductRepository>()));
  sl.registerLazySingleton(() => GetCategories(sl<ProductRepository>()));

  // ── Use-cases — cart ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCartItems(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCart(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCart(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateQuantity(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCart(sl<CartRepository>()));

  // ── BLoCs — registered as factories so each screen gets a fresh instance
  //    but they share the same singleton use-case / repository chain. ────────
  sl.registerFactory(
    () => ProductBloc(
      getProducts: sl<GetProducts>(),
      getCategories: sl<GetCategories>(),
    ),
  );
  sl.registerFactory(
    () => CartBloc(
      getCartItems: sl<GetCartItems>(),
      addToCart: sl<AddToCart>(),
      removeFromCart: sl<RemoveFromCart>(),
      updateQuantity: sl<UpdateQuantity>(),
      clearCart: sl<ClearCart>(),
    ),
  );
}