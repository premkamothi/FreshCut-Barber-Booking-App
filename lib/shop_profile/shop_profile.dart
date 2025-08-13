import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:project_sem7/booking/book_now_page.dart';
import '../Services.dart';
import '../models/barber_model.dart';

class ShopProfile extends StatefulWidget {
  final BarberModel? barberData;

  const ShopProfile({super.key, this.barberData});

  @override
  State<ShopProfile> createState() => _ShopProfileState();
}

class _ShopProfileState extends State<ShopProfile> {
  final lightOrange = const Color(0xFFFFFAF2);
  final orange = Colors.orangeAccent;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final String monToFriHours = "10:00 AM - 8:00 PM";
  final String satToSunHours = "9:00 AM - 6:00 PM";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image carousel
                  SizedBox(
                    height: 256,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [
                            _buildImageCard(widget.barberData?.imageUrl ?? 'assets/images/image1.jpg'),
                            _buildImageCard('assets/images/image2.jpg'),
                            _buildImageCard('assets/images/image3.jpg'),
                          ],
                        ),
                        Positioned(
                          bottom: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: _currentPage == index ? 20 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index ? Colors.orangeAccent : Colors.grey[400],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Shop Name
                  Padding(
                    padding: const EdgeInsets.only(right: 12, left: 12),
                    child: Text(
                      widget.barberData?.name ?? "The Barber",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Location
                  Padding(
                    padding: const EdgeInsets.only(right: 12, left: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.orangeAccent),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.barberData?.address ?? "123 Main Street, City",
                            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Distance (only show if barberData exists)
                  if (widget.barberData != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 12, left: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_walk, color: Colors.orangeAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "${widget.barberData!.distanceKm.toStringAsFixed(1)} km away",
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Ratings
                  Padding(
                    padding: const EdgeInsets.only(right: 12, left: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${widget.barberData?.rating ?? 5.0} (120 reviews)",
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                        const Spacer(),
                        // Open/Closed Status (only show if barberData exists)
                        if (widget.barberData != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.barberData!.openNow ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.barberData!.openNow ? "Open Now" : "Closed",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceCircle(Icons.language, "Website", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Services()));
                        }),
                        _buildServiceCircle(Icons.design_services, "Services", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Services()));
                        }),
                        _buildServiceCircle(Icons.call, "Call", () {
                          // Example: launch a phone call (use url_launcher package)
                        }),
                        _buildServiceCircle(Icons.directions, "Direction", () {
                          // Open Google Maps with coordinates (only if barberData exists)
                          if (widget.barberData != null) {
                            _openGoogleMaps(widget.barberData!.lat, widget.barberData!.lng);
                          }
                        }),
                        _buildServiceCircle(Icons.info, "About Us", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Services()));
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Padding(
                    padding: const EdgeInsets.only(right: 12, left: 12),
                    child: Divider(color: Colors.grey[200]),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.only(right: 12, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Working Hours",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            Text(
                              "Mon - Fri: $monToFriHours",
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            Text(
                              "Sat - Sun: $satToSunHours",
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Our Specialist title
                  Padding(
                    padding: const EdgeInsets.only(top: 16, right: 12, left: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Our Specialists",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Horizontal scrollable small cards
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        _buildSpecialistCard("assets/images/image1.jpg", "John Doe", "Sr. Barber"),
                        _buildSpecialistCard("assets/images/image3.jpg", "Mike Trim", "Sr. Barber"),
                        _buildSpecialistCard("assets/images/image2.jpg", "Alex Fade", "Jr. Barber"),
                        _buildSpecialistCard("assets/images/image1.jpg", "Alex Fade", "Jr. Barber"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // Book Now Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: imageUrl.startsWith('http')
          ? Image.network(
        imageUrl,
        width: MediaQuery.of(context).size.width,
        height: 256,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 256,
            color: Colors.grey[200],
            child: const Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            ),
          );
        },
      )
          : Image.asset(
        imageUrl,
        width: MediaQuery.of(context).size.width,
        height: 256,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildServiceCircle(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: orange, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistCard(String imagePath, String name, String role) {
    return Container(
      width: 110,
      height: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: lightOrange,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(double lat, double lng) {
    // You can implement opening Google Maps here
    // For example, using url_launcher package:
    // final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    // launch(url);
    print('Opening Google Maps for coordinates: $lat, $lng');
  }
}