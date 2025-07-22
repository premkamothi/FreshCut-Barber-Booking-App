import 'package:flutter/material.dart';
import 'package:project_sem7/uiscreen/settings.dart';
import 'liked_shops.dart';
import 'location_and_barber_shop.dart';
import 'main_home_page.dart';
import 'my_booking_page.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  Widget _buildIcon(int index, IconData iconData, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
          if (onTap != null) onTap();
        },
        child: Icon(
          iconData,
          color: selectedIndex == index ? Colors.red : Colors.grey[600],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            height: 60,
            width: 220,
            padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    //home
                    _buildIcon(0, Icons.home, onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainHomePage()),
                      );
                    }),

                    //my booking page
                    _buildIcon(1, Icons.calendar_today, onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MyBookingPage()),
                      );
                    }),

                    //location
                    _buildIcon(2, Icons.location_on, onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LocationAndBarberShop()),
                      );
                    }),

                    //liked shops
                    _buildIcon(3, Icons.favorite, onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LikedShops()),
                      );
                    }),

                    //settings
                    _buildIcon(4, Icons.settings, onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Settings()),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}