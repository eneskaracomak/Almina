import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/components/custom_header.dart';
import 'package:food_bit_app/app/manager/cart_manager.dart';


Widget detailsTab(String desc) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
          child: Text(
            desc
          ),
        ),
      ],
    ),
  );
}
class BodyDetails extends StatefulWidget {
  @override
  _BodyDetailsState createState() => _BodyDetailsState();
}

class _BodyDetailsState extends State<BodyDetails>
    with TickerProviderStateMixin {
  int quantity = 0;
  late TabController _tabController;
  CartManager cartManager = new CartManager();
  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
  }


void addToCart(CartItem item) {
    setState(() {
      cartManager.addToCart(item);
    });
  }
  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    late PopularFood product;

    if (route != null && route.settings.arguments != null) {
      final Map<dynamic, dynamic> screenArguments =
          route.settings.arguments as Map<dynamic, dynamic>;
      product = screenArguments['product'] as PopularFood;
    }

    ThemeData theme = Theme.of(context);
    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // Başlık
            Stack(
              children: [
                // Arka Plan Görseli
                Container(
                  height: size.height * 0.4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(product.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Üst Menü
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            // Detaylar
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün Adı ve Fiyat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColorDark,
                          ),
                        ),
                        Text(
                          '${product.price} Puan',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),

                    // Açıklama
                    Text(
                      "Açıklama",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),

                    // Sepete Ekleme ve Adet
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: theme.primaryColor),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 0) quantity--;
                                });
                              },
                            ),
                            Text(
                              "$quantity",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline,
                                  color: theme.primaryColor),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                                                  addToCart(new CartItem(name: product.name, price: double.parse(product.price), rate: 0, clients: product.clients, image: product.image));

                                });
                              },
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {

   setState(() {
                                this.quantity++;
                                addToCart(new CartItem(name: product.name, price: double.parse(product.price), rate: 0, clients: product.clients, image: product.image));
                          });                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            backgroundColor: theme.primaryColor,
                          ),
                          child: Text(
                            "Sepete Ekle",
                            style: TextStyle(fontSize: 18.0,color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
