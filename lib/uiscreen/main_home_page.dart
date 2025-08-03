import 'package:flutter/material.dart';
import 'package:project_sem7/uiscreen/ProfileUpdate.dart';
import 'package:project_sem7/uiscreen/liked_shops.dart';
import 'package:project_sem7/uiscreen/location_and_barber_shop.dart';
import 'package:project_sem7/uiscreen/notification.dart';
import 'package:project_sem7/uiscreen/settings.dart';
import 'my_booking_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: SizedBox(height: 50, width: 400,
            child: Container(
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.asset("assets/images/WhatsApp_Image_2025-07-11_at_20.05.12_409f80dc-removebg-preview.png"),
                  ),
                  SizedBox(width: 10,),
                  Text("The Barber" ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  SizedBox(width: 90,),
                  IconButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()));
                  }, icon: Icon(Icons.notifications)),
                  IconButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profileupdate()));
                  }, icon: Icon(Icons.account_circle))
                ],
              ),
            )
        ),
      ),
      body: Container(),
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
            items: [
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
