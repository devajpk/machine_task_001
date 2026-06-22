import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/feature/cart/domain/use_case/add_to_cart_item.dart';
import 'package:shop_app/feature/cart/presnetation/widget/cart_item.dart';
import 'package:shop_app/feature/products/domain/entities/product_entity.dart';

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final Product product;
  const AddToCartEvent({required this.product});
  @override
  List<Object?> get props => [product];
}

class RemoveFromCartEvent extends CartEvent {
  final int productId;
  const RemoveFromCartEvent({required this.productId});
  @override
  List<Object?> get props => [productId];
}

class UpdateQuantityEvent extends CartEvent {
  final int productId;
  final int quantity;
  const UpdateQuantityEvent({required this.productId, required this.quantity});
  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCartEvent extends CartEvent {}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded(this.items);

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItems getCartItems;
  final AddToCart addToCart;
  final RemoveFromCart removeFromCart;
  final UpdateQuantity updateQuantity;
  final ClearCart clearCart;

  CartBloc({
    required this.getCartItems,
    required this.addToCart,
    required this.removeFromCart,
    required this.updateQuantity,
    required this.clearCart,
  }) : super(CartInitial()) {
    on<LoadCartEvent>(_onLoad);
    on<AddToCartEvent>(_onAdd);
    on<RemoveFromCartEvent>(_onRemove);
    on<UpdateQuantityEvent>(_onUpdate);
    on<ClearCartEvent>(_onClear);
  }

  Future<void> _onLoad(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      emit(CartLoaded(await getCartItems()));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAdd(AddToCartEvent event, Emitter<CartState> emit) async {
    try {
      await addToCart(event.product);
      emit(CartLoaded(await getCartItems()));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemove(
      RemoveFromCartEvent event, Emitter<CartState> emit) async {
    try {
      await removeFromCart(event.productId);
      emit(CartLoaded(await getCartItems()));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateQuantityEvent event, Emitter<CartState> emit) async {
    try {
      await updateQuantity(event.productId, event.quantity);
      emit(CartLoaded(await getCartItems()));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClear(ClearCartEvent event, Emitter<CartState> emit) async {
    try {
      await clearCart();
      emit(CartLoaded(await getCartItems()));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
