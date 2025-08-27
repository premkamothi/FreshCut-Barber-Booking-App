import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopPreview extends StatefulWidget {
  final String uid;

  const ShopPreview({super.key, required this.uid});

  @override
  State<ShopPreview> createState() => _ShopPreviewState();
}

class _ShopPreviewState extends State<ShopPreview> {
  final lightOrange = const Color(0xFFFFFAF2);
  final orange = Colors.orangeAccent;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Map<String, dynamic>? shopData;
  bool isLoading = true;

  // 🔹 Variables to hold extracted shop data
  String shopName = "";
  String website = "";
  String about = "";
  String shopAddress = "";
  List<Map<String, dynamic>> services = [];
  String primaryContact = "";
  List<String> additionalContacts = [];
  String monFriStart = "";
  String monFriEnd = "";
  String satSunStart = "";
  String satSunEnd = "";

  // Dummy values
  final List<String> _shopImages = [
    "assets/images/image1.jpg",
    "assets/images/image2.jpg",
    "assets/images/image3.jpg",
  ];

  final double distanceKm = 2.5;
  final double rating = 4.5;

  @override
  void initState() {
    super.initState();
    fetchShopData();
  }

  Future<void> fetchShopData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("ShopProfileDetails")
          .where("ownerUid", isEqualTo: widget.uid)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        setState(() {
          shopData = data;
          shopName = data["shopName"] ?? "";
          website = data["websiteLink"] ?? "";
          about = data["aboutShop"] ?? "";
          shopAddress = data["shopAddress"] ?? "";

          if (data["Services"] != null) {
            services = List<Map<String, dynamic>>.from(data["Services"]);
          } else {
            services = [];
          }


          primaryContact = data["primaryContactNumber"] ?? "";
          additionalContacts = List<String>.from(data["additionalContactNumbers"] ?? []);
          monFriStart = data["monFriStart"] ?? "";
          monFriEnd = data["monFriEnd"] ?? "";
          satSunStart = data["satSunStart"] ?? "";
          satSunEnd = data["satSunEnd"] ?? "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching shop: $e");
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (shopData == null) {
      return const Scaffold(
        body: Center(child: Text("Shop data not found")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Image carousel
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
                            for (String imageUrl in _shopImages)
                              _buildImageCard(imageUrl),
                          ],
                        ),
                        Positioned(
                          bottom: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _shopImages.length,
                                  (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: _currentPage == index ? 20 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? Colors.orangeAccent
                                      : Colors.grey[400],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Shop Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Location
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.location_on,
                              color: Colors.orangeAccent),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            shopAddress,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🔹 Distance
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_walk,
                            color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "$distanceKm km away",
                          style:
                          TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🔹 Ratings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "$rating",
                          style:
                          TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 🔹 Services Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceCircle(Icons.language, "Website", () {}),
                        _buildServiceCircle(Icons.design_services, "Services",
                                () => _showServicesBottomSheet(context)),
                        _buildServiceCircle(Icons.call, "Call",
                                () => _showContactBottomSheet(context)),
                        _buildServiceCircle(Icons.directions, "Direction", () {
                          // Static dummy action
                        }),
                        _buildServiceCircle(Icons.info, "About Us",
                                () => _showAboutBottomSheet(context)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(color: Colors.grey[200]),
                  ),

                  const SizedBox(height: 8),

                  // 🔹 Working Hours
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Working Hours",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            Text(
                              "Mon - Fri: $monFriStart - $monFriEnd",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.orangeAccent),
                            const SizedBox(width: 8),
                            Text(
                              "Sat - Sun: $satSunStart - $satSunEnd",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Specialists
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Helper Widgets
  Widget _buildImageCard(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: Image.asset(
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
            decoration: BoxDecoration(color: lightOrange, shape: BoxShape.circle),
            child: Icon(icon, color: orange, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
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

  // 🔹 Bottom Sheets
  void _showAboutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Text("About $shopName",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(about,
                  style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
        );
      },
    );
  }

  void _showServicesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        if (services.isEmpty) {
          return const SizedBox(
              height: 200, child: Center(child: Text("Services not available")));
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10)),
              ),
              const Text("Available Services",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final name = service["service"] ?? "Service not available";
                    final price = service["price"] ?? "N/A";

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.design_services, color: Colors.orange),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          "₹$price",
                          style: const TextStyle(
                              color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              )

            ],
          ),
        );
      },
    );
  }

  void _showContactBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          if (primaryContact.isEmpty && additionalContacts.isEmpty) {
            return const SizedBox(
                height: 200,
                child: Center(child: Text("Contact numbers not available")));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10)),
                ),
                const Text("Contact Numbers",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (primaryContact.isNotEmpty)
                        ListTile(
                          leading:
                          const Icon(Icons.phone, color: Colors.orange),
                          title: Text(primaryContact),
                        ),
                      ...additionalContacts.map((number) => ListTile(
                        leading:
                        const Icon(Icons.phone, color: Colors.orange),
                        title: Text(number),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
          },
        );
    }
}
