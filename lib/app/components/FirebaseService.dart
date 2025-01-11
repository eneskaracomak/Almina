import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stories_for_flutter/stories_for_flutter.dart';

class FirebaseService {
  final DatabaseReference _db =
      FirebaseDatabase.instance.ref(); // Realtime Database referansı
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore referansı
  final DatabaseReference _notificationRef =
      FirebaseDatabase.instance.ref().child('Notifications');
  final DatabaseReference _storiesRef =
      FirebaseDatabase.instance.ref().child('Stories');
  Future<void> updateNotification(String description, DateTime dateTime) async {
    try {
      // Tüm bildirimleri al
      final snapshot = await _notificationRef.get();
      if (snapshot.exists) {
        // Her bir bildirimi döngüyle kontrol et
        for (var child in snapshot.children) {
          final Map<dynamic, dynamic>? value =
              child.value as Map<dynamic, dynamic>?;
          if (value != null) {
            // Eşleşen kayıt kontrolü
            if (value['Description'] == description &&
                DateTime.parse(value['DateTime']) == dateTime) {
              // isActive değerini false yap
              await _notificationRef.child(child.key!).update({
                'IsActive': false,
              });
              print("Bildirim güncellendi: ${child.key!}");
              return; // İşlem tamamlandığında çık
            }
          }
        }
        print("Eşleşen bir kayıt bulunamadı.");
      } else {
        print("Bildirimler bulunamadı.");
      }
    } catch (e) {
      print("Güncelleme sırasında hata oluştu: $e");
    }
  }

  Future<List<NotificationModel>> fetchActiveNotifications() async {
    try {
      final snapshot = await _notificationRef.get();
      if (snapshot.exists) {
        final notifications = <NotificationModel>[];
        print(snapshot);
        for (var child in snapshot.children) {
          final data = child.value as Map<dynamic, dynamic>;
          // Sadece isActive = true olanları ekle
          if (data['IsActive'] == true) {
            notifications.add(
              NotificationModel.fromJson(
                child.key!,
                data,
              ),
            );
          }
        }
        return notifications;
      }
      return [];
    } catch (e) {
      print('Error while fetching active notifications: $e');
      return [];
    }
  }



 Future<List<Story>> fetchStories() async {
  try {
    final snapshot = await _storiesRef.get();
    if (snapshot.exists) {
      final notifications = <Story>[];
      print(snapshot);
      for (var child in snapshot.children) {
        final data = child.value;
        if (data is Map<Object?, Object?>) {
          final storyData = data.map((key, value) => MapEntry(key.toString(), value));
          notifications.add(Story.fromJson(storyData));
        }
      }
      return notifications;
    }
    return [];
  } catch (e) {
    print('Error while fetching active notifications: $e');
    return [];
  }
}



  // Firebase Realtime Database'e veri ekleme
  Future<void> addNotification(NotificationModel notification) async {
    try {
      // Yeni bir key oluştur ve veriyi ekle
      final newNotificationRef = _notificationRef.push();
      await newNotificationRef.set(notification.toJson());
      print('Notification successfully added.');
    } catch (e) {
      print('Error while adding notification: $e');
    }
  }

  Future<void> addUserOrder(UserOrder userOrder) async {
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('UserOrder');

    try {
      // UserOrder verisini Firebase Realtime Database'e ekliyoruz
      final newOrderRef = databaseReference.push(); // Yeni bir id oluşturur
      await newOrderRef.set(userOrder.toJson()); // Veriyi ekler
      print('Sipariş başarıyla eklendi!');
    } catch (e) {
      print('Error adding order: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboardDataLocation() async {
    List<Map<String, dynamic>> leaderboardData = [];

    final snapshot = await _db.child('users').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        if ((value['checkIn'] ?? 0) != 0) {
          leaderboardData.add({
            'name': value['name'] ?? 'Bilinmeyen',
            'image': value['profilePic'] ??
                'https://cdn-icons-png.flaticon.com/512/7107/7107994.png',
            'score': value['score'] ?? 0,
            'cafeVisits':
                value['checkIn'] ?? 0, // checkIn kolonunu buraya ekliyoruz
          });
        }
      });

// Sıralama işlemi (cafeVisits değerine göre azalan)
      leaderboardData.sort(
          (a, b) => (b['cafeVisits'] ?? 0).compareTo(a['cafeVisits'] ?? 0));

// Rank atama
      for (int i = 0; i < leaderboardData.length; i++) {
        leaderboardData[i]['rank'] = i + 1; // Rank 1'den başlar
      }

      // Ziyaret sıralaması için sırala
      leaderboardData.sort(
          (a, b) => (b['cafeVisits'] ?? 0).compareTo(a['cafeVisits'] ?? 0));
    }

    return leaderboardData;
  }

  Future<void> addUserNotification(
      String userPhone, String title, String message) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    // Yeni bildirim verisini hazırlayın
    final notificationData = {
      'userPhone': userPhone,
      'title': title,
      'message': message,
      'timestamp': DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Zaman damgası ekleyebilirsiniz
    };

    try {
      // Firebase veritabanında userNotifications altına yeni bir bildirim ekleyin
      await dbRef.child('userNotifications').push().set(notificationData);
      print("Bildirim başarıyla eklendi.");
    } catch (error) {
      print("Bildirim eklerken hata oluştu: $error");
    }
  }

  Future<List<Map<String, dynamic>>> getQuiz() async {
    try {
      DataSnapshot snapshot =
          await FirebaseDatabase.instance.ref("questions").get();

      // Veriler boş değilse, kullanıcıları liste olarak döndürüyoruz
      if (snapshot.exists) {
        List<Map<String, dynamic>> quizUsers = [];
        var data = snapshot.value as Map;

        data.forEach((key, value) {
          quizUsers.add(Map<String, dynamic>.from(value));
        });
        return quizUsers;
      } else {
        return [];
      }
    } catch (e) {
      // Hata durumunda boş liste döndürülüyor
      print("Hata: $e");
      return [];
    }
  }
Future<void> addReservation(Reservation reservation) async {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('Reservations');

  try {
    // Reservation verisini Firebase Realtime Database'e ekliyoruz
    final newReservationRef = databaseReference.push(); // Yeni bir id oluşturur
    await newReservationRef.set(reservation.toJson()); // Veriyi ekler
    print('Rezervasyon başarıyla eklendi!');
  } catch (e) {
    print('Rezervasyon eklenirken bir hata oluştu: $e');
  }
}

  Future<List<User>> getWinnersFromQuizUsers() async {
    try {
      // 'QuizUsers' tablosundaki verileri alıyoruz
      DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref("QuizUsers")
          .orderByChild('isTrue')
          .equalTo(true)
          .get();

      List<User> winners = [];

      // 'isTrue' değeri true olan kayıtları döngüyle alıyoruz
      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

        for (var key in values.keys) {
          // Kazanan kişinin telefon numarasını alıyoruz
          String userPhone = values[key]['userPhone'];

          // Kullanıcıyı 'users' tablosundan buluyoruz
          DataSnapshot userSnapshot = await FirebaseDatabase.instance
              .ref('users')
              .orderByChild('phone')
              .equalTo(userPhone)
              .get();

          if (userSnapshot.exists) {
            Map<dynamic, dynamic> userData =
                userSnapshot.value as Map<dynamic, dynamic>;
            for (var userKey in userData.keys) {
              // Kullanıcıdan gerekli bilgileri alıyoruz (örneğin name, phone, etc.)
              String name = userData[userKey]['name'];
              String phone = userData[userKey]['phone'];

              // Kullanıcı objesini oluşturuyoruz ve listeye ekliyoruz
              winners.add(User(
                  name: name,
                  phone: phone,
                  isActive: true,
                  isAdmin: false,
                  isGarson: false,
                  isNotification: false,
                  password: "",
                  point: 0,
                  profilePic: ""));
            }
          }
        }
      }

      return winners;
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }

  Future<void> checkAndUpdateUser(String userPhone) async {
    // Firebase Realtime Database referansı
    final databaseReference = FirebaseDatabase.instance.ref("QuizUsers");

    // Şu anki tarih
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // Tüm kayıtları al ve kontrol et
      DataSnapshot snapshot = await databaseReference.get();

      String? existingUserKey; // Kullanıcının Firebase key'i
      bool isTrue = true; // Mevcut kullanıcının isTrue durumu

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          // Telefon numarası ve tarih eşleşmesini kontrol et
          if (value['userPhone'] == userPhone &&
              value['dateTime'].toString().startsWith(formattedDate)) {
            existingUserKey = key;
            isTrue = value['isTrue'];
          }
        });
      }

      if (existingUserKey != null) {
        // Kullanıcı zaten kayıtlı, isTrue alanını false yap
        if (isTrue) {
          await databaseReference
              .child(existingUserKey!)
              .update({'isTrue': false});
          print("Kullanıcının isTrue alanı false olarak güncellendi.");
        } else {
          print("Kullanıcının isTrue alanı zaten false.");
        }
      } else {
        // Kullanıcı mevcut değil, yeni kayıt oluştur
        Map<String, dynamic> userData = {
          "userPhone": userPhone,
          "dateTime":
              "${formattedDate} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
          "isTrue": true,
        };

        await databaseReference.push().set(userData);
        print("Yeni kullanıcı başarıyla kaydedildi.");
      }
    } catch (e) {
      print("Kullanıcı kontrol edilirken veya kaydedilirken hata oluştu: $e");
    }
  }

  Future<List<QuizUser>> getUserQuizDataForToday(String userPhone) async {
    // Firebase Realtime Database referansı
    final databaseReference = FirebaseDatabase.instance.ref("QuizUsers");

    // Şu anki tarih ve saati almak için
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    List<QuizUser> quizUsers = [];

    try {
      // Tüm kayıtları al ve kontrol et
      DataSnapshot snapshot = await databaseReference.get();

      if (snapshot.exists) {
        // Firebase'den gelen veriyi kontrol et
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        // Verileri filtrele ve QuizUser nesnelerine dönüştür
        data.forEach((key, value) {
          if (value['userPhone'] == userPhone &&
              value['dateTime'].toString().startsWith(formattedDate)) {
            quizUsers.add(QuizUser.fromMap(value));
          }
        });
      } else {
        print("Veri bulunamadı.");
      }
    } catch (e) {
      print("Veri çekilirken hata oluştu: $e");
    }

    return quizUsers;
  }

  Future<int> getQuizTodayUserCount() async {
    // Firebase Realtime Database referansı
    final databaseReference = FirebaseDatabase.instance.ref("QuizUsers");

    // Şu anki tarih (Yıl-Ay-Gün formatında)
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // Firebase'den tüm kayıtları çek
      DataSnapshot snapshot = await databaseReference.get();

      if (snapshot.exists) {
        // Firebase'den gelen veriyi kontrol et
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        int count = 0;

        // Bugüne ait kullanıcıları say
        data.forEach((key, value) {
          if (value['dateTime'].toString().startsWith(formattedDate)) {
            count++;
          }
        });

        print("Bugünkü toplam kullanıcı sayısı: $count");
        return count;
      } else {
        print("Bugün için hiçbir kayıt bulunamadı.");
        return 0;
      }
    } catch (e) {
      print("Kullanıcı sayısı alınırken hata oluştu: $e");
      return 0;
    }
  }

  Future<void> addUserToQuiz(String userPhone) async {
    // Firebase Realtime Database referansı
    final databaseReference = FirebaseDatabase.instance.ref("QuizUsers");

    // Şu anki tarih ve saati almak için
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      // Tüm kayıtları al ve kontrol et
      DataSnapshot snapshot = await databaseReference.get();

      bool alreadyRegistered = false;

      if (snapshot.exists) {
        // Firebase'den gelen veriyi kontrol et
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value['userPhone'] == userPhone &&
              value['dateTime'].toString().startsWith(formattedDate)) {
            alreadyRegistered = true;
          }
        });
      }

      if (!alreadyRegistered) {
        // Kayıt verisi
        Map<String, dynamic> userData = {
          "userPhone": userPhone,
          "dateTime":
              "${formattedDate} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
          "isTrue": true,
        };

        // Yeni bir kayıt oluştur
        await databaseReference.push().set(userData);
        print("Kullanıcı başarıyla kaydedildi.");
      } else {
        print("Bu kullanıcı zaten bugün kayıt olmuş.");
      }
    } catch (e) {
      print("Kullanıcı kontrol edilirken veya kaydedilirken hata oluştu: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserNotifications(
      String userPhone) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    try {
      // Veritabanından userNotifications verisini çekiyoruz
      final DataSnapshot snapshot = await dbRef
          .child('userNotifications')
          .orderByChild('userPhone')
          .equalTo(userPhone)
          .get();

      if (snapshot.exists) {
        // Gelen veriyi listeye dönüştür
        final List<Map<String, dynamic>> notifications = [];
        for (var child in snapshot.children) {
          final Map<String, dynamic> data =
              Map<String, dynamic>.from(child.value as Map);

          // 'isRead' true ise bu bildirimi atla
          if (data['isRead'] != true) {
            notifications.add(data);
          }
        }
        return notifications; // Bildirimler listesi (isRead: false olanlar)
      } else {
        print('No notifications found for this user.');
        return [];
      }
    } catch (error) {
      print('Error fetching notifications: $error');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboardData() async {
    List<Map<String, dynamic>> leaderboardData = [];

    try {
      // 'users' düğümünden tüm veriyi alıyoruz
      DatabaseEvent event = await _db.child('users').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var usersMap = Map<String, dynamic>.from(snapshot.value as Map);

        // Kullanıcıları User objesine dönüştürme
        List<User> users = [];
        usersMap.forEach((key, value) {
          var userData = Map<String, dynamic>.from(value);
          users.add(User.fromMap(userData));
        });

        // Kullanıcıları score'a göre sıralıyoruz
        users.sort((a, b) => b.point.compareTo(a.point));

        // leaderboardData'ya ekleme
        for (int i = 0; i < users.length; i++) {
          if (users[i].point > 0) {
            leaderboardData.add({
              'rank': i + 1,
              'name': users[i].name,
              'score': users[i].point,
              'image': users[i].profilePic == ''
                  ? 'https://cdn-icons-png.flaticon.com/512/7107/7107994.png'
                  : users[i].profilePic,
            });
          }
        }

        print("Leaderboard data successfully fetched.");
      } else {
        print("No users found.");
      }
    } catch (e) {
      print("Error occurred while fetching leaderboard data: $e");
    }

    return leaderboardData;
  }

  // Firebase Realtime Database'den telefon numarasına göre kullanıcı verisi çekme
  Future<User?> getUserDataByPhone(String phone) async {
    try {
      // Firebase Realtime Database'den veriyi al
      DatabaseEvent event =
          await _db.child("users").orderByChild('phone').equalTo(phone).once();

      // DatabaseEvent nesnesinden DataSnapshot'a erişim
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Kullanıcı verisini User objesine dönüştürme
        var userMap = Map<String, dynamic>.from(snapshot.value as Map);

        // Anahtarı al ve alt veri kısmına eriş
        var userData = userMap
            .values.first; // '-ODzURssmtR0Yli_lN_n' anahtarıyla gelen veri
        User user = User.fromMap(Map<String, dynamic>.from(userData));
        return user;
      } else {
        print("No user found with this phone number.");
        return null;
      }
    } catch (e) {
      print("Error occurred: $e");
      return null;
    }
  }

Future<List<AdBanner>> getAdBannersFromRealtimeDatabase() async {
  List<AdBanner> adBannerList = [];
  try {
    // Firebase Realtime Database bağlantısını oluşturuyoruz
    DatabaseReference db = FirebaseDatabase.instance.reference();
    
    // 'AdBanners' düğümünden veri alıyoruz
    DatabaseEvent event = await db.child('AdBanner').once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      var bannerMap = Map<String, dynamic>.from(snapshot.value as Map);

      bannerMap.forEach((key, value) {
        var bannerData = Map<String, dynamic>.from(value);
        adBannerList.add(AdBanner.fromJson(bannerData)); // Veriyi AdBanner objesine dönüştürüp ekliyoruz
      });
      print("Reklam banner'ları başarıyla alındı.");
    } else {
      print("Reklam banner verisi bulunamadı.");
    }
  } catch (e) {
    print("Reklam banner'ları alınırken bir hata oluştu: $e");
  }
  return adBannerList;
}
  Future<List<PopularFood>> getPopularFoodsFromRealtimeDatabase() async {
    List<PopularFood> popularFoodsList = [];
    try {
      // 'popular_foods' düğümünden veri alıyoruz
      DatabaseEvent event = await _db.child('PopularFood').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var foodMap = Map<String, dynamic>.from(snapshot.value as Map);

        foodMap.forEach((key, value) {
          var foodData = Map<String, dynamic>.from(value);
          popularFoodsList.add(PopularFood.fromMap(
              foodData)); // Veriyi PopularFood objesine dönüştürüp ekliyoruz
        });
        print("Popüler yemekler başarıyla alındı.");
      } else {
        print("No popular food data found.");
      }
    } catch (e) {
      print("Error occurred while fetching popular food options: $e");
    }
    return popularFoodsList;
  }

  Future<List<Order>> getOrdersByUserPhone(String phone) async {
    List<Order> userOrders = [];
    try {
      // 'orders' düğümünden telefon numarasına göre filtreleme yapıyoruz

      DatabaseEvent event =
          await _db.child('orders').orderByChild('phone').equalTo(phone).once();

      // Gelen snapshot verisini işleme
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var ordersMap = Map<String, dynamic>.from(snapshot.value as Map);

        ordersMap.forEach((key, value) {
          var orderData = Map<String, dynamic>.from(value);
          userOrders.add(Order.fromMap(
              orderData)); // Veriyi Order objesine dönüştürüp listeye ekliyoruz
        });

        print("Siparişler başarıyla alındı.");
      } else {
        print("Bu telefon numarasına ait sipariş bulunamadı.");
      }
    } catch (e) {
      print("Error occurred while fetching orders: $e");
    }
    return userOrders;
  }

  Future<List<PopularFood>> getPopularFoodsByCategoryFromRealtimeDatabase(
      String category) async {
    List<PopularFood> popularFoodsList = [];
    try {
      // 'PopularFood/{category}' yolundan veri alıyoruz
      DatabaseEvent event = await _db
          .child('PopularFood')
          .orderByChild('category')
          .equalTo(category)
          .once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var foodMap = Map<String, dynamic>.from(snapshot.value as Map);

        foodMap.forEach((key, value) {
          // Her bir öğeyi Map formatından, PopularFood nesnesine dönüştürüp listeye ekliyoruz
          var foodData = Map<String, dynamic>.from(value);
          popularFoodsList.add(PopularFood.fromMap(
              foodData)); // Veriyi PopularFood objesine dönüştürüp ekliyoruz
        });
        print("Kategoriye göre popüler yemekler başarıyla alındı.");
      } else {
        print("Kategoriye ait popüler yemek verisi bulunamadı: $category");
      }
    } catch (e) {
      print(
          "Kategoriye göre popüler yemek seçenekleri alınırken hata oluştu: $e");
    }
    return popularFoodsList;
  }

  Future<Setting?> fetchSettingsFromDatabase() async {
    try {
      final snapshot = await _db.child('Settings').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return Setting.fromJson(data);
      } else {
        print("Settings tablosunda veri bulunamadı.");
        return null;
      }
    } catch (e) {
      print("Settings verisi çekilirken hata oluştu: $e");
      return null;
    }
  }

  Future<bool> updateUserProfilePic(String phone, String profilePicUrl) async {
    try {
      // Telefon numarasına göre kullanıcı verisini alıyoruz
      DatabaseEvent event =
          await _db.child("users").orderByChild('phone').equalTo(phone).once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Kullanıcı verisini alıyoruz
        var userMap = Map<String, dynamic>.from(snapshot.value as Map);

        // Kullanıcı anahtarını alıyoruz
        String userKey = userMap.keys.first;

        // Profil resmi URL'sini güncelliyoruz
        await _db.child("users/$userKey").update({"profilePic": profilePicUrl});

        print(
            "Kullanıcının profil resmi başarıyla güncellendi. Yeni URL: $profilePicUrl");
        return true;
      } else {
        print("Bu telefon numarasına sahip bir kullanıcı bulunamadı.");
        return false;
      }
    } catch (e) {
      print("Profil resmi güncellenirken bir hata oluştu: $e");
      return false;
    }
  }

  // Firebase Realtime Database'de bir kullanıcının puanını güncelleme
  Future<bool> updateUserPoints(String phone, int point, bool arttir) async {
    try {
      // Telefon numarasına göre kullanıcı verisini alıyoruz
      DatabaseEvent event =
          await _db.child("users").orderByChild('phone').equalTo(phone).once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        // Kullanıcı verisini alıyoruz
        var userMap = Map<String, dynamic>.from(snapshot.value as Map);

        // Kullanıcı anahtarını alıyoruz
        String userKey = userMap.keys.first;

        // Mevcut puanı alıyoruz
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(userMap[userKey]);
        int currentPoint = userData['point'] ?? 0;
        int updatedPoint = 0;
        if (arttir) {
          updatedPoint = currentPoint + point;
        } else {
          updatedPoint = currentPoint - point;
        }

        // Kullanıcının puan bilgisini güncelliyoruz
        await _db.child("users/$userKey").update({"point": updatedPoint});

        print(
            "Kullanıcının puanı başarıyla güncellendi. Yeni puan: $updatedPoint");
        return true;
      } else {
        print("Bu telefon numarasına sahip bir kullanıcı bulunamadı.");
        return false;
      }
    } catch (e) {
      print("Puan güncellenirken bir hata oluştu: $e");
      return false;
    }
  }

  Future<List<Campaign>> getCampaignsFromRealtimeDatabase() async {
    List<Campaign> campaignList = [];
    try {
      DatabaseEvent event =
          await _db.child('Campaigns').once(); // 'Campaigns' düğümünü alıyoruz
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var campaignsMap = Map<String, dynamic>.from(snapshot.value as Map);

        campaignsMap.forEach((key, value) {
          var campaignData = Map<String, dynamic>.from(value);
          campaignList.add(Campaign.fromMap(key,
              campaignData)); // Veriyi Campaign nesnesine dönüştürüp ekliyoruz
        });
        print("Kampanyalar başarıyla alındı.");
      } else {
        print("Kampanya verisi bulunamadı.");
      }
    } catch (e) {
      print("Kampanyaları çekerken bir hata oluştu: $e");
    }
    return campaignList;
  }

  Future<List<FoodOption>> getFoodOptionsFromRealtimeDatabase() async {
    List<FoodOption> foodOptionsList = [];
    try {
      DatabaseEvent event =
          await _db.child('menü').once(); // 'menü' düğümünü alıyoruz
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        var foodMap = Map<String, dynamic>.from(snapshot.value as Map);

        foodMap.forEach((key, value) {
          var foodData = Map<String, dynamic>.from(value);
          foodOptionsList.add(FoodOption.fromMap(
              foodData)); // Veriyi FoodOption objesine dönüştürüp ekliyoruz
        });
        print("Veriler başarıyla alındı.");
      } else {
        print("No menu data found.");
      }
    } catch (e) {
      print("Error occurred while fetching food options: $e");
    }
    return foodOptionsList;
  }
  // Firestore'a veri ekleme
}

class NotificationModel {
  String? description;
  DateTime dateTime;
  bool isActive;

  NotificationModel({
    required this.description,
    required this.dateTime,
    required this.isActive,
  });

  // Firebase'e kaydetmek için JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'Description': description,
      'DateTime': dateTime.toIso8601String(),
      'IsActive': isActive,
    };
  }

  // Firebase'den gelen JSON'u modele dönüştürme
  factory NotificationModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return NotificationModel(
      description: json['Description'] as String,
      dateTime: DateTime.parse(json['DateTime'] as String),
      isActive: json['IsActive'] as bool,
    );
  }
}

class UserOrder {
  final String userPhone;
  final double point;
  final String dateTime;

  UserOrder({
    required this.userPhone,
    required this.point,
    required this.dateTime,
  });

  // JSON dönüşümü
  Map<String, dynamic> toJson() {
    return {
      'UserPhone': userPhone,
      'Point': point,
      'DateTime': dateTime,
    };
  }

  // JSON'dan UserOrder oluşturma
  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      userPhone: json['UserPhone'],
      point: json['Point'],
      dateTime: json['DateTime'],
    );
  }
}

class OrderResult {
  String userPhone;
  String dateTime;
  List<CartItem> cartItems;

  OrderResult({
    required this.userPhone,
    required this.dateTime,
    required this.cartItems,
  });

  // JSON'dan Order nesnesi oluşturma
  factory OrderResult.fromJson(Map<String, dynamic> json) {
    return OrderResult(
      userPhone: json['UserPhone'],
      dateTime: json['DateTime'],
      cartItems: (json['CartItems'] as List)
          .map((cartItemJson) => CartItem.fromJson(cartItemJson))
          .toList(),
    );
  }

  // Order nesnesini JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'UserPhone': userPhone,
      'DateTime': dateTime,
      'CartItems': cartItems.map((cartItem) => cartItem.toJson()).toList(),
    };
  }
}

class Campaign {
  final String id;
  final String title;
  final String description;
  final String dateString;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.dateString,
  });

  // Firebase'den gelen JSON'u Campaign nesnesine dönüştürme
  factory Campaign.fromMap(String id, Map<String, dynamic> map) {
    return Campaign(
      id: id,
      title: map['Title'] ?? '',
      description: map['Description'] ?? '',
      dateString: map['DateString'] ?? '',
    );
  }
}

class CartItem {
  final String name;
  final double price;
  final double rate;
  final String clients;
  final String image;
  int quantity; // Quantity değiştirilebilir

  CartItem({
    required this.name,
    required this.price,
    required this.rate,
    required this.clients,
    required this.image,
    this.quantity = 1, // Varsayılan değer 1
  });

  // JSON'dan Cart nesnesi oluşturma
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'] as String,
      price: double.parse(json['price']),
      rate: double.parse(json['rate']),
      clients: json['clients'],
      image: json['image'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  // Cart nesnesini JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price.toStringAsFixed(2),
      'rate': rate.toStringAsFixed(1),
      'clients': clients.toString(),
      'image': image,
      'quantity': quantity,
    };
  }
}

class Order {
  final String phone;
  final int price;
  final String date;
  final int points;

  Order({
    required this.phone,
    required this.price,
    required this.date,
    required this.points,
  });

  // Map'ten Order objesi oluşturma
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      phone: map['phone'] ?? '',
      price: map['price'] ?? 0.0,
      date: map['date'] ?? '',
      points: map['points'] ?? 0,
    );
  }

  // Order objesini Map formatına dönüştürme
  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'price': price,
      'date': date,
      'points': points,
    };
  }
}

class FoodOption {
  final String name;
  final String image;

  FoodOption({required this.name, required this.image});

  // Map'ten FoodOption objesi oluşturma
  factory FoodOption.fromMap(Map<String, dynamic> map) {
    return FoodOption(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
    );
  }
}

class User {
  final String password;
  final String phone;
  final String profilePic;
  final bool isGarson;
  final String name;
  final bool isAdmin;
  final bool isActive;
  final bool isNotification;
  final int point;

  User({
    required this.password,
    required this.phone,
    required this.isGarson,
    required this.name,
    required this.isAdmin,
    required this.isActive,
    required this.isNotification,
    required this.profilePic,
    required this.point,
  });

  // Firebase verisinden User objesi oluşturma
  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      password: map['password'] ?? '',
      profilePic: map['profilePic'] ?? '',
      phone: map['phone'] ?? '',
      isGarson: map['isGarson'] ?? false,
      name: map['name'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      isActive: map['isActive'] ?? false,
      isNotification: map['isNotification'] ?? false,
      point: map['point'] ?? 0,
    );
  }
}

class PopularFood {
  final String name;
  final String image;
  final String
      rating; // Örnek: yemeklerin puanı, popülerlik için kullanılabilir
  final String
      clients; // Örnek: yemeklerin puanı, popülerlik için kullanılabilir
  final String price; // Örnek: yemeklerin puanı, popülerlik için kullanılabilir
  final String
      description; // Örnek: yemeklerin puanı, popülerlik için kullanılabilir
  final String
      category; // Örnek: yemeklerin puanı, popülerlik için kullanılabilir

  PopularFood({
    required this.name,
    required this.image,
    required this.rating,
    required this.clients,
    required this.price,
    required this.description,
    required this.category,
  });

  // Map'ten PopularFood objesi oluşturma
  factory PopularFood.fromMap(Map<String, dynamic> map) {
    return PopularFood(
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      rating: map['rate'] ?? '',
      price: map['price'] ?? '',
      clients: map['clients'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
    );
  }
}

class QuizUser {
  final String userPhone;
  final String dateTime;
  final bool isTrue;

  QuizUser({
    required this.userPhone,
    required this.dateTime,
    required this.isTrue,
  });

  // Firebase verisini bu modele dönüştürmek için bir factory constructor
  factory QuizUser.fromMap(Map<dynamic, dynamic> map) {
    return QuizUser(
      userPhone: map['userPhone'] ?? '',
      dateTime: map['dateTime'] ?? '',
      isTrue: map['isTrue'] ?? false,
    );
  }
}

class Setting {
  final bool isCark;
  final bool isQuiz;
  final bool isAdBanner1;
  final bool isAdBanner2;
  final bool isStorie;
  final String Version;

  Setting({
    required this.isCark,
    required this.isQuiz,
    required this.isAdBanner1,
    required this.isAdBanner2,
    required this.Version,
    required this.isStorie,
  });

  // Firebase'den gelen veriyi sınıfa dönüştürmek için factory
  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      isCark: json['isCark'] ?? false,
      isQuiz: json['isQuiz'] ?? false,
      isStorie: json['isStorie'] ?? false,
      isAdBanner1: json['isAdBanner1'] ?? false,
      isAdBanner2: json['isAdBanner2'] ?? false,
      Version: json['Version'] ?? "",
    );
  }

  // Veriyi Firebase'e yazmak için Map'e dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'isCark': isCark,
      'isQuiz': isQuiz,
      'isAdBanner1': isAdBanner1,
      'isAdBanner2': isAdBanner2,
    };
  }
}
class Reservation {
  String? type; // Tür
  String? phone; // Telefon
  int? personCount; // Kişi Sayısı
  String? userId; // Kullanıcı ID

  Reservation({this.type, this.phone, this.personCount, this.userId});

  // JSON'a dönüştürme metodu
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'phone': phone,
      'personCount': personCount,
      'userId': userId,
    };
  }

  // JSON'dan Reservation nesnesine dönüştürme metodu
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      type: json['type'],
      phone: json['phone'],
      personCount: json['personCount'],
      userId: json['userId'],
    );
  }
}

class AdBanner {
  final String image;
  final int index;
  final String url;
  final String phone;

  AdBanner({
    required this.image,
    required this.index,
    required this.url,
    required this.phone,
  });

  // JSON'dan AdBanner nesnesi oluşturmak için factory constructor
  factory AdBanner.fromJson(Map<String, dynamic> json) {
    return AdBanner(
      image: json['Image'] ?? '',
      index: json['Index'] ?? 0,
      url: json['Url'] ?? '',
      phone: json['Phone'] ?? '',
    );
  }

  // AdBanner nesnesini JSON formatına dönüştürmek için toJson metodu
  Map<String, dynamic> toJson() {
    return {
      'Image': image,
      'Index': index,
      'Url': url,
      'Phone': phone,
    };
  }
}
class Story {
  final String thumbnail; // Küçük resim URL'si
  final String name;      // Hikaye adı
  final String image;     // Hikaye tam boy resim URL'si

  Story({
    required this.thumbnail,
    required this.name,
    required this.image,
  });

  // JSON'dan oluşturmak için bir factory metodu
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      thumbnail: json['thumbnail'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }

  // JSON'a dönüştürmek için bir metod
  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'name': name,
      'image': image,
    };
  }
}
