import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/tabs/home/details/body_details.dart';

class Details extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
   final route = ModalRoute.of(context);
   late PopularFood product;
   int index=0;
if (route != null && route.settings.arguments != null) {
  final Map<dynamic, dynamic> screenArguments =
      route.settings.arguments as Map<dynamic, dynamic>;
         
  product = screenArguments['product'] as PopularFood;
      index = screenArguments['index'];
  

}


    return Scaffold(
      body: Stack(
        children: <Widget>[
          Hero(
            tag: 'detail_food$index',
            child: Container(
              alignment: Alignment.topCenter,
              width: size.width,
              height: size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product.image),
                ),
              ),
            ),
          ),
          BodyDetails(),
        ],
      ),
    );
  }
}