import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DairyScreen extends StatefulWidget {
  @override
  _DairyScreenState createState() => _DairyScreenState();
}

class _DairyScreenState extends State<DairyScreen> {
  late User? _user;
  late FirebaseFirestore _firestore;
  List<DocumentSnapshot> products = [];
  Set<String> favoriteProducts = <String>{};
  String selectedCategory = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _firestore = FirebaseFirestore.instance;
    _loadFavoriteProducts();
    _loadAllProducts();
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

  void _loadAllProducts() async {
    List<DocumentSnapshot> allProducts = [];
    List<String> categories = ['Cheddar Cheese', 'Greek Yogurt', 'Sliced Turkey', 'Butter', 'Fresh Mozzarella'];
    for (String category in categories) {
      QuerySnapshot categorySnapshot = await _firestore
          .collection('Products')
          .doc('Dairy')
          .collection(category)
          .get();
      allProducts.addAll(categorySnapshot.docs);
    }
    allProducts.sort((a, b) {
      String nameA = (a.data() as Map<String, dynamic>)['name'] ?? '';
      String nameB = (b.data() as Map<String, dynamic>)['name'] ?? '';
      return nameA.compareTo(nameB);
    });

    setState(() {
      products = allProducts;
    });
  }

  void _loadProductsByCategory(String category) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Products')
        .doc('Dairy')
        .collection(category)
        .get();
    List<DocumentSnapshot> sortedProducts = querySnapshot.docs;
    sortedProducts.sort((a, b) {
      String nameA = (a.data() as Map<String, dynamic>)['name'] ?? '';
      String nameB = (b.data() as Map<String, dynamic>)['name'] ?? '';
      return nameA.compareTo(nameB);
    });

    setState(() {
      products = sortedProducts;
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

  void _searchProducts(String query) {
    if (query.isEmpty) {
      if (selectedCategory.isEmpty) {
        _loadAllProducts();
      } else {
        _loadProductsByCategory(selectedCategory);
      }
    } else {
      setState(() {
        products = products.where((product) {
          return product['name'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _showProductModal(Map<String, dynamic> product, String category) {
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
              style: TextStyle(fontFamily: 'Poppins',color: Colors.green),
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
          'Dairy',
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                hintText: 'Search products...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
              onChanged: _searchProducts,
            ),
          ),

          // Category Chips with Padding
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              child: Row(
                children: ['Cheddar Cheese', 'Greek Yogurt', 'Sliced Turkey', 'Butter', 'Fresh Mozzarella']
                    .map((category) => _buildCategoryButton(category))
                    .toList(),
              ),
            ),
          ),


          // Products List
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final productDoc = products[index];
                final product = productDoc.data() as Map<String, dynamic>;
                final category = productDoc.reference.parent.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
                        icon: Icon(
                          favoriteProducts.contains(productDoc.id) ? Icons.favorite : Icons.favorite_border,
                          color: favoriteProducts.contains(productDoc.id) ? Colors.red : Colors.grey,
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
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green[700] : Colors.green[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {
          setState(() {
            if (selectedCategory == category) {
              selectedCategory = '';
              _loadAllProducts();
            } else {
              selectedCategory = category;
              _loadProductsByCategory(category);
            }
          });
        },
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
