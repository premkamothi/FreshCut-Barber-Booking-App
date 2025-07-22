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
  int _selectedIndex = 1;

  void _onNavTap(int index){
    setState(() {
      _selectedIndex = index;
    });

    if(index == 0){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainHomePage()));
    }else if(index == 1){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyBookingPage()));
    }else if(index == 2){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LocationAndBarberShop()));
    }else if(index == 3){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LikedShops()));
    }else if(index == 4){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Settings()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Center(
        child: Text("My Booking page"),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -3), // ⬅️ Shadow appears at the top side
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.black,
            onTap: _onNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Booked"),
              BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Near shop"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Liked shop"),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
            ],
          ),
        ),
      ),
    );
  }
}
