import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'date_time_selection_page.dart';

class BookNowPage extends StatefulWidget {
  const BookNowPage({super.key});

  @override
  State<BookNowPage> createState() => _BookNowPageState();
}

class _BookNowPageState extends State<BookNowPage> {
  final List<Map<String, dynamic>> services = [
    {
      "name": "Haircut",
      "price": 100,
      "selected": false,
      "image": "image2.jpg"
    },
    {
      "name": "Shave",
      "price": 100,
      "selected": false,
      "image": "image3.jpg"
    },
    {
      "name": "Trim",
      "price": 150,
      "selected": false,
      "image": "image1.jpg"
    },
    {
      "name": "Facial",
      "price": 200,
      "selected": false,
      "image": "image2.jpg"
    },
    {
      "name": "Hair Spa",
      "price": 300,
      "selected": false,
      "image": "image3.jpg"
    },
  ];

  String _getImagePath(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return "assets/images/image1.jpg";
    }
    return "assets/images/$fileName";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Text("Our Services"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              padding: EdgeInsets.all(10.w),
              itemBuilder: (context, index) {
                final service = services[index];

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  child: Card(
                    color: const Color(0xFFFFFAF2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              _getImagePath(service["image"]),
                              height: 80.w,
                              width: 80.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 80.w,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(Icons.image_not_supported),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service["name"] ?? "Unknown Service",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "₹${service["price"] ?? 0}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              activeColor: Colors.orange,
                              value: service["selected"] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  service["selected"] = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            width: double.infinity,
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              onPressed: () {
                final selectedServices = services
                    .where((s) => s["selected"] == true)
                    .map((s) => {
                  "name": s["name"],
                  "price": s["price"],
                  "image": s["image"],
                })
                    .toList();

                print("DEBUG: Selected services before navigation: $selectedServices");

                if (selectedServices.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select at least one service"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DateTimeSelectionPage(
                        selectedServices: selectedServices,
                      ),
                    ),
                  );
                } catch (e) {
                  print("ERROR during navigation: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Navigation error occurred"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "Apply",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}