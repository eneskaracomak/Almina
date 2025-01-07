import 'dart:math';

class Question {
  final String title;
  final List<String> incorrectAnswers;
  final String correctAnswer;

  Question({
    required this.title,
    required this.incorrectAnswers,
    required this.correctAnswer,
  });

  // JSON'dan Question nesnesi oluşturma
  Question.fromJson(Map<String, dynamic> json)
      : title = json["question"],
        incorrectAnswers = List<String>.from(json["incorrect_answers"]),
        correctAnswer = json["correct_answer"];

  // Doğru cevabı ve yanlış cevapları içeren bir seçenekler listesi döndüren metot
  List<String> get options {
    List<String> options = [];
    options.addAll(incorrectAnswers.take(2));
      Random random = Random();
    int correctAnswerIndex = random.nextInt(2); // 0 ile yanlış cevapların sayısı arasında bir sayı seç

    options.insert(correctAnswerIndex, correctAnswer); // Doğru cevabı 3. sıraya ekliyoruz
    return options;
  }
}
