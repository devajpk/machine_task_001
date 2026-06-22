import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/feature/cart/data/cart_remote_data_Source/cart_remote_data_source.dart';
import 'package:shop_app/feature/cart/data/repo/repo_imp.dart';
import 'package:shop_app/feature/cart/domain/repo/rep.dart';
import 'package:shop_app/feature/cart/domain/use_case/add_to_cart_item.dart';
import 'package:shop_app/feature/cart/presnetation/bloc/cart_bloc.dart';
import 'package:shop_app/feature/products/data/remote_data_sorce/remote_data_source.dart';
import 'package:shop_app/feature/products/data/repo_imp/repo_imp.dart';
import 'package:shop_app/feature/products/domain/rep/repo.dart';
import 'package:shop_app/feature/products/domains/use_case/get_category.dart';
import 'package:shop_app/feature/products/domains/use_case/get_product.dart';
import 'package:shop_app/feature/products/presentation/bloc/product_bloc.dart';


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