import 'package:flutter/material.dart';
import 'profile.dart';
import 'favorites.dart';
import 'settings.dart';
import '../utils/contact_us.dart';
import '../utils/log_out.dart';
import '../categories/beverages.dart';
import '../categories/snacks.dart';
import '../categories/dairy.dart';
import '../categories/staples.dart';
import '../categories/canned.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              icon: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'Profile':
                    _navigate(context, const ProfileScreen());
                    break;
                  case 'Favorites':
                    _navigate(context, const FavoritesScreen());
                    break;
                  case 'Settings':
                    _navigate(context, const SettingsScreen());
                    break;
                  case 'Contact Us':
                    _navigate(context, const ContactUsScreen());
                    break;
                  case 'Log Out':
                    _navigate(context, const LogOutScreen());
                    break;
                }
              },
              offset: const Offset(0, 50),
              itemBuilder: (context) => [
                _buildPopupMenuItem('Profile'),
                _buildPopupMenuItem('Favorites'),
                _buildPopupMenuItem('Settings'),
                _buildPopupMenuItem('Contact Us'),
                _buildPopupMenuItem('Log Out'),
              ],
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
                        height: 230,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Discover Healthier Grocery Alternatives',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Explore',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.normal,
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
            const SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.green),
                      onPressed: () {},
                    ),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search product',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.green),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryIcon(context, 'Beverages', 'assets/categories/Beverages/beverages.jpg', const BeveragesScreen()),
                    _buildCategoryIcon(context, 'Snacks', 'assets/categories/Snacks/snacks.jpg', const SnacksScreen()),
                    _buildCategoryIcon(context, 'Dairy', 'assets/categories/Dairy/dairy.jpg', const DairyScreen()),
                    _buildCategoryIcon(context, 'Staples', 'assets/categories/Staples/staples.jpg', const StaplesScreen()),
                    _buildCategoryIcon(context, 'Canned', 'assets/categories/Canned/canned.jpg', CannedScreen()),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle('Featured Products'),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProductItem('assets/apple.jpg', 'Product 1'),
                  _buildProductItem('assets/apple.jpg', 'Product 2'),
                  _buildProductItem('assets/apple.jpg', 'Product 3'),
                  _buildProductItem('assets/apple.jpg', 'Product 4'),
                ],
              ),
            ),
            const SizedBox(height: 3),
            _buildSectionTitle('Seasonal Recommendations'),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildProductItem('assets/apple.jpg', 'Seasonal 1'),
                  _buildProductItem('assets/apple.jpg', 'Seasonal 2'),
                  _buildProductItem('assets/apple.jpg', 'Seasonal 3'),
                  _buildProductItem('assets/apple.jpg', 'Seasonal 4'),
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
      case 'Settings':
        return Icons.settings;
      case 'Contact Us':
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
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(assetPath),
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(String imagePath, String label) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
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
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}
