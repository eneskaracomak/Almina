import 'package:flutter/material.dart';
import 'package:food_bit_app/app/tabs/quiz/models/answer.dart';
import 'package:food_bit_app/app/tabs/quiz/models/question.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/answer_widget.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/option_widget.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final bool answerable;
  final Function onClicked;
  final String? answer;
  const QuestionWidget(
      {Key? key,
      required this.question,
      required this.answerable,
      required this.onClicked,
      this.answer})
      : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  String? selectedOption;  // Seçilen şık
  bool clicked = false;  // Tıklanabilirlik durumu
  
  @override
  Widget build(BuildContext context) {
    Question question = widget.question;
    List<Widget> widgets = [];

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          question.title,
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (widget.answer == null) {
      // Doğru cevabın index'ini elde ediyoruz (eğer doğru cevap varsa)

      question.options.forEach((option) {
        widgets.add(OptionWidget(
          label: option,
          showProgress: false,
          progress: 100,
          isSelected: selectedOption == option,  // Seçili şık mı?
          onClicked: widget.answerable && !clicked
              ? () {
                  setState(() {
                    selectedOption = option;
                    clicked = true;
                  });
                  widget.onClicked(option);  // Cevap işlemi yapılacak fonksiyon
                }
              : () {},
        ));
      });
    } else {
      // Cevap verildiyse doğru/yanlış seçenekleri gösterilecek
      int count = 0;
      question.options.forEach((option) {
        // Seçenekleri, doğru cevabın yerini değiştirmeyecek şekilde gösteriyoruz.
        widgets.add(AnswerWidget(
          progress: getRatios()[count++],
          option: option,
          type: getAnswerType(option),
        ));
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  AnswerType getAnswerType(String option) {
    Question question = widget.question;
    if (question.correctAnswer == option) {
      return AnswerType.Right;
    } else if (question.correctAnswer != widget.answer &&
        option == widget.answer) {
      return AnswerType.Wrong;
    }
    return AnswerType.NotSelected;
  }

  List getRatios() {
    return [100.0, 100.0, 100.0];
  }
}
