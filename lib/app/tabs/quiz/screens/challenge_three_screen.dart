import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/quiz/models/question.dart';
import 'package:food_bit_app/app/tabs/quiz/screens/quiz_screen.dart';
import 'package:food_bit_app/app/tabs/quiz/utils/default_gradient.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/bouncing_widget.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/number_timer.dart';
import 'package:food_bit_app/app/tabs/quiz/utils/networking.dart' as network;
import 'package:food_bit_app/app/tabs/quiz/widgets/show_result.dart';

class ChallengeThreeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChallengeThreeScreenState();
}

class _ChallengeThreeScreenState extends State<ChallengeThreeScreen> {
  bool loading = true;
  FirebaseService service = new FirebaseService();
  int current = 0;
  int kisiSayisi = 0;
@override
void initState() {
  super.initState();
  _initialize();  // Asenkron işlemi başka bir metodda çağırıyoruz
}

Future<void> _initialize() async {
  kisiSayisi = await getCount();  // Asenkron işlemi burada bekliyoruz
  refresh();  // Yeniden düzenleme veya işlemi tetikleyin
}

Future<int> getCount() async {
  return await service.getQuizTodayUserCount();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(gradient: DefaultGradient.defaultGradient),
        child: loading
            ? NumberTimer(onCompleted: () {
                setState(() {
                  this.loading = false;
                  current++;
                });
              })
            : current < questions.length
                ? QuizScreen(
                  kisiSayisi: kisiSayisi,
                    question: questions[current],
                    onCompleted: () {
                      setState(() {
                        this.loading = true;
                      });
                    },
                  )
                : BouncingWidget2(
          duration: Duration(seconds: 2),  
            onClaimPrize: () {
              // "Ödülü Al" butonuna basıldığında yapılacak işlemi burada tanımlayın
              print("Ödül Alındı!");
            },   
        ),
        ),
      
    );
    // return Scaffold();
  }

  List<Question> questions = [];
  void refresh() {
    network.getQuestions().then((ques) {
      print(ques.length);
      if (mounted) {
        setState(() {
          questions.clear();
          questions.addAll(ques);
        });
      }
    });
  }
}