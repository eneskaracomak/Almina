import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:food_bit_app/app/app.dart';
import 'package:food_bit_app/app/tabs/home/details/details.dart';
import 'package:food_bit_app/app/tabs/home/splash_screen.dart';

// Arka planda gelen mesajları işleme fonksiyonu
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Arka planda gelen mesaj: ${message.messageId}");
}

void main() async {
  // Flutter binding işlemini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp();

  // Arka planda gelen mesajları dinlemek için handler bağla
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
runFirebaseMessagingSetup();
  // Uygulamayı başlat
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Cera Pro",
        primaryColor: Color(0xFFE85852),
      ),
      routes: {
        'details': (context) => Details(),
      },
      home: SplashScreen(),
    );
  }
}

// Bildirimler için izin kontrolü ve dinleyici ayarları
Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Bildirim alma izinlerini kontrol et
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    sound: true,
  );

  print('İzin durumu: ${settings.authorizationStatus}');

  // Bildirim dinleyicileri
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Ön planda mesaj alındı: ${message.notification?.title}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Bildirim tıklandı: ${message.notification?.title}');
  });
}

// Uygulama çalıştığında Firebase Messaging ayarlarını başlat
void runFirebaseMessagingSetup() {
  setupFirebaseMessaging();
}
