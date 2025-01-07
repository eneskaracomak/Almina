import 'dart:async';
import 'dart:convert';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/quiz/models/question.dart';
import 'package:http/http.dart' as http;



Future<List<Question>> getQuestions()async{
  FirebaseService service = new FirebaseService();
  var res = await service.getQuiz();
  List<Question> questions = res.map((item) => Question.fromJson(item)).toList();
  return questions;
}

Question getQuestion() {
  return Question(
    title: "What was the name of the Ethiopian Wolf before they knew it was related to wolves?",
    incorrectAnswers: ["Amharic Fox","Simien Jackel",],
    correctAnswer:"Ethiopian Coyote" 
  );
}