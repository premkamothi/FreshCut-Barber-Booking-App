import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Services extends StatefulWidget {
  final String placeId;

  const Services({super.key, required this.placeId});

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

  List<Map<String, dynamic>> serviceList = [];

  @override
  void initState() {
    super.initState();
    _loadExistingServices();
  }

  Future<void> _loadExistingServices() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('ShopProfileDetails')
          .doc(widget.placeId)
          .get();

      if (doc.exists && doc.data()?['Services'] != null) {
        List<dynamic> saved = doc['Services'];

        Map<String, String> savedMap = {
          for (var e in saved) e['service'] as String: e['price'] as String
        };

        setState(() {
          serviceList = serviceOptions.map((service) {
            final price = savedMap[service];
            return {
              'service': service,
              'controller': TextEditingController(text: price),
            };
          }).toList();
        });
      } else {
        setState(() {
          serviceList = serviceOptions.map((service) {
            return {
              'service': service,
              'controller': TextEditingController(),
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> saveServicesToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      List<Map<String, dynamic>> validServices = serviceList
          .where((e) => e['controller'].text.isNotEmpty)
          .map((e) => {
        'service': e['service'],
        'price': e['controller'].text,
      })
          .toList();

      await FirebaseFirestore.instance
          .collection('ShopProfileDetails')
          .doc(widget.placeId)
          .set({
        'ownerUid': user.uid,
        'placeId': widget.placeId,
        'Services': validServices,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.pop(context);
    } catch (e) {
      print("Error saving services: $e");
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
                itemCount: serviceList.length,
                itemBuilder: (context, index) {
                  final serviceName = serviceList[index]['service'];
                  final controller = serviceList[index]['controller']
                  as TextEditingController;

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
                      padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                              controller: controller,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Price",
                                filled: true,
                                fillColor: Colors.grey[100],
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 12.w),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
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
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: saveServicesToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                child: Text(
                  "Submit",
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
      ),
    );
  }
}
