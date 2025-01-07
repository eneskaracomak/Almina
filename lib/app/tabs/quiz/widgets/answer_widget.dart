import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_bit_app/app/tabs/quiz/models/answer.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/option_widget.dart';

class AnswerWidget extends StatefulWidget {
  final AnswerType type;
  final String option;
  final double progress;
  const AnswerWidget({Key? key, required this.option, required this.type, required this.progress})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  double width = 0.0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100)).then((val) {
      if (mounted) {
        setState(() {
          width = MediaQuery.of(context).size.width * 3 / 4;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        OptionWidget(
                    onClicked: (){},
          label: widget.option,
          color: Colors.black,
          progress: widget.progress,
          showProgress: false,
        ),
        OptionWidget(
          onClicked: (){},
          label: widget.option,
          color: widget.type == AnswerType.NotSelected
              ? Colors.transparent
              : Colors.white,
          background: widget.type == AnswerType.NotSelected
              ? Colors.blueGrey.withOpacity(0.5)
              : (widget.type == AnswerType.Right)
                  ? Colors.green.withOpacity(0.9)
                  : Colors.red.withOpacity(0.9),
          progress: widget.progress,
          showProgress: true,
        ),
      ],
    );
  }
}