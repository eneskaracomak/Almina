import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_bit_app/app/app.dart';
import 'package:food_bit_app/app/app_garson.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/components/bezierContainer.dart';
import 'package:food_bit_app/app/tabs/home/signup.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<dynamic> checkUserExists(String phone, String password) async {
    try {

      final databaseReference = FirebaseDatabase.instance.ref("users");

      final snapshot = await databaseReference.get();

      if (snapshot.exists) {
        final users = Map<String, dynamic>.from(snapshot.value as Map);

        for (var user in users.values) {
          if (user['phone'] == phone && user['password'] == password) {
            return user; // Kullanıcı bulundu
          }
        }
      }
      return false; // Kullanıcı bulunamadı
    } catch (e) {
      print("Error: $e");
      return false; // Hata durumunda kullanıcı bulunamadı varsayılır
    }
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    var userExists = await checkUserExists(phone, password);
    print("userExists");
    print(userExists);
    if (userExists != null) {
      // SharedPreferences'e kullanıcı bilgilerini kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      FirebaseService service = new FirebaseService();
      await prefs.setString('userPhone', phone); // Kullanıcı bilgisi saklanır
      await prefs.setString('isGarson', userExists["isGarson"].toString()); // Kullanıcı bilgisi saklanır
      await prefs.setString('isAdmin', userExists["isAdmin"].toString()); // Kullanıcı bilgisi saklanır
      var detail = await service.getUserDataByPhone(phone);
      print("Enes");
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Telefon numarası veya şire hatalı!")),
      );
    }
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: Colors.white),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
  controller: controller,
  obscureText: isPassword,
  keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
  inputFormatters: isPassword
      ? null
      : [
          FilteringTextInputFormatter.digitsOnly, // Sadece rakamlara izin ver
        ],
  decoration: InputDecoration(
    border: InputBorder.none,
    fillColor: Color(0xfff3f3f4),
    filled: true,
  ),
),
        ],
      ),
    );
  }


  Widget _submitButton() {
    return InkWell(
      onTap: () {
       _login();
      },
      child:Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
         
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color.fromARGB(255, 175, 58, 29)])),
      child: Text(
        'Giriş Yap',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ));
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Henüz Hesabın Yokmu?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Kayıt Ol',
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Al',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 255, 255, 255)
          ),
          children: [
            TextSpan(
              text: 'mi',
              style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 30),
            ),
            TextSpan(
              text: 'na',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 30),
            ),
            TextSpan(
              text: '\nCafe Restaurant',
              style: TextStyle(color: Color.fromARGB(255, 255, 253, 252), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Telefon Numarası",_phoneController),
        _entryField("Parola",_passwordController, isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
              decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/back.jgp'),
              fit: BoxFit.cover, // Resmin nasıl yerleşeceğini belirtir
            )),
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .3),
                  _title(),
                  SizedBox(height: 50),
                  _emailPasswordWidget(),
                  SizedBox(height: 20),
                  _submitButton(),                  
                  _createAccountLabel(),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}