import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:food_bit_app/app/tabs/account/account.dart';
import 'package:food_bit_app/app/tabs/cart/cart.dart';
import 'package:food_bit_app/app/tabs/home/details/CheckedInUsersPage.dart';
import 'dart:async';

import 'package:food_bit_app/app/tabs/home/home.dart';
import 'package:food_bit_app/app/tabs/near_by/near_by.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Zamanlayıcı için

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isCheckedIn = false;
  String _buttonText = "Check-in Yap";
  List<String> checkedInUsers = [];
  Timer? _resetTimer;
  // Firebase Realtime Database referansı
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _resetTimer = Timer(Duration(hours: 1), _resetCheckIn);
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
  void _handleCheckIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? phone = prefs.getString('userPhone');

  if (phone == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kullanıcı bilgisi bulunamadı.")),
    );
    return;
  }

  DateTime now = DateTime.now();
  String currentDate = "${now.year}-${now.month}-${now.day}";
  String? lastCheckInTimeString = prefs.getString('lastCheckInTime');
  DateTime? lastCheckInTime =
      lastCheckInTimeString != null ? DateTime.parse(lastCheckInTimeString) : null;

  if (_isCheckedIn) {
    // Eğer check-in yapılmışsa "Buradakiler" sayfasına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckedInUsersPage()),
    );
    return;
  }

  if (lastCheckInTime != null &&
      lastCheckInTime.difference(now).inHours < 1 &&
      lastCheckInTime.year == now.year &&
      lastCheckInTime.month == now.month &&
      lastCheckInTime.day == now.day) {
    // Eğer aynı gün ve 1 saat içerisinde check-in yapılmışsa
    setState(() {
      _isCheckedIn = true;
      _buttonText = "Buradakiler";
    });
    return;
  }

  // Yeni bir check-in işlemi
  bool? isConfirmed = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Check-in Yapıyorsunuz"),
      content:
          Text("Kafede olduğunuza dair check-in yapıyorsunuz. Onaylıyor musunuz?"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text("Hayır"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text("Evet"),
        ),
      ],
    ),
  );

  if (isConfirmed == true) {
    // Firebase işlemleri
    final checkInRef = _database.child("checkedInUsers");
    await checkInRef.push().set({
      'userId': phone,
      'timestamp': now.toString(),
    });

    final userRef = _database.child("users").orderByChild("phone").equalTo(phone);
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.value as Map;
      final userKey = userData.keys.first;
      final currentCheckIn = userData[userKey]['checkIn'] ?? 0;

      await _database.child("users/$userKey").update({
        'checkIn': currentCheckIn + 1,
      });
    }

    // Check-in bilgilerini SharedPreferences'e kaydet
    await prefs.setString('lastCheckInTime', now.toIso8601String());

    setState(() {
      _isCheckedIn = true;
      _buttonText = "Buradakiler";
    });
  }
}




  void _resetCheckIn() {
    setState(() {
      _isCheckedIn = false;
      _buttonText = "Check-in Yap";
      checkedInUsers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: TabBarView(
          children: <Widget>[
            Home(tableInfo: '',),
            NearBy(),
            Cart(),
            Account(),
          ],
        ),
        bottomNavigationBar: Material(
          color: Colors.white,
          child:Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(46),
                topRight: Radius.circular(46),
              ),
            
            ),
            child: TabBar(
            labelPadding: const EdgeInsets.only(bottom: 10),
            labelStyle: TextStyle(fontSize: 16.0),
            indicatorColor: Colors.transparent,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black54,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home, size: 28), text: 'Anasayfa'),
              Tab(icon: Icon(Icons.workspace_premium_rounded, size: 28), text: 'Liderlik'),
              Tab(icon: Icon(Icons.card_travel, size: 28), text: 'Sepetim'),
              Tab(icon: Icon(Icons.person_outline, size: 28), text: 'Hesabım'),
            ],
          ),
        )),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20, right: 20),
          child: FloatingActionButton(
            onPressed: _handleCheckIn,
            backgroundColor: Colors.orange,
            child: Icon(
              _isCheckedIn ? Icons.location_on : Icons.add_location_outlined,
              size: 30,
            ),
            tooltip: _isCheckedIn ? 'Buradakiler' : 'Check-in Yap',
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
