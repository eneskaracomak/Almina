import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderResult cartItems;

  OrderDetailsPage({required this.cartItems});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {


  // Helper method to check if the order is within the last 15 minutes
  bool isOrderValid(String dateTimeString) {
    DateTime orderTime = DateTime.parse(dateTimeString);
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(orderTime);

    return difference.inMinutes <= 30; // Check if the difference is 15 minutes or less
  }
double calculateTotalPoints(List<CartItem> cartItems) {
  double totalPoints = 0.0;

  for (var item in cartItems) {
    totalPoints += item.price; // Her ürünün puanını ekliyoruz
  }

  return totalPoints;
}

  @override
  Widget build(BuildContext context) {
    FirebaseService _firebaseService = new FirebaseService();
    // Check if the order is valid (within last 15 minutes)
    bool orderValid = isOrderValid(this.widget.cartItems.dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Detayları'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sipariş Detayları Başlığı
            Text(
              'Sipariş Detayları',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Eğer sipariş geçerliyse, sipariş detaylarını göster
            if (orderValid) ...[
              // Sipariş Listesi
              Expanded(
                child: ListView.builder(
                  itemCount: this.widget.cartItems.cartItems.length,
                  itemBuilder: (context, index) {
                    CartItem item = this.widget.cartItems.cartItems[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        leading: Image.asset(
                          item.image, // Ürün resmini sol tarafa yerleştiriyoruz
                          width: 50.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.name),
                        subtitle: Text("${item.quantity} x ${item.price.toStringAsFixed(2)} TL"),
                        trailing: IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            // İptal butonuna tıklandığında yapılacak işlem
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item.name} iptal edildi')),
                            );
                             setState(() {
                this.widget.cartItems.cartItems.removeAt(index);
                              _firebaseService.updateUserPoints(this.widget.cartItems.userPhone, item.price.toInt(), true);

                if(this.widget.cartItems.cartItems.length <=0){
                                        Navigator.pop(context); // Geri dön

                }
              });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // İptal Butonu ve Siparişi Tamamla Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // İptal Et Butonu (Kırmızı)
                  ElevatedButton(
                    onPressed: () {
                       _firebaseService.updateUserPoints(this.widget.cartItems.userPhone, calculateTotalPoints(this.widget.cartItems.cartItems).toInt(), true);

                      Navigator.pop(context); // Geri dön
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // İptal butonu için kırmızı renk
                    ),
                    child: Text('    İptal Et    ', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(width: 20),
                  // Siparişi Tamamla Butonu (Yeşil)
                ElevatedButton(
  onPressed: () {
    // Sipariş tamamla işlemi yapılabilir.
    
    // Snackbar tasarımını güzelleştirelim
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sipariş tamamlandı!',
          style: TextStyle(color: Colors.white),  // Metin rengi beyaz
        ),
        backgroundColor: Colors.green, // Arka plan rengi
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Kenarları yuvarlatmak
        ),
        duration: Duration(seconds: 2), // Snackbar süresi 2 saniye
      ),
    );

    // Firebase'e sipariş kaydetme
    _firebaseService.addUserOrder(new UserOrder(
      userPhone: this.widget.cartItems.userPhone, 
      point: calculateTotalPoints(this.widget.cartItems.cartItems),
      dateTime: this.widget.cartItems.dateTime,
    ));

    // 2 saniye sonra bir önceki sayfaya yönlendirme
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Bir önceki sayfaya dönüyoruz
    });
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green, // Sipariş tamamla butonu için yeşil renk
  ),
  child: Text('Siparişi Tamamla', style: TextStyle(color: Colors.white)),
),

                ],
              ),
            ] else ...[
              // Sipariş geçerli değilse uyarı ver
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Geçersiz Sipariş! Barkodun tarihi geçmiş.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0, color: Colors.red),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Sayfadan çıkma işlemi
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Kırmızı renk
                      ),
                      child: Text('Geri Dön', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
