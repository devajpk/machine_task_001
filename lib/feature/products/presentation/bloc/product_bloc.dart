import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/products/domains/entities/product_entity.dart';
import 'package:shop_app/feature/products/domains/use_case/get_category.dart';
import 'package:shop_app/feature/products/domains/use_case/get_product.dart';


// ─── Events ──────────────────────────────────────────────────────────────────
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? category;
  const LoadProducts({this.category});
  @override
  List<Object?> get props => [category];
}

class FilterByCategory extends ProductEvent {
  final String category;
  const FilterByCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);
  @override
  List<Object?> get props => [query];
}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    required this.categories,
    this.selectedCategory = 'all',
    this.searchQuery = '',
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
  }) =>
      ProductLoaded(
        products: products ?? this.products,
        filteredProducts: filteredProducts ?? this.filteredProducts,
        categories: categories ?? this.categories,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props =>
      [products, filteredProducts, categories, selectedCategory, searchQuery];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final GetCategories getCategories;

  ProductBloc({
    required this.getProducts,
    required this.getCategories,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoad);
    on<FilterByCategory>(_onFilter);
    on<SearchProducts>(_onSearch);
  }

  Future<void> _onLoad(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final results = await Future.wait([
        getProducts(category: event.category),
        getCategories(),
      ]);
      final products = results[0] as List<Product>;
      final categories = ['all', ...(results[1] as List<String>)];

      emit(ProductLoaded(
        products: products,
        filteredProducts: products,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onFilter(FilterByCategory event, Emitter<ProductState> emit) {
    final current = state;
    if (current is! ProductLoaded) return;

    List<Product> filtered;
    if (event.category == 'all') {
      filtered = current.products;
    } else {
      filtered = current.products
          .where((p) => p.category == event.category)
          .toList();
    }

    // Re-apply any existing search on top of the category filter
    if (current.searchQuery.isNotEmpty) {
      final q = current.searchQuery.toLowerCase();
      filtered = filtered
          .where((p) => p.title.toLowerCase().contains(q))
          .toList();
    }

    emit(current.copyWith(
      filteredProducts: filtered,
      selectedCategory: event.category,
    ));
  }

  void _onSearch(SearchProducts event, Emitter<ProductState> emit) {
    final current = state;
    if (current is! ProductLoaded) return;

    List<Product> base = current.selectedCategory == 'all'
        ? current.products
        : current.products
            .where((p) => p.category == current.selectedCategory)
            .toList();

    final q = event.query.toLowerCase();
    final filtered = q.isEmpty
        ? base
        : base.where((p) => p.title.toLowerCase().contains(q)).toList();

    emit(current.copyWith(
      filteredProducts: filtered,
      searchQuery: event.query,
    ));
  }
}