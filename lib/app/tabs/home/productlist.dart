import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:food_bit_app/app/components/food_card.dart';

class ProductListPage extends StatefulWidget {
  final String categoryName;

  ProductListPage({required this.categoryName});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  FirebaseService firebaseService = FirebaseService();

  Future<List<PopularFood>> fetchProducts(String categoryName) async {
    return await firebaseService.getPopularFoodsByCategoryFromRealtimeDatabase(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<PopularFood>>(
        future: fetchProducts(widget.categoryName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Bir hata oluştu. Lütfen tekrar deneyin.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final products = snapshot.data!;
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 1.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 0.80, // Kartların oranını düzenler
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  var product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        'details',
                        arguments: {
                          'product': product,
                          'index': index,
                        },
                      );
                    },
                    child: Hero(
                      tag: 'detail_food$index',
                      child: FoodCard(
                        width: MediaQuery.of(context).size.width / 2 - 20.0,
                        primaryColor: Theme.of(context).primaryColor,
                        productName: product.name,
                        productPrice: product.price,
                        productUrl: product.image,
                        productClients: product.clients,
                        productRate: product.rating,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text(
                'Ürün bulunamadı.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }
}
