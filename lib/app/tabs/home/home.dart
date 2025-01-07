import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/components/firebase.dart';
import 'package:food_bit_app/app/components/food_card.dart';
import 'package:food_bit_app/app/tabs/home/LuckyWheelPage.dart';
import 'package:food_bit_app/app/tabs/home/NotificationsPage.dart';
import 'package:food_bit_app/app/tabs/home/hediyebulutu.dart';
import 'package:food_bit_app/app/tabs/home/productlist.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/QuizTimerWidget.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Home extends StatefulWidget {
  final String tableInfo;

  Home({required this.tableInfo});

  @override
  _HomeState createState() => _HomeState();
}


class _HomeState  extends State<Home> {

 User? userData;
 List<FoodOption>? foodOptions;
 List<Campaign> campaign = [];
 List<PopularFood>? popularFood;
 List<Order>? orders;
    final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getNotifications();
  }
  List<Map<String, dynamic>> notifications = [];
  Setting? setting;
void getNotifications() async {
          SharedPreferences prefs = await SharedPreferences.getInstance();

    String? phone = prefs.getString('userPhone'); 
  List<Map<String, dynamic>> notifications = await _firebaseService.fetchUserNotifications(phone!);
  var setting2 = await _firebaseService.fetchSettingsFromDatabase();
  setState(() {
    this.notifications = notifications; // Ekranda göstermek için state'e atayın
    setting = setting2;
  });
}
  // SharedPreferences'ten telefon numarasını alıp Firebase'den kullanıcı verisini çekiyoruz
  Future<void> _loadUserData() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

    String? phone = prefs.getString('userPhone');  // SharedPreferences'ten telefon numarasını alıyoruz
    if (phone != null) {
      // Firebase'den kullanıcı verilerini alıyoruz
      var data = await _firebaseService.getUserDataByPhone(phone);
      var food = await _firebaseService.getFoodOptionsFromRealtimeDatabase();
      var order = await _firebaseService.getOrdersByUserPhone(phone);
      var popularFoods = await _firebaseService.getPopularFoodsFromRealtimeDatabase();
      var campaigns = await _firebaseService.getCampaignsFromRealtimeDatabase();
      if (data != null) {
        setState(() {
          popularFood = popularFoods;
          orders = order;
          foodOptions = food;
          campaign = campaigns;
          userData = data;  // Kullanıcı verisini state'e kaydediyoruz
        });
      } else {
        print("User not found2.");
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    InAppMessageHandler.listenForMessages(context);
    if(userData == null){
     return Container(
  child: Center(
    child: CircularProgressIndicator(color: Colors.brown,),
  ),
);

    }else{

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
      'Almina Cafe',
      style: TextStyle(
        fontSize: 24.0, // Yazı büyüklüğü
        fontWeight: FontWeight.bold, // Kalın yazı tipi
        color: Color(0xFFB21F29), // Hex renk kodu
        fontFamily: 'Cursive', // Daha dekoratif bir font kullanabilirsiniz
      ),
    ),
Stack(
  alignment: Alignment.center,
  children: [
    IconButton(
      icon: Icon(Icons.notifications_none, size: 28.0),
      onPressed: () {
        // Bildirimler sayfasına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
      },
    ),
    Positioned(
      right: 6, // Sağ tarafa hizalama
      top: 6, // Üst tarafa hizalama
      child:  Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.red, // Arkaplan rengi
                shape: BoxShape.circle, // Daire şekli
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${notifications.length}', // Bildirim sayısı
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
    ),
  ],
)
            ],
              ),
            ),
            Padding(
  padding: const EdgeInsets.only(
    top: 10.0,
    left: 20.0,
    right: 20.0,
  ),
  child: Container(
    padding: EdgeInsets.all(15.0),
    decoration: BoxDecoration(
      color: Colors.white, // Arka plan rengi
      borderRadius: BorderRadius.circular(15.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 8.0,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30.0,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              child: Image.asset("images/point.png"),
            ),
            SizedBox(width: 15.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Almina Puanım",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  userData!.point.toString(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
  onPressed: () {
    showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(20.0),
    ),
  ),
  backgroundColor: Colors.white,
  builder: (BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(  // Taşmayı engellemek için SingleChildScrollView ekleyelim
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Puan Hakkında",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "Almina Puanı Kullanmak/Kazanmak için:",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
              title: Text(
                "Puan Kazanma",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Her gerçek siparişinde kasada uygulamaya kayıtlı cep telefonunu söylemen yeterli.",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Divider(color: Colors.grey[300]),
            ListTile(
              leading: Icon(
                Icons.card_giftcard,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
              title: Text(
                "Puan Kullanımı",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Kazandığın puanlar ile uygulama içerisinde puanlarına uygun sepet oluşturup QR Oluştur butonuna basman yeterli, ardından oluşan QR kod garson tarafından okutulup sipariş oluşturulacaktır.",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Hadi Kazan!",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
  },   
  
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).primaryColor,
    padding: EdgeInsets.all(10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(11.0),
    ),
  ),
  child: Text(
    "Nasıl Kullanılır",
    style: TextStyle(
      fontSize: 12.0,
      color: Colors.white,
    ),
  ),
),

      ],
    ),
  ),
),

            Container(
              height: 107,
              margin: const EdgeInsets.only(
                top: 10.0,
                bottom: 1.0,
              ),
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    left: 20.0,
                  ),
                  itemCount: this.foodOptions!.length,
                  itemBuilder: (context, index) {
                    var option = this.foodOptions![index];
                    return Container(
                      margin: const EdgeInsets.only(right: 35.0),
                      child: GestureDetector(
                        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductListPage(
        categoryName: option.name, // Ürünü detay sayfasına gönderiyoruz
      ),
    ),
  );
},

                        child: Column(
                        children: <Widget>[
                          Container(
                            width: 70,
                            height: 70,
                            margin: const EdgeInsets.only(bottom: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                              image: DecorationImage(
                                image: AssetImage(
                                  option.image,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10.0,
                                  color: Colors.grey,
                                  offset: Offset(6.0, 6.0),
                                )
                              ],
                            ),
                          ),
                          Text(
                            option.name,
                            style: TextStyle(fontSize: 17.0),
                          ),
                        ],
                      ),
                    ));
                  }),
            ),
           Row(
  children: [
    if(setting!.isCark)...[
    Expanded(child: LuckyWheelCard()),

    ],   
     if(setting!.isQuiz)...[
    Expanded(child:QuizTimerWidget()),

    ]
  ],),  
   BenimMasamBanner(tableInfo: widget.tableInfo,firebaseService: this._firebaseService,),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 10.0,top: 13),
              child: Text(
                'Popüler Ürünler',
                style: TextStyle(fontSize: 21.0),
              ),
            ),
            Container(
              height: 225.0,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 10.0),
                scrollDirection: Axis.horizontal,
                itemCount: this.popularFood!.length,
                itemBuilder: (context, index) {
                  var product = this.popularFood![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        'details',
                        arguments: {
                          'product': product,
                          'index': index,
                        },
                      );
                    },
                    child: Hero(
                      tag: 'detail_food$index',
                      child: FoodCard(
                        width: size.width / 2 - 30.0,
                        primaryColor: theme.primaryColor,
                        productName: product.name,
                        productPrice: product.price,
                        productUrl: product.image,
                        productClients: product.clients,
                        productRate: product.rating,
                      ),
                    ),
                  );
                },
              ),
            ),   Row(
  children: [
    Expanded(child: EventBanner(campaignsFuture: this.campaign,)),
    Expanded(child: EventsPlaning()),
  ],),
    SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20.0, bottom: 10.0, top: 5.0),
        child: Text(
          'Son Kasa Siparişlerim',
          style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: orders?.length, // order listesi uzunluğu
  itemBuilder: (context, index) {
    Order currentOrder = orders![index]; // Her bir Order objesini alıyoruz
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // değişen offset ile biraz derinlik ekledik
            ),
          ],
        ),
        child: Row(
          children: [
            // İkonu küçük boyutta ekliyoruz
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/3338/3338579.png',
              height: 30.0, // Boyut ayarı yapıldı
              width: 30.0,
            ),
            SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tutar: ${currentOrder.price}₺", // Order'ın fiyatını gösteriyoruz
                    style: TextStyle(fontSize: 16.0, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    currentOrder.date, // Order'ın tarihini gösteriyoruz
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Puan kısmını yeşil renkte gösteriyoruz
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "+${currentOrder.points} Puan", // Order'ın puanını gösteriyoruz
                  style: TextStyle(fontSize: 16.0, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
)

    ],
  ),
)


            
          ],
        ),
      ),
    );
  }}
}


class LuckyWheelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Her köşe için border radius
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        height: 55, // Yükseklik 50 px
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Her köşe için border radius
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0), // Padding ekledim
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [             
              Image.network("https://cdn-icons-png.flaticon.com/512/5659/5659825.png"),
              SizedBox(width: 1),
              Text(
                "Şanslı Çark",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                ),
               onPressed: () {
                 // Şanslı çark etkinliği sayfasını açma
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => ExamplePage()),
                 );
               },
                child: Text("Çevir!",style: TextStyle(fontSize: 12),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class HediyeBulutu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Her köşe için border radius
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        height: 55, // Yükseklik 50 px
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Her köşe için border radius
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0), // Padding ekledim
          child: GestureDetector(
            onTap: (){
               Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => KazimaKartPage()),
                 );
            },
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [             
              Image.network("https://cdn-icons-png.flaticon.com/512/5659/5659825.png"),
              SizedBox(width: 1),
              Text(
                "Şanslı Çark",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
           ],
          )),
        ),
      ),
    );
  }
}



class EventsPlaning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 17, 172, 25),
                const Color.fromARGB(255, 178, 230, 120)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                    "https://cdn-icons-png.flaticon.com/512/10178/10178514.png"),
                SizedBox(width: 12),
                Text(
                  "Etkinlik Planla",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        // Popup açma
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,  // Scroll özelliği ekliyoruz
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          backgroundColor: Colors.white,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(  // Scrollable hale getirdik
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Etkinlik Bilgileri",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Etkinlik Türü Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Etkinlik Türü",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.event),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "Doğum Günü",
                          child: Text("Doğum Günü"),
                        ),
                        DropdownMenuItem(
                          value: "Evlilik Teklifi",
                          child: Text("Evlilik Teklifi"),
                        ),
                        DropdownMenuItem(
                          value: "İş Yemeği",
                          child: Text("İş Yemeği"),
                        ),
                        DropdownMenuItem(
                          value: "Konferans",
                          child: Text("Konferans"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        // Seçilen etkinlik türünü işle
                      },
                    ),
                    SizedBox(height: 15),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Telefon Numarası",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Kişi Sayısı",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        // Rezervasyon işlemi yapılabilir
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        "Rezervasyon Oluştur",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class BenimMasamBanner extends StatefulWidget {
  var tableInfo;
  FirebaseService firebaseService;
    BenimMasamBanner({required this.tableInfo, required this.firebaseService});

  @override
  _BenimMasamBannerState createState() => _BenimMasamBannerState();
}

class _BenimMasamBannerState extends State<BenimMasamBanner> {
  String masaInfo = ""; // Başlangıçta masa bilgisi yok

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: () async {
                  if(masaInfo == ""){
                  String qrResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRScannerScreen(),
                    ),
                  );
                  setState(() {
                    masaInfo = qrResult; // QR sonucu ile masa bilgisini güncelle
                  });}else {
      // Masa bilgisi varsa, popup göster
      _showCustomMasaInfoDialog(context,widget.firebaseService);
    }
                },
      child:Card(
        
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network("https://cdn-icons-png.flaticon.com/512/1187/1187436.png"),
              SizedBox(width: 6),
              Text(
                this.masaInfo == "" ? "Masa Okut" : this.masaInfo,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
           
              Icon(Icons.qr_code_scanner, color: Colors.white),               
              
            ],
          ),
        ),
      ),
    ));
  }
  
  void _showCustomMasaInfoDialog(BuildContext context, FirebaseService service) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Daha modern köşe yuvarlama
        ),
        elevation: 15,
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF512DA8), // Modern mor ton
                    Color(0xFF9575CD), // Açık mor ton
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 6),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Başlık
                  Text(
                    '$masaInfo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  // Butonlar
                  GridView.count(
                    crossAxisCount: 2, // Her satırda 2 buton
                    shrinkWrap: true,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5, // Butonların genişlik-yükseklik oranı
                    children: [
                      _buildActionButton(
                        context,
                        'Garson Çağır',
                        Color(0xFF0288D1),
                        Icons.person,
                        () {
                          Navigator.pop(context);
                          service.addNotification(
                            NotificationModel(
                              description: "$masaInfo Garson Çağırdı",
                              dateTime: DateTime.now(),
                              isActive: true,
                            ),
                          );
                          _showActionMessage('Garson Çağrıldı');
                        },
                      ),
                      _buildActionButton(
                        context,
                        'Hesap İste',
                        Color(0xFFFF9800),
                        Icons.receipt_long,
                        () {
                          Navigator.pop(context);
                          _showActionMessage('Hesap İstendi');
                          service.addNotification(
                            NotificationModel(
                              description: "$masaInfo Hesap İstedi",
                              dateTime: DateTime.now(),
                              isActive: true,
                            ),
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        'Şikayet Gönder',
                        Color(0xFFD32F2F),
                        Icons.warning,
                        () {
                          Navigator.pop(context);
                          _showActionMessage('Şikayet Gönderildi');
                          service.addNotification(
                            NotificationModel(
                              description: "$masaInfo Şikayeti Var",
                              dateTime: DateTime.now(),
                              isActive: true,
                            ),
                          );
                        },
                      ),
                      _buildActionButton(
                        context,
                        'Taksi Çağır',
                        Color(0xFF4CAF50),
                        Icons.local_taxi,
                        () {
                          Navigator.pop(context);
                          _showActionMessage('Taksi Çağrıldı');
                          service.addNotification(
                            NotificationModel(
                              description: "$masaInfo Taksi Çağırdı",
                              dateTime: DateTime.now(),
                              isActive: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Masa Kapat Butonu (Tam genişlik)
                  _buildActionButton(
                    context,
                    'Masa Kapat',
                    Color(0xFFE57373),
                    Icons.close,
                    () {
                      setState(() {
                        masaInfo = ""; // Masa bilgisini sıfırla
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Üstteki Süs
            Positioned(
              top: -40,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                child: Icon(
                  Icons.table_restaurant,
                  size: 40,
                  color: Color(0xFF512DA8),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Özel Buton Oluşturucu Widget
Widget _buildActionButton(BuildContext context, String label, Color color, IconData icon, VoidCallback onPressed) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: Colors.white),
    label: Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      elevation: 5,
    ),
  );
}


// Aksiyon mesajı göstermek için bir fonksiyon
void _showActionMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

}

class QRScannerScreen extends StatefulWidget  {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: <Widget>[
        // QR tarayıcıyı sığdırmak için widget'ı yeniden yapılandır
        Expanded(
          flex: 3,
          child: _buildQrView(context),
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (result != null) 
                  Text('${result!.code}'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
  setState(() {
    this.controller = controller;
  });
  
  // QR kod okuma verisini dinleyin
  controller.scannedDataStream.listen((scanData) {
    setState(() {
      result = scanData;
    });

    // QR okunduktan sonra sonucu geri gönder
    if (Navigator.canPop(context)) {
  Navigator.pop(context, result!.code);
} else {
  // Eğer stack boşsa, buraya bir fallback mekanizması ekleyebilirsiniz.
}
  });
}

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}



class EventBanner extends StatelessWidget {
  final List<Campaign> campaignsFuture;
  EventBanner({required this.campaignsFuture});
  @override
  Widget build(BuildContext context) {
        ThemeData theme = Theme.of(context);

    return GestureDetector(child:  Card(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.event,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 2),
              Text(
                "Kampanyalar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              
            ],
          ),
        ),
      ),
    ),onTap: () {
      showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EventDetailsPopup(campaigns: campaignsFuture,);
                    },
                  );
    },);
  }
}
class EventDetailsPopup extends StatelessWidget {
  final List<Campaign> campaigns; // Kampanyaları doğrudan alıyoruz

  EventDetailsPopup({required this.campaigns});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      child: Container(
        padding: EdgeInsets.all(20),
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Text(
              "Günün Kampanyaları",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 16),

            // Kampanyaları Listele
            if (campaigns.isNotEmpty)
              ...campaigns.map((campaign) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.shade100,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.dateString,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor.withOpacity(1),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            campaign.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.primaryColor.withOpacity(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            else
              // Eğer kampanya yoksa gösterilecek mesaj
              Text(
                "Kampanya bulunamadı.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

            SizedBox(height: 20),

            // Kapat butonu
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Popup'ı kapat
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: Text(
                "Kapat",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}