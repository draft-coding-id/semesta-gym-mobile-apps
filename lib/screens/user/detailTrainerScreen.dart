import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:semesta_gym/layout.dart';

class DetailTrainer extends StatefulWidget {
  const DetailTrainer({super.key});

  @override
  State<DetailTrainer> createState() => _DetailTrainerState();
}

class _DetailTrainerState extends State<DetailTrainer> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? trainer = Get.arguments;

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
                        image: NetworkImage("${trainer?['imageUrl']}"),
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
                        Get.back();
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
                                '${trainer?['name']}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              //Fokus
                              Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.fitness_center_rounded),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Fokus",
                                        style: TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    'WINGS, SHOULDER, LEG',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
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
                                    '086256xxxxxx',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
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
                                    '17.00 -21.00',
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
                      //Description
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "DESKRIPSI",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      "Number 1st Trainer paling kece dan jago dalam pembentukan otot sayap dan bahu, dan juga kaki")
                                ],
                              ),
                              SizedBox(
                                height: 32,
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF68989),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Review",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Session and price
                      Padding(
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
                                    "Rp. {price}",
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
                      )
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
                  onPressed: () {
                    // Action for purchase
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF68989),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Booking",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Action for booking
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Payment",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
