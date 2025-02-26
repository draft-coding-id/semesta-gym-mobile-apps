import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:semesta_gym/models/booking.dart';
import 'package:semesta_gym/screens/user/notification/notificationScreen.dart';

class PayBookingScreen extends StatefulWidget {
  const PayBookingScreen({super.key});

  @override
  State<PayBookingScreen> createState() => _PayBookingScreenState();
}

class _PayBookingScreenState extends State<PayBookingScreen> {
  final Booking booking = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 260,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    background: ClipRRect(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "http://10.0.2.2:3000/${booking.trainer.picture}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )),
                backgroundColor:
                    innerBoxIsScrolled ? Colors.white : Colors.transparent,
                elevation: innerBoxIsScrolled ? 4 : 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: innerBoxIsScrolled
                          ? Colors.transparent
                          : Color.fromARGB(50, 0, 0, 0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: innerBoxIsScrolled ? Colors.black : Colors.white,
                      ),
                      onPressed: () {
                        Get.off(() => NotificationScreen());
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      //PT
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${booking.trainer.name}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              // No. hp
                              Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.phone),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "No. Handphone",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    booking.trainer.phone,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              // Jadwal
                              Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.schedule),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Jadwal",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    booking.trainer.hoursOfPractice,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),

                      //Session and price
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1))),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "1 Bulan",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "4 Session",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                width: 301,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: Offset(4, 6),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
                                  child: Center(
                                    child: Text(
                                      "Rp. ${NumberFormat('#,###').format(booking.trainer.price)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Jadwal booking", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                SizedBox(height: 12,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(4, (index) {
                                    final weekNames = [
                                      "Minggu 1",
                                      "Minggu 2",
                                      "Minggu 3",
                                      "Minggu 4"
                                    ];
                                    final weekDates = [
                                      booking.week1Date,
                                      booking.week2Date,
                                      booking.week3Date,
                                      booking.week4Date
                                    ];
                                                          
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          weekNames[index],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Color(0xFF9747FF),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: Offset(4, 6),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 12),
                                            child: Text(
                                              DateFormat('dd-MM-yyyy')
                                                  .format(weekDates[index]),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ])),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 32),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF68989),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
