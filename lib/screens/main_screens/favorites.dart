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

            favoriteProductIds =
            List<String>.from(favoritesSnapshot['productIds'] ?? []);
            print('Extracted favoriteProductIds: $favoriteProductIds');

            if (favoriteProductIds.isNotEmpty) {
              List<String> categories = [
                'Beverages',
                'Snacks',
                'Dairy',
                'Staples',
                'Canned',
              ];

              List<Future<QuerySnapshot>> categoryFutures = [];
              for (String category in categories) {
                Map<String, List<String>> subcategories = {
                  'Beverages': [
                    'Coffee',
                    'Green Tea',
                    'Sparkling Water',
                    'Orange Juice',
                    'Almond Milk'
                  ],
                  'Canned': [
                    'Black Beans',
                    'Tomato Paste',
                    'Coconut Milk',
                    'Tuna',
                    'Corn'
                  ],
                  'Snacks': [
                    'Pretzels',
                    'Trail Mix',
                    'Granola Bars',
                    'Popcorn',
                    'Dark Chocolate'
                  ],
                  'Staples': [
                    'Jasmine Rice',
                    'Spaghetti',
                    'Orzo',
                    'Basmati Rice',
                    'Penne'
                  ],
                  'Dairy': [
                    'Cheddar Cheese',
                    'Greek Yogurt',
                    'Sliced Turkey',
                    'Butter',
                    'Fresh Mozzarella'
                  ],
                };

                for (String subcategory in subcategories[category]!) {
                  categoryFutures.add(
                    _firestore
                        .collection('Products')
                        .doc(category)
                        .collection(subcategory)
                        .where(
                        FieldPath.documentId, whereIn: favoriteProductIds)
                        .get(),
                  );
                }
              }

              List<QuerySnapshot> allFavoriteProductSnapshots = await Future
                  .wait(categoryFutures);

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

  void _toggleFavorite(String productId) {
    setState(() {
      favoriteProductIds.remove(productId);
      favoriteProducts.removeWhere((product) => product.id == productId);
    });

    if (_user != null) {
      _firestore.collection('Users').doc(_user!.uid)
          .collection('Favorites')
          .doc('favorites')
          .set({
        'productIds': favoriteProductIds,
      });
    }
  }

  void _showProductModal(Map<String, dynamic> product, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          product['name'] ?? '',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product['image'],
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Category: $category',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['longerDescription'] ?? 'No detailed description available.',
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
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
      body: Container(
        color: Colors.white,
        child: favoriteProducts.isEmpty
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 4.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 16.0),
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
                        style: const TextStyle(fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () => _toggleFavorite(productDoc.id),
                  ),
                  onTap: () => _showProductModal(product, category),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}