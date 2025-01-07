import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CheckedInUsersPage extends StatefulWidget {
  @override
  _CheckedInUsersPageState createState() => _CheckedInUsersPageState();
}

class _CheckedInUsersPageState extends State<CheckedInUsersPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late Stream<List<Map<String, dynamic>>> _checkedInUsersStream;

  @override
  void initState() {
    super.initState();
    _checkedInUsersStream = _database.child("checkedInUsers").onValue.asyncMap((event) async {
      final List<Map<String, dynamic>> users = [];
      final data = event.snapshot.value as Map?;
      if (data != null) {
        for (var entry in data.entries) {
          final phone = entry.value['userId']; // Check-in tablosundaki 'userId' aslında phone
          final timestamp = DateTime.parse(entry.value['timestamp']);
          final userSnapshot = await _database.child("users").orderByChild("phone").equalTo(phone).get();
      if (userSnapshot.exists) {
  final userMap = userSnapshot.value as Map;
  final userData = userMap.values.first as Map;
  
  // Geçen zamanı hesapla
  final timeSpent = DateTime.now().difference(timestamp).inMinutes;
    
  // Eğer son 1 saat içerisindeyse tabloya ekle
  if (timeSpent <= 60 && timeSpent >=0) {
    users.add({
      'name': userData['name'] ?? 'Bilinmeyen',
      'phone': phone,
      'isActive': userData['isActive'] ?? false,
      'point': userData['point'] ?? 0,
      'timeSpent': timeSpent,
    });
  }
}

        }
      }
      return users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check-In Yapanlar')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _checkedInUsersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu.'));
          }
          final checkedInUsers = snapshot.data ?? [];
          if (checkedInUsers.isEmpty) {
            return Center(child: Text('Henüz check-in yapan kimse yok.'));
          }
          return ListView.builder(
            itemCount: checkedInUsers.length,
            itemBuilder: (context, index) {
              final user = checkedInUsers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 5,
                child: ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: user['isActive'] == true ? Colors.green : Colors.red,
                    size: 35,
                  ),
                  title: Text(
                    user['name'] ?? 'Bilinmeyen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),                     
                      Text(
                        'Puan: ${user['point']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        '${user['timeSpent']} dakikadır burada',
                        style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 67, 197, 84)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
