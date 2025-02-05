import 'package:flutter/material.dart';
import 'package:semesta_gym/screens/personalTrainer/homeScreen.dart';
import 'package:semesta_gym/screens/personalTrainer/profileScreen.dart';

class LayoutPt extends StatefulWidget {
  const LayoutPt({super.key});

  @override
  State<LayoutPt> createState() => _LayoutPtState();
}

class _LayoutPtState extends State<LayoutPt> {
  int _currentIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    const HomeScreenPt(),
    const ProfileScreenPt()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
         type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black,
        selectedItemColor: Color(0xFFF68989),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Member',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
