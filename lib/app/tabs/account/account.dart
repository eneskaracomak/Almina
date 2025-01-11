
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_bit_app/app/tabs/home/loginPage.dart';
import 'package:http/http.dart' as http;

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String profileImage = ''; // Varsayılan profil resmi
  String userName = 'Bilinmiyor';
  String userPhone = 'Bilinmiyor';
  int userPoint = 0;
  String userAddress = 'Adres eklenmemiş';
  File? _selectedImage; // Seçilen resim dosyası
  final String uploadUrl = 'https://alminacafe.com/upload'; // Resim yükleme URL'si

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      await _uploadImage(_selectedImage!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      final response = await request.send();

      if (response.statusCode == 200) {
          FirebaseService service = new FirebaseService();

      // API'den dönen dosya yolu
      await service.updateUserProfilePic(userPhone, "https://alminacafe.com/uploads/"+ request.files.first.filename!);
     
      await 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 24.0),
                SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Profil resmi başarıyla yüklendi.',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        );
      } else {
        throw Exception('Yükleme başarısız: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 24.0),
              SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  'Bir hata oluştu: $e',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      );
    }
  }
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('userPhone');

    if (phone != null) {
      setState(() {
        userPhone = phone;
      });

      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
      final userSnapshot = await databaseRef.child("users").orderByChild("phone").equalTo(phone).get();

      if (userSnapshot.exists) {
        final userData = (userSnapshot.value as Map).values.first as Map;
        setState(() {
          userName = userData['name'] ?? '';
          profileImage = userData['profilePic'] ?? 'https://alminacafe.com/uploads/dummy.jpg';
          userAddress = userData['address'] ?? '';
          userPoint = userData['point'] ?? 0;
        });
        _nameController.text = userName;
        _addressController.text = userAddress;
      }
    }
  }

  Future<void> _updateUserData() async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    final userSnapshot = await databaseRef.child("users").orderByChild("phone").equalTo(userPhone).get();

    if (userSnapshot.exists) {
      final userKey = (userSnapshot.value as Map).keys.first;
      await databaseRef.child("users/$userKey").update({
        "name": _nameController.text,
        "address": _addressController.text,
      });

      // Kullanıcı arayüzünü güncelle
      setState(() {
        userName = _nameController.text;
        userAddress = _addressController.text;
      });

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white, size: 24.0),
        SizedBox(width: 10.0),
        Expanded(
          child: Text(
            'Bilgiler başarıyla güncellendi.',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.green, // Arka plan rengi
    behavior: SnackBarBehavior.floating, // SnackBar pozisyonu ayarlanabilir
    margin: EdgeInsets.only(
      left: 16.0, 
      right: 16.0, 
      bottom: MediaQuery.of(context).size.height * 0.7, // Ekranın altından %10 yukarı
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0), // Yuvarlatılmış köşeler
    ),
    duration: Duration(seconds: 3), // Görünme süresi
  ),
);

    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bilgileri Güncelle'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Ad Soyad'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ad Soyad boş olamaz';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Adres'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Adres boş olamaz';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _updateUserData();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Column(
                children: [
               GestureDetector(
  onTap: () {
    _pickImage();

  },
  child: Stack(
    alignment: Alignment.center,
    children: [
      CircleAvatar(
        backgroundColor: Colors.white,
        radius: 70.0,
        backgroundImage: NetworkImage(profileImage),
      ),
      if (profileImage == "https://alminacafe.com/uploads/dummy.jpg") ...[
      Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 30,
            ),
            SizedBox(height: 5),
            Text(
              "Fotoğraf Yükle",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ]],
  ),
),

                  SizedBox(height: 20.0),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    userPhone,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  _buildInfoCard('Ad Soyad', userName),
                  SizedBox(height: 8.0),
                  _buildInfoCard('Adres', userAddress),
                  SizedBox(height: 8.0),
                  _buildInfoCard('Puan', userPoint.toString()),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
              child: ElevatedButton(
                onPressed: _showEditDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 45, 209, 221),
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Bilgileri Düzenle',
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                ),
              ),
            ),


// Ayarlar Butonları
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 10.0),
              child: Column(
                children: [
                  _buildSettingOption(title:'Bildirimler',icon: Icons.notifications),
                  _buildSettingOption(title:'Gizlilik Ayarları', icon:Icons.lock),
                ],
              ),
            ),

            // Çıkış Yap Butonu
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ElevatedButton(
                onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

// Sıfırlanmayacak anahtarları belirleyin
List<String> excludedKeys = ['lastSpinDate','lastCheckInTime'];

// Tüm anahtarları listeleyin
Set<String> allKeys = prefs.getKeys();

// Sıfırlanacak anahtarları kaldırın
for (String key in allKeys) {
  if (!excludedKeys.contains(key)) {
    prefs.remove(key);
  }
}


                  // Login sayfasına yönlendirme
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Çıkış Yap',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildSettingOption({
   required String title,
    required IconData icon,
}) {
  return GestureDetector(
    onTap: (){},
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30.0, color: Colors.blue),
          SizedBox(width: 20.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
        ],
      ),
    ),
  );
}

  Widget _buildInfoCard(String title, String info) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          Text(
            info,
            style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
