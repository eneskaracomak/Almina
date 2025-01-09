import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_bit_app/app/components/FirebaseService.dart';
class NearBy extends StatefulWidget {
  @override
  _NearByState createState() => _NearByState();
}

class _NearByState extends State<NearBy> {
  final FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: Text(
            'Liderlik Sıralaması',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: DefaultTabController(
            length: 2, // 2 sekme olacak
            child: Column(
              children: [
                TabBar(
                  indicatorColor: theme.primaryColor,
                  tabs: [
                    Tab(text: 'Puan Sıralaması'),
                    Tab(text: 'Ziyaret Sıralaması'),
                  ],
                ),
                SizedBox(height: 10.0),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Puan sıralaması sekmesi
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: firebaseService.getLeaderboardData(),
                        builder: (context, snapshot) {
                          return _buildLeaderboardTab(snapshot, 'score');
                        },
                      ),
                      // Ziyaret sıralaması sekmesi
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: firebaseService.getLeaderboardDataLocation(),
                        builder: (context, snapshot) {
                          return _buildLeaderboardTab(snapshot, 'cafeVisits');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(
    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
    String sortBy,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
    } else if (snapshot.hasData) {
      var leaderboardData = snapshot.data!;
      return SingleChildScrollView(
        child: _buildLeaderboardSection('Liderlik Sıralaması', leaderboardData, sortBy),
      );
    } else {
      return Center(child: Text('Veri bulunamadı.'));
    }
  }

  Widget _buildLeaderboardSection(String title, List<Map<String, dynamic>> leaderboardData, String sortBy) {
    leaderboardData.sort((a, b) {
      var aValue = a[sortBy] ?? 0;
      var bValue = b[sortBy] ?? 0;
      return bValue.compareTo(aValue);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: leaderboardData.length,
      itemBuilder: (context, index) {
        final data = leaderboardData[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: 15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28.0,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(data['image']),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data['name'],
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '#${data['rank']} | ${sortBy == 'score' ? 'Puan' : 'Ziyaret'}: ${data[sortBy]}',
                        style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (data['rank'] <= 3)
                  Icon(
                    Icons.star,
                    color: _getRankColor(data['rank']),
                    size: 24.0,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) {
      return Colors.amber;
    } else if (rank == 2) {
      return Colors.grey;
    } else if (rank == 3) {
      return Colors.brown;
    } else {
      return Colors.black;
    }
  }
}
