import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late User? _user;
  late FirebaseFirestore _firestore;
  List<DocumentSnapshot> favoriteProducts = [];
  List<String> favoriteProductIds = [];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _firestore = FirebaseFirestore.instance;
    _loadFavoriteProducts();
  }

  void _loadFavoriteProducts() {
    if (_user != null) {
      try {
        print('Listening for changes in favorites for user: ${_user!.uid}');

        _firestore
            .collection('Users')
            .doc(_user!.uid)
            .collection('Favorites')
            .doc('favorites')
            .snapshots()
            .listen((favoritesSnapshot) async {
          if (favoritesSnapshot.exists) {
            print('Favorites document data: ${favoritesSnapshot.data()}');

            // Extract favorite product IDs from the snapshot
            favoriteProductIds = List<String>.from(favoritesSnapshot['productIds'] ?? []);
            print('Extracted favoriteProductIds: $favoriteProductIds');

            if (favoriteProductIds.isNotEmpty) {
              List<String> categories = [
                'Beverages',
                'Snacks',
                'Dairy',
                'Staples',
                'Canned',
                'Spices'
              ];

              List<Future<QuerySnapshot>> categoryFutures = [];
              for (String category in categories) {
                Map<String, List<String>> subcategories = {
                  'Beverages': ['Coffee', 'Green tea', 'Sparkling water', 'Orange juice', 'Almond Milk'],
                  'Canned': ['Black beans', 'Tomato paste', 'Coconut milk', 'Tuna', 'Corn'],
                  'Snacks': ['Pretzels', 'Trail mix', 'Granola bars', 'Popcorn', 'Dark chocolate'],
                  'Staples': ['Jasmine rice', 'Spaghetti', 'Orzo', 'Basmati rice', 'Penne'],
                  'Dairy': ['Cheddar cheese', 'Greek yogurt', 'Sliced turkey', 'Butter', 'Fresh mozzarella'],
                  'Spices': ['Salt', 'Pepper', 'Chili powder', 'Garlic powder', 'Oregano']
                };

                for (String subcategory in subcategories[category]!) {
                  categoryFutures.add(
                    _firestore
                        .collection('Products')
                        .doc(category)
                        .collection(subcategory)
                        .where(FieldPath.documentId, whereIn: favoriteProductIds)
                        .get(),
                  );
                }
              }

              List<QuerySnapshot> allFavoriteProductSnapshots = await Future.wait(categoryFutures);

              List<QueryDocumentSnapshot> allFavoriteProducts = [];
              for (var snapshot in allFavoriteProductSnapshots) {
                allFavoriteProducts.addAll(snapshot.docs);
              }

              setState(() {
                favoriteProducts = allFavoriteProducts;
              });
            } else {
              print('No product IDs found in favorites.');
              setState(() {
                favoriteProducts = [];
              });
            }
          } else {
            print('Favorites document does not exist.');
            setState(() {
              favoriteProducts = [];
            });
          }
        });
      } catch (e) {
        print('Error fetching favorite products: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontFamily: 'YesevaOne',
            fontSize: 20,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: favoriteProducts.isEmpty
          ? Center(
        child: Text(
          'No favorites added yet.',
          style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
        ),
      )
          : ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final productDoc = favoriteProducts[index];
          final product = productDoc.data() as Map<String, dynamic>;
          final category = productDoc.reference.parent.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product['image'] ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  product['name'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: $category',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product['description'] ?? '',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    //
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
