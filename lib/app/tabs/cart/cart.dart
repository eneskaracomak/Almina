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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Sepetteki toplam puan ($totalCartPoints), mevcut puanınızdan ($userPoints) fazla.",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red, // Uyarı rengi için kırmızı seçildi
      action: SnackBarAction(
        label: "Tamam",
        textColor: Colors.white,
        onPressed: () {
          // "Tamam" butonuna tıklanıldığında yapılacaklar
        },
      ),
      duration: Duration(seconds: 5), // SnackBar'ın ekranda kalma süresi
    ),
  );
}

else if (totalCartPoints == 0) {
  // Kullanıcı puanı yetersizse SnackBar göster
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Sepetinizde ürün bulunmamaktadır.",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange,
      action: SnackBarAction(
        label: "Tamam",
        textColor: Colors.white,
        onPressed: () {
          // SnackBar üzerindeki "Tamam" butonuna basıldığında yapılacaklar
        },
      ),
      duration: Duration(seconds: 3), // SnackBar ne kadar süre görünür kalacak
    ),
  );
}

    else {
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
        // Özel başlık
        CustomHeader(
          title: 'Sepetim',
          quantity: foods.length,
          internalScreen: false,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: foods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Sepet boş ekranı
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 100.0,
                          color: theme.primaryColor.withOpacity(0.7),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Sepetiniz Boş',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColorDark,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Hemen ürün ekleyin ve sipariş oluşturun.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 30.0),
                       
                      ],
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: renderAddList(), // Ürün listesi
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 30.0,
                        ),
                        margin: EdgeInsets.only(bottom: 15),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
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
