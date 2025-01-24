import 'package:flutter/material.dart';

class Schedulescreen extends StatefulWidget {
  const Schedulescreen({super.key});

  @override
  State<Schedulescreen> createState() => _SchedulescreenState();
}

class _SchedulescreenState extends State<Schedulescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jadwal Trainer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Center(
        child: Text("Jadwal"),
      ),
    );
  }
}
