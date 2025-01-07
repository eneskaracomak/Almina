import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';

class BouncingWidget2 extends StatefulWidget {
  final Duration duration;
  final Function onClaimPrize; // "Ödülü Al" butonunun işlevi

  const BouncingWidget2({Key? key, required this.duration, required this.onClaimPrize}) : super(key: key);

  @override
  _BouncingWidget2State createState() => _BouncingWidget2State();
}

class _BouncingWidget2State extends State<BouncingWidget2> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  List<User> winners = []; // Kazananlar listesi

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.ease, reverseCurve: Curves.bounceInOut),
    );
    controller.animateTo(1.0, duration: widget.duration, curve: Curves.elasticOut);
    
    // Kazananları Firebase'den alıyoruz
    _fetchWinners();
  }

  // Kazananları Firebase'den çekme işlemi
  Future<void> _fetchWinners() async {
    try {
      List<User> fetchedWinners = await FirebaseService().getWinnersFromQuizUsers();
      setState(() {
        winners = fetchedWinners; // Kazananları güncelle
      });
    } catch (e) {
      print("Kazananlar alınırken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kazananlar Listesi Başlığı
              Text(
                'Kazananlar:',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 75, 238, 102),
                ),
              ),
              SizedBox(height: 20),
              // Kazananları listeleme
              winners.isEmpty
                  ? CircularProgressIndicator() // Veriler yükleniyorsa
                  : Column(
                      children: winners.map((winner) {
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.star, color: Colors.yellow),
                            title: Text(
                              winner.name,
                              style: TextStyle(fontSize: 18, color: Colors.black87),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              SizedBox(height: 20),
              // "Ödülü Al" Butonu
              ElevatedButton(
                onPressed: () {
                  widget.onClaimPrize(); // "Ödülü Al" butonuna basıldığında yapılacak işlem
                },
                child: Text(
                  'Ödülü Al',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  backgroundColor: Colors.greenAccent, // Buton arka planı
                  foregroundColor: Colors.white, // Buton yazı rengi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          scale: controller.value,
        );
      },
      child: Container(
        width: 0.0,
        height: 0.0,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
