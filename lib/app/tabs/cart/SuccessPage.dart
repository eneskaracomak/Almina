import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SuccessPage extends StatelessWidget {
  final String qrData;
  List<CartItem>  carItem;
  String userPhone;
  SuccessPage({required this.qrData,required this.carItem,required this.userPhone});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> orderData = {
      'UserPhone': userPhone,
      'DateTime': DateTime.now().toIso8601String(),
      'CartItems': this.carItem.map((item) => item).toList(), // CartItems'i Map formatına dönüştürüyoruz
    };
    print(jsonEncode(orderData));
    return Scaffold(
      appBar: AppBar(
        title: Text("Sipariş Başarılı"),
        backgroundColor: Colors.green, // Başarı simgesi için yeşil renk
      ),
      body: SingleChildScrollView( // Kaydırma özelliği eklendi
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Başarı simgesi
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100.0,
              ),
              SizedBox(height: 20.0),

              // Sipariş Detayları
              Text(
                "Siparişiniz Başarıyla Alındı!",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Siparişiniz başarıyla alındı. QR kodunu garsona göstererek siparişinizi teslim alabilirsiniz.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.black54),
              ),
              SizedBox(height: 20.0),

              // QR Kod
              QrImageView(
                data: jsonEncode(orderData), // QR kodu için veri
                version: QrVersions.auto,
                size: 250.0,
                foregroundColor: Colors.black,
              ),
              SizedBox(height: 20.0),

              // Sipariş Detayları Liste
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.0)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sipariş Detayları:",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10.0),
                  
                    ...this.carItem.asMap().entries.map((entry) {
      int index = entry.key + 1; // Liste numaralandırması için
      CartItem item = entry.value;
      return Text(
        "$index. ${item.name} - ${item.quantity} x ${item.price.toStringAsFixed(2)} TL",
        style: TextStyle(fontSize: 16.0),
      );
    }).toList(),
                    Divider(color: Colors.black26),
                   Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Toplam:", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        Text(
          "${this.carItem.fold<double>(0, (sum, item) => sum + (item.quantity * item.price)).toStringAsFixed(2)} TL",
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
