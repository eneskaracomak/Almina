import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_bit_app/app/app_garson.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/home/loginPage.dart';
import 'dart:async';

import 'package:food_bit_app/app/app.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
 final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('Settings/Version');

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüsünü başlat
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
      _logoAnimation = Tween<double>(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Animasyonu başlat
    _controller.forward();

    // Oturum kontrolünü yap
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      // Uygulamanın mevcut sürümünü al
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
       String version = packageInfo.version; // Örn: "1.0.0"
    String buildNumber = packageInfo.buildNumber; // Örn: "9"

    // "1.0.0" olan version bilgisini "1.0.9" formatına dönüştür
    List<String> versionParts = version.split('.');
    if (versionParts.length == 3) {
      versionParts[2] = buildNumber; // Son kısmı buildNumber ile değiştir
    }
    String currentVersion = versionParts.join('.'); // "1.0.9"

      // Firebase'den en son sürümü al
      final DataSnapshot snapshot = await _databaseReference.get();

      if (snapshot.exists) {
        String latestVersion = snapshot.value.toString();
        print(currentVersion);
        print(latestVersion);
        if (_isVersionOutdated(currentVersion, latestVersion)) {
          _showUpdateDialog();
        } else {
          _checkSession();
        }
      } else {
        // Firebase'den veri alınamazsa direkt giriş yapılır
        _checkSession();
      }
    } catch (e) {
      _checkSession();
    }
  }  
  bool _isVersionOutdated(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latest.length; i++) {
      if (i >= current.length || current[i] < latest[i]) return true;
      if (current[i] > latest[i]) return false;
    }
    return false;
  }

  
  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Güncelleme Mevcut'),
          content: const Text(
              'Yeni bir sürüm mevcut. Güncelleyerek en iyi deneyimi yaşayın.'),
          actions: [
            TextButton(
              onPressed: () {
    if (Platform.isAndroid) {
      _launchPlayStore(); // Android için Play Store'a yönlendirme
    } else if (Platform.isIOS) {
      _launchAppStore(); // iOS için App Store'a yönlendirme
    }
  },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }
  
  void _launchPlayStore() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.alminacafe.alminacafe';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  void _launchAppStore() async {
    const url =
        'https://apps.apple.com/tr/app/almina-cafe/id6740246836?l=tr';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

   void _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isUserLoggedIn = prefs.getString('user');

    Timer(const Duration(seconds: 3), () {
      if (isUserLoggedIn != null) {
        Navigator.pushReplacementNamed(context, '/Main');
      } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
  }
  Future<void> _checkSession() async {
    FirebaseService service = FirebaseService();
    final prefs = await SharedPreferences.getInstance();
    final String? user = prefs.getString('userPhone'); // Kullanıcı oturumu kontrolü

    // 3 saniye bekledikten sonra yönlendirme yap
    Timer(const Duration(seconds: 3), () async {
      if (user != null && user.isNotEmpty) {
        final String? isAdmin = prefs.getString('isAdmin');
        final String? isGarson = prefs.getString('isGarson');
        var detail = await service.getUserDataByPhone(user);
        print(detail);
        if (detail!.isGarson) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AppGarson()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => App()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient arka plan
          Container(
               decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/back.jpg'),
              fit: BoxFit.cover, // Resmin nasıl yerleşeceğini belirtir
            ),
          ),
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [Color.fromARGB(199, 197, 96, 14), Color.fromARGB(255, 200, 248, 28)],
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //   ),
            // ),
          ),
          // İçerik
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Image.asset(
                    'images/barcha_logo.png',
                    width: 200, // Modern boyutlandırma
                    height: 200,
                  ),
                ),
                const SizedBox(height: 30),
                // Uygulama adı
                Text(
                  "Almina Cafe Restaurant",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Alt metin
            
                const SizedBox(height: 30),
                // Yükleniyor animasyonu
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
