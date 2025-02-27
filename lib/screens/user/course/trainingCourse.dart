import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';
import 'package:semesta_gym/layout.dart';
import 'package:semesta_gym/models/course.dart';
import 'package:semesta_gym/models/trainingFocus.dart';
import 'package:http/http.dart' as http;
import 'package:semesta_gym/preferences/rememberUser.dart';
import 'package:semesta_gym/screens/user/course/courseScreen.dart';
import 'package:semesta_gym/screens/user/course/description.dart';

class TrainingCourseScreen extends StatefulWidget {
  const TrainingCourseScreen({super.key});

  @override
  State<TrainingCourseScreen> createState() => _TrainingCourseScreenState();
}

class _TrainingCourseScreenState extends State<TrainingCourseScreen> {
  final TrainingFocus trainingFocus = Get.arguments;
  List<Course> courses = [];
  bool isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchCoursesByTrainingFocus();
  }

  Future<void> fetchCoursesByTrainingFocus() async {
    String? token = await RememberUserPrefs.readAuthToken();
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/courses/data-course/training-focus/${trainingFocus.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(response.body);
        setState(() {
          courses = data.map((json) => Course.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", "Failed to load courses data");
    }
  }

  void _goToNextPage() {
    if (_currentPage < courses.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          courses.isEmpty ? "Latihan": "Latihan ${_currentPage + 1}/${courses.length}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? Center(
                  child: Text(
                    "Course belum tersedia",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: courses.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Column(
                      children: [
                        Image.network(
                          "http://10.0.2.2:3000/${course.picture}",
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported,
                                size: 100, color: Colors.grey);
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              course.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.to(() => DescriptionScreen(), arguments: course);
                              },
                              icon:
                                  Icon(Icons.question_mark_outlined, size: 22),
                            ),
                          ],
                        ),
                        Text(
                          "X ${course.numberOfPractices}",
                          style: TextStyle(
                            fontSize: 92,
                            fontWeight: FontWeight.bold,
                            color: Color(0xfff82ACEF),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        child: SizedBox(
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _goToPreviousPage,
                child: Transform.flip(
                  flipX: true,
                  child: Icon(
                    Icons.skip_next,
                    size: 40,
                    color: _currentPage > 0 ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_currentPage < courses.length - 1 || courses.isEmpty) {
                    null;
                  } else {
                    QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        title: "Selamat",
                        text:
                            "Anda telah menyelesaikan course!\nAnda juga masih bisa menggunakan course ini selama masa berlaku! ",
                        onConfirmBtnTap: () {
                          Get.offAll(() => Layout(index: 3,));
                        },
                        confirmBtnColor: Colors.blue);
                  }
                },
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(4, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _currentPage < courses.length - 1 || courses.isEmpty
                          ? "Semesta GYM"
                          : "Finish",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _goToNextPage,
                child: Icon(
                  Icons.skip_next,
                  size: 40,
                  color: _currentPage < courses.length - 1
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
