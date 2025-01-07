import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class InAppMessageHandler {
  // Uygulama açıkken mesajları dinleme
  static void listenForMessages(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showInAppMessage(
          context,
          title: message.notification!.title ?? "Bildirim",
          body: message.notification!.body ?? "Bir mesajınız var!",
        );
      }
    });

    // Uygulama arka planda açıldığında mesajları yakalama
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Bildirim tıklandı: ${message.notification!.title}');
      }
    });
  }

  // In-App Mesaj Gösterimi
  static void showInAppMessage(BuildContext context, {required String title, required String body}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Kapat"),
            ),
          ],
        );
      },
    );
  }
}
