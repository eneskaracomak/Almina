import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_bit_app/app/app.dart';
import 'package:food_bit_app/app/components/bezierContainer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _PhoneNumberFormatter extends TextInputFormatter {
   @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Eğer telefon numarasının uzunluğu 11'den büyükse, değişikliği engelle
    if (newValue.text.length > 11) {
      return oldValue;
    }

    // Başlangıç kontrolü: "053" ile başlıyor mu?
    if (newValue.text.length > 0 && !newValue.text.startsWith('053')) {
      return oldValue; // Değişikliği engelle
    }

    return newValue; // Geçerli değeri kabul et
  }
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameSurnameController = TextEditingController();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  bool _isLoading = false; // Buton durumu için bir kontrol değişkeni
  bool _isPhoneNumberValid(String phoneNumber) {
    // Telefon numarasının 11 haneli ve "053" ile başlaması gerektiğini kontrol et
    return phoneNumber.length == 11 && phoneNumber.startsWith('05');
  }
  Future<void> _signUp() async {
    // Kullanıcı verilerini al
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameSurnameController.text.trim();

    // Alanlar boşsa hata göster
    if (phone.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Kaydet butonunu yükleme durumuna geçir
    });

    try {
      // Firebase Realtime Database'e veri kaydet
      await _db.child("users").push().set({
        'phone': phone,
        'password': password,
        'isActive': true,
        'isGarson': false,
        'isAdmin': false,
        'point': 0,
        'name': name,
        'isNotification': true,
      });

      // Kullanıcı bilgisini SharedPreferences ile kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userPhone', phone);
      prefs.setString('userPassword', password);

      // Kayıt başarılı olduğunda ana sayfaya yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => App()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarısız. Lütfen tekrar deneyin.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Kaydet butonunu normal duruma getir
      });
    }
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: const Color.fromARGB(255, 255, 255, 255)),
            ),
            Text('Geri Dön',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: Colors.white))
          ],
        ),
      ),
    );
  }
  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false, bool isPhoneNumber = false}) {
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
          keyboardType: isPhoneNumber ? TextInputType.phone : TextInputType.text,
          inputFormatters: isPhoneNumber
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ]
              : [],
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Color(0xfff3f3f4),
            filled: true,
            hintText: isPhoneNumber ? "" : null,
          ),
        ),
      ],
    ),
  );
}


  Widget _submitButton() {
    return GestureDetector(
       onTap: () {
        if (_isPhoneNumberValid(_phoneController.text)) {
          // Telefon numarası geçerli ise, kayıt işlemini başlat
          _signUp();
        } else {
          // Geçersiz telefon numarası girişi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Geçersiz telefon numarası. Lütfen 05 ile başlayın ve 11 haneli numara girin.')),
          );
        }
      }, // Yükleme sırasında ikinci tıklama engellenir
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
     
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)],
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white) // Çark ekleniyor
            : Text(
                'Kayıt Ol',
                style: TextStyle(fontSize: 20, color: Colors.white),
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
          color: Color.fromARGB(255, 255, 255, 255),
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
            style: TextStyle(
              color: Color.fromARGB(255, 255, 252, 251),
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Ad Soyad", _nameSurnameController),
        _entryField("Telefon Numarası", _phoneController,isPhoneNumber: true),
        _entryField("Parola", _passwordController, isPassword: true),
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
              image: AssetImage('images/back.jpg'),
              fit: BoxFit.cover, // Resmin nasıl yerleşeceğini belirtir
            ),
          ),
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
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
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
