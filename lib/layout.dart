import 'package:flutter/material.dart';
import 'package:semesta_gym/screens/user/course/courseScreen.dart';
import 'package:semesta_gym/screens/user/homeScreen.dart';
import 'package:semesta_gym/screens/user/member/memberScreen.dart';
import 'package:semesta_gym/screens/user/profile/profileScreen.dart';
import 'package:semesta_gym/screens/user/schedule/scheduleScreen.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Schedulescreen(),
    const MemberScreen(),
    const CourseScreen(),
    const Profilescreen(),
  ];

  /*  void _onItemTapped(int index) {
    if (index == 3) {
      bool isExpired = _checkCourseExpired();
      if (isExpired) {
        _showAccessDeniedModal();
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  bool _checkCourseExpired() {
    DateTime now = DateTime.now();
    DateTime endDate = DateTime.parse("2025-02-18");
    return endDate.isBefore(now);
  }

  void _showAccessDeniedModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Access Denied"),
          content: const Text("Your course access has expired. Please renew."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  } */

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
        selectedItemColor: const Color(0xFFF68989),
        currentIndex: _currentIndex,
        /* onTap: _onItemTapped, */
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_gymnastics_sharp),
            label: 'Trainer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Member',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Course',
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


/* import 'package:flutter/material.dart';
import 'package:semesta_gym/screens/user/course/courseScreen.dart';
import 'package:semesta_gym/screens/user/homeScreen.dart';
import 'package:semesta_gym/screens/user/member/memberScreen.dart';
import 'package:semesta_gym/screens/user/profile/profileScreen.dart';
import 'package:semesta_gym/screens/user/schedule/scheduleScreen.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _currentIndex = 0;

  // List of screens for navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const Schedulescreen(),
    const MemberScreen(),
    const CourseScreen(),
    const Profilescreen()

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
            icon: Icon(Icons.sports_gymnastics_sharp),
            label: 'Trainer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Member',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Course',
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
 */