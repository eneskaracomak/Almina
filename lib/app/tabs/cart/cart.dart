import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/custom_header.dart';
import 'package:food_bit_app/app/manager/cart_manager.dart';
import 'package:food_bit_app/app/tabs/cart/SuccessPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/FirebaseService.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with TickerProviderStateMixin {
  late TabController _tabController;
  List<CartItem> foods = []; // Sepet ürünlerini tutacak liste
 CartManager cartManager = new CartManager();
 FirebaseService _firebaseService = new FirebaseService();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 3,
      vsync: this,
    );
    _loadCartItems(); // Sepet verilerini yükle
  }

  Future<void> _loadCartItems() async {
    // Bu metot gerçek veri kaynağından veri çekecek şekilde düzenlenebilir

    // Veriyi listeye ekle
    setState(() {
      foods = cartManager.cartItems;
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      if (foods[index].quantity + delta >= 0) {
        foods[index].quantity += delta; // Miktarı artır/azalt
      }
    });
  }

 void _generateQR() async {
  try {
    // SharedPreferences'den kullanıcı telefon numarasını al
    final prefs = await SharedPreferences.getInstance();
    String? userPhone = prefs.getString('userPhone');

    if (userPhone == null) {
      // Telefon numarası yoksa işlem yapma
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("Kullanıcı bilgisi bulunamadı."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
      return;
    }

    // Firebase'den kullanıcı verisini çek
    User? user = await _firebaseService.getUserDataByPhone(userPhone);

    if (user == null) {
      // Kullanıcı bulunamazsa
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("Kullanıcı bilgisi bulunamadı."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
      return;
    }

    // Kullanıcının puanı
    int userPoints = user.point; // User modelindeki puan alanı

    // Sepetteki toplam puanı hesapla
    int totalCartPoints = foods.fold<int>(
      0,
      (sum, food) => sum + (food.quantity * food.price.toInt()),
    );

    // Sepet puanını kontrol et
    if (totalCartPoints > userPoints) {
      // Kullanıcı puanı yetersizse popup göster
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Puan Yetersiz"),
          content: Text(
              "Sepetteki toplam puan ($totalCartPoints), mevcut puanınızdan ($userPoints) fazla."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    } else {
      // İşlem başarılı: QR kodu oluştur
      String qrData = "Cart: \n";
      for (var food in foods) {
        qrData += "${food.name} - ${food.quantity} x ${food.price}\n";
      }

      // Kullanıcı puanını düşür
      int updatedPoints = userPoints - totalCartPoints;

      // Firebase'deki puanı güncelle
      await _firebaseService.updateUserPoints(userPhone,totalCartPoints,false);
      List<CartItem> otherCartItem =[];
      otherCartItem.addAll(foods);
      // Sepeti temizle
      setState(() {
        foods.clear();
      });

      // QR kod sayfasına yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(qrData: qrData,carItem: otherCartItem,userPhone: userPhone,),
        ),
      );
    }
  } catch (e) {
    print("Hata oluştu: $e");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hata"),
        content: Text("Beklenmeyen bir hata oluştu."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tamam"),
          ),
        ],
      ),
    );
  }
}


  Widget renderAddList() {
    return ListView.builder(
      itemCount: foods.length,
      itemBuilder: (BuildContext context, int index) {
        var food = foods[index];
        Color primaryColor = Theme.of(context).primaryColor;
        return Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          child: Card(
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(food.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(food.name),
                            IconButton(
                              icon: Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  foods.removeAt(index); // Ürünü sepetten kaldır
                                });
                              },
                            ),
                          ],
                        ),
                        Text(food.price.toString() + " Puan"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                _updateQuantity(index, -1); // Miktarı azalt
                              },
                            ),
                            Container(
                              color: primaryColor,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 12.0,
                              ),
                              child: Text(
                                '${food.quantity}',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: primaryColor),
                              onPressed: () {
                                _updateQuantity(index, 1); // Miktarı artır
                              },
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return SafeArea(      
      child: Column(
        children: <Widget>[
          CustomHeader(
            title: 'Sepetim',
            quantity: foods.length,
            internalScreen: false,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: renderAddList(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 35.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: theme.primaryColor,
                        ),
                        child: TextButton(
                          onPressed: _generateQR, // QR kodu oluştur
                          child: Text(
                            'QR Oluştur',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
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
    );
  }
}
