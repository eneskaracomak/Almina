import 'package:food_bit_app/app/components/FirebaseService.dart';

class CartManager {
  static final CartManager _instance = CartManager._internal();

  factory CartManager() {
    return _instance;
  }

  CartManager._internal();

  List<CartItem> _cartItems = [];

  // Sepeti sıfırla
  void resetCart() {
    _cartItems = [];
  }

  // Sepete ürün ekle
  void addToCart(CartItem item) {
    int index = _cartItems.indexWhere((cartItem) => cartItem.name == item.name);
    if (index != -1) {
      _cartItems[index].quantity += 1;
    } else {
      _cartItems.add(item);
    }
  }

  // Sepeti getir
  List<CartItem> get cartItems => _cartItems;
}
