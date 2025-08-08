import 'package:flutter/material.dart';
import 'package:project_sem7/uiscreen/settings.dart';

import 'liked_shops.dart';
import 'location_and_barber_shop.dart';
import 'main_home_page.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Center(
        child: Text("My Booking page"),
      ),
    );
  }
}
