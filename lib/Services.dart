import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_sem7/shop_profile/shop_profile.dart';
import 'package:project_sem7/uiscreen/DashboardScreen.dart';
import 'package:project_sem7/uiscreen/barber_card_list.dart';

import 'models/barber_model.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  final List<String> serviceOptions = [
    'Haircut',
    'Shave',
    'Trim',
    'Facial',
    'Hair Color',
    'Hair Spa',
  ];

  late final List<BarberModel> barbers;

  List<Map<String, String?>> serviceList = [
    {'service': null, 'price': null},
  ];

  Future<void> saveServicesToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      List<Map<String, String>> validServices = serviceList
          .where((element) =>
      (element['service'] != null && element['price'] != null))
          .map((e) => {
        'service': e['service']!,
        'price': e['price']!,
      })
          .toList();

      await FirebaseFirestore.instance
          .collection('BarberShops')
          .doc(user.uid)
          .set({
        'Services': validServices,
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Dashboardscreen()));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Set Your Services"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: serviceOptions.length,
                itemBuilder: (context, index) {
                  String serviceName = serviceOptions[index];

                  if (serviceList.length <= index) {
                    serviceList.add({'service': serviceName, 'price': null});
                  } else {
                    serviceList[index]['service'] = serviceName;
                  }

                  IconData serviceIcon;

                  switch (serviceName) {
                    case 'Haircut':
                      serviceIcon = Icons.content_cut;
                      break;
                    case 'Shave':
                      serviceIcon = Icons.face;
                      break;
                    case 'Trim':
                      serviceIcon = Icons.cut;
                      break;
                    case 'Facial':
                      serviceIcon = Icons.spa;
                      break;
                    case 'Hair Color':
                      serviceIcon = Icons.color_lens;
                      break;
                    case 'Hair Spa':
                      serviceIcon = Icons.water_drop;
                      break;
                    default:
                      serviceIcon = Icons.build;
                  }

                  return Card(
                    elevation: 3,
                    shadowColor: Colors.orange.withOpacity(0.2),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            child: Icon(serviceIcon,
                                color: Colors.orange, size: 24.sp),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              serviceName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100.w,
                            child: TextFormField(
                              initialValue: serviceList[index]['price'],
                              onChanged: (value) {
                                serviceList[index]['price'] =
                                value.isEmpty ? null : value;
                              },
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Price",
                                filled: true,
                                fillColor: Colors.grey[100],
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 12.w),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.orange, width: 1.5),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: saveServicesToFirestore,
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
