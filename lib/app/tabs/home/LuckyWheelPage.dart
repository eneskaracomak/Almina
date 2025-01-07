import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamplePage extends StatefulWidget {
  @override
  _ExamplePageState createState() => _ExamplePageState();
}
    FirebaseService _firebaseService = new FirebaseService();

class _ExamplePageState extends State<ExamplePage> {
  StreamController<int> selected = StreamController<int>.broadcast(sync: false);

  bool isSpinning = false;
  String winner = "";
  List<Color> wheelColors = [
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.pink,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
    Colors.deepOrange,
    Colors.amber,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.lightBlue,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.indigoAccent,
    Colors.pinkAccent,
  ];

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> itemsWithProbabilities = [
      {'item': '10 Puan', 'probability': 80},
      {'item': '20 Puan', 'probability': 70},
      {'item': '30 Puan', 'probability': 70},
      {'item': 'Çay', 'probability': 90},
      {'item': 'Kahve', 'probability': 1},
      {'item': 'Tatlı', 'probability': 1},
      {'item': '60 Puan', 'probability': 1},
      {'item': '70 Puan', 'probability': 1},
      {'item': '80 Puan', 'probability': 1},
      {'item': '90 Puan', 'probability': 1},
      {'item': '100 Puan', 'probability': 1},
      {'item': 'Pizza', 'probability': 1},
      {'item': 'Burger', 'probability': 1},
      {'item': '150 Puan', 'probability': 1},
      {'item': 'Fanta', 'probability': 1},
      {'item': 'Kola', 'probability': 1},
      {'item': '50 Puan', 'probability': 1},
      {'item': 'Meyve Suyu', 'probability': 1},
      {'item': '200 Puan', 'probability': 1},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Almina Cafe Şanslı Çark', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade400,
        elevation: 1,
      ),
      body: GestureDetector(
        onTap: () {},
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/backlucky.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 450,
                      child: FortuneWheel(
                        animateFirst: false,
                        selected: selected.stream,
                        items: [
                          for (var it in itemsWithProbabilities)
                            FortuneItem(child: _buildItem(it['item'])),
                        ],
                        onAnimationEnd: () {
                          setState(() {
                            isSpinning = false;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () async {
                        if (!isSpinning) {
                          setState(() async {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            var lastSpinDate = await prefs.getString('lastSpinDate');
                            var currentDate = DateTime.now().toString().split(' ')[0]; // sadece tarih kısmı
                            
                            if (lastSpinDate != currentDate) {
                              // Eğer kullanıcı zaten o gün çevirmişse, uyarı göster
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Bugün zaten çevirdiniz! Yarın tekrar deneyebilirsiniz.',
                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.blue,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              );
                            } else {
                              // Günü değiştirelim ve çarkı çevirelim
                              isSpinning = true;
                              String winnerItem = getRandomItem(itemsWithProbabilities);
                              // Rastgele bir sayı seç ve çarkı döndür
                                    final filteredItems = itemsWithProbabilities.where((item) => item['probability'] > 1).toList();
                              selected.add(Fortune.randomInt(0, filteredItems.length)); // Burada doğru index seçiliyor
                              await prefs.setString('lastSpinDate', currentDate); // Çark çevrilmiş gün kaydediyoruz
                              winner = winnerItem;
                            }
                          });
                        }
                      },
                      child: Text(
                        "Çevir",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(), backgroundColor: Colors.blueGrey,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        elevation: 10,
                      ),
                    ),
                  ],
                ),
                StreamBuilder<int>(  // Stream'deki değeri dinliyoruz
                  stream: selected.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                      String result = itemsWithProbabilities[snapshot.data!]['item'];
                      if (!isSpinning) {
                        Future.delayed(Duration(seconds: 2), () {
                          if (mounted) {
                            _showWinnerDialog(context, result);
                          }
                        });
                      }
                    }
                    return SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getRandomItem(List<Map<String, dynamic>> itemsWithProbabilities) {
    // Olasılıkları normalize et
    double totalWeight = 0;
    List<double> cumulativeWeights = [];

    // Olasılıkların toplamını hesapla
    for (var item in itemsWithProbabilities) {
      totalWeight += item['probability'];
    }

    // Normalize edilmiş ağırlıkları hesapla
    double cumulativeWeight = 0;
    for (var item in itemsWithProbabilities) {
      double normalizedWeight = item['probability'] / totalWeight;
      cumulativeWeight += normalizedWeight;
      cumulativeWeights.add(cumulativeWeight);
    }

    // Ağırlıklı seçim yap
    double randomValue = Random().nextDouble() * 1.0; // 0 ile 1 arasında bir sayı seçiyoruz

    // Ağırlıklı seçim yap, probability değeri 1 olmayan öğeleri kazanan olarak al
    for (int i = 0; i < cumulativeWeights.length; i++) {
      if (randomValue < cumulativeWeights[i] && itemsWithProbabilities[i]['probability'] != 1) {
        return itemsWithProbabilities[i]['item'];
      }
    }

    return itemsWithProbabilities.last['item']; // Son öğe varsayılan olarak döndürülür
  }

  Future<void> _showWinnerDialog(BuildContext context, String winner) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var res = await prefs.getString('userPhone');
    if(winner.contains("Puan")){
      FirebaseService service = FirebaseService();
        String pointString = winner.replaceAll("Puan", "").trim();

      service.updateUserPoints(res!, int.parse(pointString), true);
      _firebaseService.addUserNotification(res, "Kazandınız !", "Çark çevriminden $pointString Puan kazandınız");
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Kazandınız!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kazandığınız Ürün: $winner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _firebaseService.addUserNotification(res!, "Kazandınız !", "Çark çevriminden $winner kazandınız");
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Tamam',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(String item) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        item,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
