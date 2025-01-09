import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/quiz/screens/challenge_three_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizTimerWidget extends StatefulWidget {
  @override
  _QuizTimerWidgetState createState() => _QuizTimerWidgetState();
}

class _QuizTimerWidgetState extends State<QuizTimerWidget> {
  late Timer _timer;
  int _remainingSeconds = 10; // 3 dakika = 180 saniye
  bool _isTimeUp = false;
  FirebaseService _firebaseService = new FirebaseService();
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _isTimeUp = true;
        });
        _timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _onJoinQuiz() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = prefs.getString("userPhone");
    await _firebaseService.addUserToQuiz(user!);
    var quizCount = await _firebaseService.getQuizTodayUserCount();
    var quizUser = await _firebaseService.getUserQuizDataForToday(user);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            // Taşmayı engellemek için SingleChildScrollView ekleyelim
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Yarışma Hakkında",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Almina Quiz Yarışmasına Katılmak için:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                  title: Text(
                    "Ödül",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Yarışmada tüm sorulara doğru cevap veren kişiye 200 PUAN ve WAFFLE ikram edilecektir",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Divider(color: Colors.grey[300]),
                ListTile(
                  leading: Icon(
                    Icons.card_giftcard,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                  title: Text(
                    "Yarışma Şartları",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8), // Başlık ile liste arasında boşluk
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• "),
                          Expanded(
                            child: Text(
                              "Yarışmada toplam 10 soru yer almaktadır.",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4), // Liste öğeleri arasında boşluk
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• "),
                          Expanded(
                            child: Text(
                              "Her soru için 10 saniye süre vardır.",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• "),
                          Expanded(
                            child: Text(
                              "Yarışma başlaması için en az 10 kullanıcı olmak zorundadır.",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• "),
                          Expanded(
                            child: Text(
                              "Mevcut Kullanıcı: ${quizCount} ",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () async {
                    // Günlük kullanıcı sayısını kontrol et

                    if (quizCount >= 2) {
                      // Yeterli kullanıcı varsa yönlendir
                      print(quizUser.first.isTrue);
                      print(quizUser.first.dateTime);
                      print(quizUser.first.userPhone);
                      if (quizUser.first.isTrue) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChallengeThreeScreen()),
                        );
                      } else {
                        showTopSnackbar(
                          context,
                          "Yarışmadan elendiniz :( Lütfen bir sonraki yarışmayı bekleyin.",
                        );
                      }
                    } else {
                      showTopSnackbar(
                        context,
                        "Yarışma başlaması için en az 10 kullanıcı gereklidir. Şu anki kullanıcı sayısı: $quizCount",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      "Yarışmaya Gir",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showTopSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top +
            10, // Status bar altında gösterim
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    // Snackbar 4 saniye sonra kaldırılır
    Future.delayed(Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5, left: 5),
      height: 55,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 102, 102), // Açık kırmızı
            Color.fromARGB(255, 184, 85, 85), // Koyu kırmızı
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16), // Daha yumuşak köşeler
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Daha belirgin gölge
            blurRadius: 12, // Daha yumuşak bir gölge efekti
            offset: Offset(0, 4), // Gölgede hafif yukarı kayma
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Bilgi Yarışması",
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          _isTimeUp
              ? ElevatedButton(
                  onPressed: _onJoinQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 54, 192, 72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Katıl",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                )
              : Text(
                  "Süre: ${_formatTime(_remainingSeconds)}",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
        ],
      ),
    );
  }
}
