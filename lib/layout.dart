import 'package:flutter/material.dart';
import 'package:semesta_gym/screens/user/course/courseScreen.dart';
import 'package:semesta_gym/screens/user/homeScreen.dart';
import 'package:semesta_gym/screens/user/member/memberScreen.dart';
import 'package:semesta_gym/screens/user/profile/profileScreen.dart';
import 'package:semesta_gym/screens/user/schedule/scheduleScreen.dart';

class Layout extends StatefulWidget {
  final int index;

  const Layout(
      {super.key, this.index = 0});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const Schedulescreen(),
    const MemberScreen(),
    const CourseScreen(),
    const Profilescreen(),
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
        selectedItemColor: const Color(0xFFF68989),
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