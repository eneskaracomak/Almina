import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/cart/order_details.dart';
import 'package:food_bit_app/app/tabs/home/loginPage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeGarson extends StatefulWidget {
  @override
  _HomeGarsonState createState() => _HomeGarsonState();
}

class _HomeGarsonState extends State<HomeGarson> {
  String? scannedQRCode;
  List<NotificationModel> notifications = [];
  Timer? timer;
  final AudioPlayer audioPlayer = AudioPlayer();
  final FirebaseService _service = FirebaseService();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _startNotificationTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  // Bildirimleri Fetch etme
  void _fetchNotifications() async {
    notifications = await _service.fetchActiveNotifications();
    setState(() {}); // UI'yi güncelle
  }

  // Bildirim Güncelleme
  void _updateNotification(String name, DateTime date) async {
    await _service.updateNotification(name, date);
  }

  // Bildirim zamanlayıcısını başlatma
  void _startNotificationTimer() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      List<NotificationModel> newNotifications = await _service.fetchActiveNotifications();
      if (newNotifications.length > notifications.length) {
        _playNotificationSound();
      }
      setState(() {
        notifications = newNotifications;
      });
    });
  }

  // Sesli Bildirim Çalma
  void _playNotificationSound() async {
    await audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2864/2864-preview.mp3'));
  }

  // QR Tarayıcı sayfasına gitme
  Future<void> _navigateToQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );
    if (result != null) {
      setState(() {
        scannedQRCode = result;
      });
      _showScannedQRCodePopup(result);
    }
  }

  // QR kodu içerik popup'ını gösterme
 OrderResult parseCartItems(String jsonString) {
  Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return OrderResult.fromJson(jsonMap);
}


  void _showScannedQRCodePopup(String qrCodeContent) {
  OrderResult cartItems = parseCartItems(qrCodeContent);

  // QR kodu okunduğunda, Sipariş Detayları Sayfasına yönlendirme
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OrderDetailsPage(cartItems: cartItems), // Sipariş detayları sayfasına yönlendiriyoruz
    ),
  );
}


  // Çıkış yapma fonksiyonu
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // SharedPreferences içeriğini temizle

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Garson Paneli'),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner kısmı
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoş Geldiniz!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Masa siparişlerini yönetmek için QR kodları tarayın.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _navigateToQRScanner,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.redAccent, backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Sipariş Oku',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          // Bildirimler Listesi
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bildirimler',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: notifications.isEmpty
                        ? Center(
                            child: Text(
                              'Henüz bildirim yok.',
                              style: TextStyle(fontSize: 16.0, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: ListTile(
                                  leading: Icon(Icons.notifications, color: Colors.redAccent),
                                  title: Text(notifications[index].description!),
                                  trailing: IconButton(
                                    icon: Icon(Icons.check, color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        _updateNotification(notifications[index].description!, notifications[index].dateTime);
                                        notifications.removeAt(index); // Bildirimi listeden çıkar
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
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

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Tarayıcı'),
        backgroundColor: Colors.redAccent,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300.0,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera(); // Kamerayı durdur
      Navigator.pop(context, scanData.code); // QR kodu geri gönder
    });
  }
}
