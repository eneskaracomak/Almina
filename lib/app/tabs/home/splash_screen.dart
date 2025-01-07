import 'package:flutter/material.dart';
import 'package:food_bit_app/app/app_garson.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/home/loginPage.dart';
import 'dart:async';

import 'package:food_bit_app/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _checkSession();
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
