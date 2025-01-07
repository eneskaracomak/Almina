import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/quiz/models/question.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/alert_widget.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/bouncing_widget.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/question_widget.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/quiz_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class QuizScreen extends StatefulWidget {
  final Question question;
  final Function onCompleted;
  final int kisiSayisi;
  const QuizScreen(
      {Key? key, required this.question, required this.onCompleted, required this.kisiSayisi})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool answerable = true;
  bool answered = false;
  bool correct = false;
  bool showAnswer = false;
  String answer = '';
  late Question question;
  @override
  void initState() {
    super.initState();
    question = widget.question;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Center(
          child: BouncingWidget(
            duration: Duration(seconds: 1),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                buildTimer(),
                QuestionWidget(
                  answer: showAnswer ? answer : null,
                  onClicked: (answer) {
                    this.answer = answer;
                    if (this.answer == question.correctAnswer) {
                      correct = true;
                    }
                  },
                  answerable: answerable,
                  question: question,
                )
              ]),
            ),
          ),
        ));
  }

  Widget buildTimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox.fromSize(
                size: Size(110.0, 25.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        size: 22.0,
                        color: Colors.black38,
                      ),
                      Text("Kişi : ${widget.kisiSayisi}",
                          style: TextStyle(
                              color: Colors.black38,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w800)),
                    
                    ],
                  ),
                ),
              ),
              SizedBox.fromSize(
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text("Almina Cafe",
                        style: TextStyle(
                            color: Colors.black38,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900)),
                  )),
            ],
          ),
          !showAnswer
              ? QuizTimer(
                  onCompleted: () {
                    setState(() {
                      answerable = false;
                    });
                    if (correct == null) correct = false;
                    convertToAnswered();
                  },
                  duration: Duration(seconds: 6),
                )
              : (correct
                  ? AlertWidget(
                      iconData: Icons.check,
                      boxDecoration: BoxDecoration(color: Colors.green),
                      label: "Doğru",
                    )
                  : AlertWidget(
                      iconData: Icons.clear,
                      boxDecoration: BoxDecoration(color: Colors.red),
                      label: "Yanlış",
                    )),
        ],
      ),
    );
  }

Future<void> convertToAnswered() async {
  FirebaseService _firebaseService = new FirebaseService();
  SharedPreferences pref = await SharedPreferences.getInstance();
  var user = pref.getString("userPhone");
  Future.delayed(Duration(seconds: 1, milliseconds: 500)).then((val) {
    showAnswer = true;
    if (mounted) setState(() {});

    Future.delayed(Duration(seconds: 2)).then((val) {
      if (correct) {
        // Doğru cevap verildiyse yarışmaya devam et
        widget.onCompleted();
      } else {
        _firebaseService.checkAndUpdateUser(user!);
        Navigator.of(context).pop();  // anasayfa yönlendirmesi
      }
    });
  });
}

}