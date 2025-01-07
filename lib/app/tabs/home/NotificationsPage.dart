import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  FirebaseService _firebaseService = FirebaseService();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Firebase'den bildirimleri çekmek için kullanılan metod
  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userPhone = prefs.getString('userPhone') ?? ''; // Eğer null ise boş string

    if (userPhone.isNotEmpty) {
      List<Map<String, dynamic>> fetchedNotifications = await _firebaseService.fetchUserNotifications(userPhone);
      setState(() {
        notifications = fetchedNotifications;
      });
    } else {
      print('User phone is not available');
    }
  }

  // 'message' ve 'userPhone' ile eşleşen bildirimi bulup 'isRead' alanını güncelle
  Future<void> _markAsRead(String message, String userPhone) async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('userNotifications');

    try {
      // Eşleşen bildirimi bulup 'isRead' değerini true yapıyoruz
      dbRef.orderByChild('message').equalTo(message).get().then((snapshot) {
        snapshot.children.forEach((child) {
          if (child.child('userPhone').value == userPhone) {
            // 'isRead' alanını güncelle
            child.ref.update({
              'isRead': true,
            });
          }
        });
      });
      print('Bildirim okundu olarak işaretlendi');
    } catch (e) {
      print('Error updating isRead status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirimler'),
        backgroundColor: Colors.teal,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                "Hiç bildiriminiz yok.",
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                String notificationTitle = notifications[index]['title'] ?? 'Bildirim Başlığı';
                String notificationMessage = notifications[index]['message'] ?? 'Bildirim Mesajı';
                String userPhone = notifications[index]['userPhone'] ?? ''; // Kullanıcı telefon numarasını alıyoruz

                // İlk bildirim için animasyon başlatma
                if (_isFirstLoad && index == 0) {
                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      _isFirstLoad = false;
                    });
                  });
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                  child: Dismissible(
                    key: Key(notifications[index].toString()),
                    direction: DismissDirection.startToEnd, // Kaydırma sağa
                    onDismissed: (direction) {
                      // Silme işlemi sırasında 'isRead' değerini güncelle
                      _markAsRead(notificationMessage, userPhone);

                      setState(() {
                        // Bildirimi listeden sil
                        notifications.removeAt(index);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Bildirim silindi."),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                          duration: Duration(seconds: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        ),
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.redAccent,
                      padding: EdgeInsets.only(left: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      transform: Matrix4.translationValues(
                          _isFirstLoad && index == 0 ? 100.0 : 0.0, 0.0, 0.0),
                      child: ListTile(
                        leading: Icon(Icons.notifications_active, color: Colors.teal),
                        title: Text(
                          notificationTitle,
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                          notificationMessage,
                          style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
