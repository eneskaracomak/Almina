import 'package:flutter/material.dart';
import 'package:food_bit_app/app/tabs/home/homegarson.dart';

class AppGarson extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: HomeGarson(),       
      ),
    );
  }
}
