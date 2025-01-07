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
  FirebaseService firebaseService = new FirebaseService();

  // Firebase'den kategoriye ait ürünleri çeken fonksiyon
  Future<List<PopularFood>> fetchProducts(String categoryName) async {
    return await firebaseService.getPopularFoodsByCategoryFromRealtimeDatabase(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
  appBar: AppBar(
    title: Text('${widget.categoryName}'),
  ),
  body: FutureBuilder<List<PopularFood>>(
    future: fetchProducts(widget.categoryName),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Something went wrong.'));
      } else if (snapshot.hasData) {
        final products = snapshot.data!;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0), // Üst ve alt padding ekleyin
          child: GridView.builder(
            padding: const EdgeInsets.only(left: 10.0, bottom: 10.0), // Alt paddingi buradan ekleyebilirsiniz
            shrinkWrap: true, // GridView'in yalnızca içeriği kadar yer kaplamasını sağlar
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Her satırda 2 öğe olacak şekilde ayarlanır
              mainAxisSpacing: 10.0, // Öğeler arasında dikey boşluk
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
                    width: MediaQuery.of(context).size.width / 2 - 30.0,  // Yarım genişlik
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
        return Center(child: Text('No products found.'));
      }
    },
  ),
);

  }
}
