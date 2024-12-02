import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late User? _user;
  late FirebaseFirestore _firestore;
  List<DocumentSnapshot> products = [];
  Set<String> favoriteProducts = <String>{};

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _firestore = FirebaseFirestore.instance;
    _loadFavoriteProducts();
    _searchProducts(widget.query);
  }

  void _loadFavoriteProducts() async {
    if (_user != null) {
      DocumentSnapshot favoritesSnapshot = await _firestore
          .collection('Users')
          .doc(_user!.uid)
          .collection('Favorites')
          .doc('favorites')
          .get();
      if (favoritesSnapshot.exists) {
        setState(() {
          favoriteProducts = Set<String>.from(favoritesSnapshot['productIds']);
        });
      }
    }
  }

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      _loadAllProducts();
    } else {
      List<DocumentSnapshot> filteredProducts = [];

      Map<String, List<String>> subcategories = {
        'Beverages': ['Coffee', 'Green Tea', 'Sparkling Water', 'Orange Juice', 'Almond Milk'],
        'Canned': ['Black Beans', 'Tomato Paste', 'Coconut Milk', 'Tuna', 'Corn'],
        'Snacks': ['Pretzels', 'Trail Mix', 'Granola Bars', 'Popcorn', 'Dark Chocolate'],
        'Staples': ['Jasmine Rice', 'Spaghetti', 'Orzo', 'Basmati Rice', 'Penne'],
        'Dairy': ['Cheddar Cheese', 'Greek Yogurt', 'Sliced Turkey', 'Butter', 'Fresh Mozzarella'],
      };

      QuerySnapshot categoriesSnapshot = await _firestore.collection('Products').get();

      for (var categoryDoc in categoriesSnapshot.docs) {
        for (var subcategory in subcategories[categoryDoc.id]!) {
          QuerySnapshot productSnapshot = await _firestore
              .collection('Products')
              .doc(categoryDoc.id)
              .collection(subcategory)
              .get();

          for (var productDoc in productSnapshot.docs) {
            Map<String, dynamic> productData = productDoc.data() as Map<String, dynamic>;

            if (productData['name'].toString().toLowerCase().contains(query.toLowerCase())) {
              filteredProducts.add(productDoc);
            }
          }
        }
      }

      setState(() {
        products = filteredProducts;
      });
    }
  }


  void _loadAllProducts() async {
    List<DocumentSnapshot> allProducts = [];
    QuerySnapshot categoriesSnapshot = await _firestore.collection('Products').get();

    for (var categoryDoc in categoriesSnapshot.docs) {
      QuerySnapshot categorySnapshot = await _firestore
          .collection('Products')
          .doc(categoryDoc.id)
          .collection('items')
          .get();

      allProducts.addAll(categorySnapshot.docs);
    }

    setState(() {
      products = allProducts;
    });
  }

  void _toggleFavorite(String productId) {
    setState(() {
      if (favoriteProducts.contains(productId)) {
        favoriteProducts.remove(productId);
      } else {
        favoriteProducts.add(productId);
      }
    });
    _updateFavorites();
  }

  void _updateFavorites() {
    if (_user != null) {
      _firestore.collection('Users').doc(_user!.uid).collection('Favorites').doc('favorites').set({
        'productIds': favoriteProducts.toList(),
      });
    }
  }

  void _showProductModal(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: TextStyle(fontFamily: 'Poppins', color: Colors.green),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Search Results',
          style: TextStyle(
            fontFamily: 'YesevaOne',
            fontSize: 20,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final productDoc = products[index];
                final product = productDoc.data() as Map<String, dynamic>;
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
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              product['image'] ?? '',
                              fit: BoxFit.cover,
                            ),
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
                            product['description'] ?? '',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          favoriteProducts.contains(productDoc.id) ? Icons.favorite : Icons.favorite_border,
                          color: favoriteProducts.contains(productDoc.id) ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(productDoc.id),
                      ),
                      onTap: () => _showProductModal(product),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
