import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/auth/log_in.dart';
import 'screens/main_screens/home.dart';
import 'screens/main_screens/favorites.dart';
import 'screens/main_screens/profile.dart';
import 'screens/categories/beverages.dart';
import 'screens/categories/canned.dart';
import 'screens/categories/dairy.dart';
import 'screens/categories/snacks.dart';
import 'screens/categories/staples.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NutriWise',
          theme: ThemeData(primarySwatch: Colors.green),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final user = snapshot.data;
                if (user == null) {
                  return const LoginScreen();
                } else {
                  return const MainNavigation();
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const FavoritesScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });

      if (index == 1) {
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      }
    }
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Widget _buildCustomIcon({
    required bool isSelected,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isSelected ? 46.sp : 40.sp,
      width: isSelected ? 46.sp : 40.sp,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.transparent,
          width: 2.sp,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 6.sp,
            spreadRadius: 1.sp,
          ),
        ]
            : [],
      ),
      child: Center(
        child: FaIcon(
          icon,
          color: isSelected ? Colors.green : Colors.green.shade500,
          size: isSelected ? 22.sp : 20.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Navigator(
            key: _navigatorKeys[0],
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (context) => const FavoritesScreen(),
              );
            },
          ),
          Navigator(
            key: _navigatorKeys[1],
            onGenerateRoute: (routeSettings) {
              switch (routeSettings.name) {
                case '/beverages':
                  return MaterialPageRoute(
                    builder: (context) => const BeveragesScreen(),
                  );
                case '/canned':
                  return MaterialPageRoute(
                    builder: (context) => CannedScreen(),
                  );
                case '/dairy':
                  return MaterialPageRoute(
                    builder: (context) => DairyScreen(),
                  );
                case '/snacks':
                  return MaterialPageRoute(
                    builder: (context) => SnacksScreen(),
                  );
                case '/staples':
                  return MaterialPageRoute(
                    builder: (context) => StaplesScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  );
              }
            },
          ),
          Navigator(
            key: _navigatorKeys[2],
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Container(
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.green.shade700,
              width: 3.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _onItemTapped(0),
                child: _buildCustomIcon(
                  isSelected: _selectedIndex == 0,
                  icon: Icons.favorite,
                ),
              ),
              GestureDetector(
                onTap: () => _onItemTapped(1),
                child: _buildCustomIcon(
                  isSelected: _selectedIndex == 1,
                  icon: FontAwesomeIcons.home,
                ),
              ),
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: _buildCustomIcon(
                  isSelected: _selectedIndex == 2,
                  icon: FontAwesomeIcons.userAlt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
