import 'package:flutter/material.dart';
import 'package:food_bit_app/app/tabs/quiz/utils/default_gradient.dart';
import 'package:food_bit_app/app/tabs/quiz/widgets/bouncing_widget.dart';

class OptionWidget extends StatelessWidget {
  final Color background, color;
  final Function onClicked;
  final double progress;
  final bool showProgress;
  final String label;
  final bool isSelected;  // Dışarıdan gelen tıklanma durumu
  const OptionWidget(
      {Key? key,
      required this.label,
      this.color = Colors.black,
      this.background = Colors.white,
      required this.onClicked,
      this.progress = 1.0,
      this.showProgress = true,
      this.isSelected = false})  // isSelected parametresi ekledik
      : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BouncingWidget(
      child: _buildOption(),
      duration: Duration(seconds: 2),
    );
  }

  Widget _buildOption() {
    return LayoutBuilder(
      builder: (context, contraints) {
        double width = contraints.maxWidth;
        return GestureDetector(
          onTap: () {
            if (onClicked != null) {
              onClicked();  // Şık tıklanınca dışarıdaki onClicked çalışacak
            }
          },
          child: AnimatedContainer(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
            height: 72.0,
            alignment: Alignment.centerLeft,
            width: width * (showProgress ? progress : 1.0),
            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: isSelected ? null : background,
              border: background != Colors.white
                  ? null
                  : Border.all(
                      color: Colors.black45,
                      width: 1.2,
                    ),
              borderRadius: BorderRadius.circular(72.0),
              gradient: isSelected ? DefaultGradient.defaultGradient : null,
            ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildText(label),
                  
                         Container(
                            width: 0.0,
                            height: 0.0,
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildText(String text) {
    return Text(text,
        style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 20.0,
            fontWeight: FontWeight.w600), overflow: TextOverflow.clip);
  }
}
