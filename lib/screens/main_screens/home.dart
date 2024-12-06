import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';
import 'favorites.dart';
import '../utils/about_us.dart';
import '../auth/log_in.dart';
import '../categories/beverages.dart';
import '../categories/snacks.dart';
import '../categories/dairy.dart';
import '../categories/staples.dart';
import '../categories/canned.dart';
import 'search.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirm Log Out',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                } catch (e) {
                  print("Error during logout: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'Smart Swap',
              style: TextStyle(
                fontFamily: 'YesevaOne',
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  );
                }

                var userDocument = snapshot.data!;
                String profileImageUrl = userDocument['profileImage'] ?? 'assets/profile.jpg';

                return GestureDetector(
                  onTap: () {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    Offset offset = renderBox.localToGlobal(Offset.zero);

                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + renderBox.size.height,
                        0,
                        0,
                      ),
                      items: [
                        PopupMenuItem<String>(
                          value: 'Profile',
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.green),
                              const SizedBox(width: 10),
                              Text('Profile'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Favorites',
                          child: Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.green),
                              const SizedBox(width: 10),
                              Text('Favorites'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'About Us',
                          child: Row(
                            children: [
                              Icon(Icons.contact_mail, color: Colors.green),
                              const SizedBox(width: 10),
                              Text('About Us'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Log Out',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.green),
                              const SizedBox(width: 10),
                              Text('Log Out'),
                            ],
                          ),
                        ),
                      ],
                      elevation: 8.0,
                    ).then((value) {
                      if (value != null) {
                        switch (value) {
                          case 'Profile':
                            _navigate(context, const ProfileScreen());
                            break;
                          case 'Favorites':
                            _navigate(context, const FavoritesScreen());
                            break;
                          case 'About Us':
                            _navigate(context, const AboutUsScreen());
                            break;
                          case 'Log Out':
                            _showLogOutDialog(context);
                            break;
                        }
                      }
                    });
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: profileImageUrl.startsWith('http')
                        ? NetworkImage(profileImageUrl)
                        : AssetImage(profileImageUrl) as ImageProvider,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade300, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/banner.jpg',
                        width: double.infinity,
                        height: 155,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 155,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 20,
                      right: 20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'NutriWise',
                                  style: TextStyle(
                                    fontFamily: 'YesevaOne',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Discover Healthier Grocery Alternatives',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(100, 30),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              child: const Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 1.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search product...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: Colors.green),
                          onPressed: () {
                            if (searchController.text.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchScreen(query: searchController.text),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center (
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryIcon(context, 'Beverages', 'assets/categories/Beverages/beverages.jpg', const BeveragesScreen()),
                      _buildCategoryIcon(context, 'Snacks', 'assets/categories/Snacks/snacks.jpg', SnacksScreen()),
                      _buildCategoryIcon(context, 'Dairy', 'assets/categories/Dairy/dairy.jpg', DairyScreen()),
                      _buildCategoryIcon(context, 'Staples', 'assets/categories/Staples/staples.jpg', StaplesScreen()),
                      _buildCategoryIcon(context, 'Canned', 'assets/categories/Canned/canned.jpg', CannedScreen()),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: Column(
                children: [
                  _buildSectionTitle('Featured Products'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProductItem(context, 'assets/featured/bulletproof.jpg', 'Bulletproof', 'Coffee', 'A unique blend of high-quality coffee, MCT oil, and grass-fed butter, Bulletproof Coffee offers sustained energy and enhanced focus without the mid-day crash. Known as a staple for keto enthusiasts, it supports cognitive function and can serve as a satisfying breakfast replacement.'),
                      _buildProductItem(context, 'assets/featured/rxbar.jpeg', 'RXBAR', 'Dark Chocolate', 'Made with real, simple ingredients like egg whites, dates, and almonds, RXBAR delivers a rich dark chocolate flavor with no added sugar. Packed with protein and fiber, it’s a clean, guilt-free snack perfect for on-the-go energy.'),
                      _buildProductItem(context, 'assets/featured/blackbean.jpg', 'Black Bean', 'Spaghetti', 'Crafted from 100% organic black beans, this gluten-free spaghetti is high in protein and fiber. With a firm texture and nutty flavor, it’s a healthy twist on pasta dishes, ideal for those seeking plant-based alternatives.'),
                      _buildProductItem(context, 'assets/featured/beehive.jpg', 'Beehive', 'Cheddar Cheese', 'Beehive cheddar is a creamy, artisan cheese made with milk from pasture-raised cows and aged to develop rich, unique flavors. Known for its sustainable practices, it offers creative twists like espresso-infused varieties, making it a standout choice for both taste and quality.'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Seasonal Recommendations'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProductItem(context, 'assets/seasonal/califia.png', 'Califia', 'Almond Milk', 'This creamy, dairy-free almond milk is unsweetened, making it a perfect choice for smoothies, coffee, or cereal. With a simple ingredient list, it’s a healthy, low-calorie alternative to traditional milk.'),
                      _buildProductItem(context, 'assets/seasonal/naturebox.jpg', 'Nature Box', 'Trail Mix', 'A delightful mix of nuts, seeds, and dried fruits, this trail mix balances taste and nutrition. It’s perfect for snacking or fueling outdoor adventures, providing natural energy without artificial additives.'),
                      _buildProductItem(context, 'assets/seasonal/tolerant.jpg', 'Tolerant', 'Penne', 'Made from a single ingredient—red lentils—this pasta is a protein-packed, gluten-free option. With its firm bite and mild flavor, it pairs beautifully with any sauce, offering a nutritious twist to traditional penne.'),
                      _buildProductItem(context, 'assets/seasonal/siggis.jpg', 'Siggis', 'Yogurt', 'Crafted with simple ingredients, Siggi’s Icelandic-style yogurt is rich and creamy yet low in sugar. It’s packed with protein, making it a wholesome and satisfying snack or breakfast choice.'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String text) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(
            _getMenuIcon(text),
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMenuIcon(String text) {
    switch (text) {
      case 'Profile':
        return Icons.person;
      case 'Favorites':
        return Icons.favorite;
      case 'About Us':
        return Icons.contact_mail;
      case 'Log Out':
        return Icons.logout;
      default:
        return Icons.help;
    }
  }

  Widget _buildCategoryIcon(BuildContext context, String label, String assetPath, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(assetPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, String imagePath, String label, String category, String longDescription) {
    return GestureDetector(
      onTap: () {
        _showProductDialog(context, imagePath, label, category, longDescription);
      },
      child: Container(
        width: 74,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 74,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

void _showProductDialog(BuildContext context, String imagePath, String name, String category, String longDescription) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Category: $category',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    longDescription,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

