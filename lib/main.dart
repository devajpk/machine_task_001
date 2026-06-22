import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/router/app_router.dart';
import 'package:shop_app/core/theme/app_theme.dart';
import 'package:shop_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:shop_app/features/products/presentation/bloc/product_bloc.dart';
import 'package:shop_app/features/products/presentation/pages/product_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for consistent layout experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupDi();
  runApp(const ShopApp());
}

class ShopApp extends StatefulWidget {
  const ShopApp({super.key});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Cart and Product BLoCs are provided at the root so they're accessible
      // from both the listing page (cart badge) and the detail page (add button).
      providers: [
        BlocProvider<ProductBloc>(create: (_) => sl<ProductBloc>()),
        BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
      ],
      child: ThemeSwitcher(
        toggle: _toggleTheme,
        child: MaterialApp.router(
          title: 'Shop App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}