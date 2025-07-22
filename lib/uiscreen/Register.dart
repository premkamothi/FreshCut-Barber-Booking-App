import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_sem7/uiscreen/DashboardScreen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mobileController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? shopName;
  String? shopAddress;
  String? uid;
  bool isLoading = false;
  List<XFile> selectedImages = [];

  final String imageKitUploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
  final String imageKitPrivateKey = 'private_pWr6GTcSorJB7LBrowYhFUndHG0=';

  @override
  void initState() {
    super.initState();
    loadShopDetails();
  }

  Future<void> loadShopDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    uid = user.uid;

    final doc = await FirebaseFirestore.instance.collection('BarberShops').doc(uid).get();
    if (doc.exists) {
      setState(() {
        shopName = doc['name'];
        shopAddress = doc['address'];
      });
    }
  }

  Future<List<String>> uploadImagesToImageKit() async {
    List<String> uploadedUrls = [];
    for (XFile image in selectedImages) {
      File file = File(image.path);
      var request = http.MultipartRequest('POST', Uri.parse(imageKitUploadUrl));
      request.headers['Authorization'] =
      'Basic ${base64Encode(utf8.encode('$imageKitPrivateKey:'))}';
      request.fields['fileName'] = file.path.split('/').last;
      request.fields['useUniqueFileName'] = 'true';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      try {
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final decoded = json.decode(responseData);

        if (response.statusCode == 200) {
          uploadedUrls.add(decoded['url']);
        } else {
          debugPrint("Upload failed: ${decoded['message']}");
        }
      } catch (e) {
        debugPrint("ImageKit upload error: $e");
      }
    }
    return uploadedUrls;
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (uid == null) return;

    setState(() => isLoading = true);
    try {
      final imageUrls = await uploadImagesToImageKit();

      await FirebaseFirestore.instance.collection('BarberShops').doc(uid).update({
        'mobile': mobileController.text,
        'images': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop registered successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboardscreen()),
      );
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register shop')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register Barber Shop"),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop Name Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (shopName != null)
                        Text("Shop Name: $shopName",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                      if (shopAddress != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Address: $shopAddress",
                              style: const TextStyle(fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mobile Input
              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Enter Mobile No",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.phone, color: Colors.black),
                ),
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Enter valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Image Picker Buttons
              Text("Upload Shop Images",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final picked =
                        await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            selectedImages.add(picked);
                          });
                        }
                      },
                      icon: const Icon(Icons.photo, color: Colors.white),
                      label: const Text("Gallery", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final picked =
                        await _picker.pickImage(source: ImageSource.camera);
                        if (picked != null) {
                          setState(() {
                            selectedImages.add(picked);
                          });
                        }
                      },
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text("Camera", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Image Preview
              if (selectedImages.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(selectedImages[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                height: 40.h,
                width: 320.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  onPressed: submitForm,
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
