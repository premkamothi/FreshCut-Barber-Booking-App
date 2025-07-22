import 'package:flutter/material.dart';
import 'package:project_sem7/uiscreen/bottom_nav_bar.dart';
import 'package:project_sem7/uiscreen/settings.dart';
import 'package:provider/provider.dart';
import '../providers/liked_shops_provider.dart';
import '../models/barber_model.dart';
import 'location_and_barber_shop.dart';
import 'main_home_page.dart';
import 'my_booking_page.dart';

class LikedShops extends StatefulWidget {
  const LikedShops({super.key});

  @override
  State<LikedShops> createState() => _LikedShopsState();
}

class _LikedShopsState extends State<LikedShops> {
  int _selectedIndex = 3;

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
    final likedShops = context.watch<LikedShopsProvider>().likedShops;


    return Scaffold(
      appBar: AppBar(title: const Text("Liked Shops")),
      body: Column(
        children: [
          SizedBox(
            height: 475, // Horizontal list height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: likedShops.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final barber = likedShops[index];
                final isLiked = context.read<LikedShopsProvider>().isLiked(barber);

                return SizedBox(
                  width: 300,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.network(
                                  barber.imageUrl,
                                  height: 260,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 260,
                                    color: Colors.grey[300],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  context.read<LikedShopsProvider>().toggleLike(barber);
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                barber.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                barber.address,
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 22, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text('${barber.distanceKm.toStringAsFixed(1)} km',
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.star, size: 22, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(barber.rating.toString(), style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, indent: 16, endIndent: 16, height: 1),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextButton(
                            onPressed: () {
                              // Booking logic
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 116,),
          const BottomNavBar(initialIndex: 3),
        ],
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
