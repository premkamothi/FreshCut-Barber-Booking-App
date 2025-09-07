import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_sem7/authentication/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/NavBar.dart';
import '../widgets/bottom_nav_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedAvatarIndex = 0;
  bool _showAvatarSelector = false;
  String? _userEmail;
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobilenoController = TextEditingController();

  final List<String> _avatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
    'assets/images/avatar4.png',
    'assets/images/avatar5.png',
    'assets/images/avatar6.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedAvatar();
    _fetchUserEmail();
    _loadSignupDataFromFirestore(); // NEW: Load signup data
  }

  Future<void> _loadSelectedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAvatarIndex = prefs.getInt('selectedAvatarIndex') ?? 0;
    });
  }

  Future<void> _saveSelectedAvatar(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedAvatarIndex', index);
  }

  void _fetchUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
      });
    }
  }

  Future<void> _loadSignupDataFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Step 1: Check OwnerSignupDetails first
      final ownerDoc = await FirebaseFirestore.instance
          .collection('OwnerSignupDetails')
          .doc(uid)
          .get();

      String collectionName;
      if (ownerDoc.exists && (ownerDoc.data()?['ownerRole'] == true)) {
        // Owner found
        collectionName = 'OwnerSignupDetails';
      } else {
        // Not owner → must be customer
        collectionName = 'CustomerSignupDetails';
      }

      // Step 2: Fetch name & mobile from the right signup collection
      final signupDoc = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(uid)
          .get();

      if (signupDoc.exists && signupDoc.data() != null) {
        final data = signupDoc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _mobilenoController.text = data['mobile'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _saveProfileToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Step 1: Determine ownerRole from signup collections
      bool ownerRole = false;
      final ownerDoc = await FirebaseFirestore.instance
          .collection('OwnerSignupDetails')
          .doc(uid)
          .get();

      if (ownerDoc.exists && (ownerDoc.data()?['ownerRole'] == true)) {
        ownerRole = true;
      }

      // Step 2: Save to ProfileDetail
      final profileData = {
        'name': _nameController.text.trim(),
        'mobile': _mobilenoController.text.trim(),
        'email': _userEmail ?? "",
        'avatar': _avatars[_selectedAvatarIndex],
        'timestamp': FieldValue.serverTimestamp(),
        'ownerRole': ownerRole,
      };

      await FirebaseFirestore.instance
          .collection('ProfileDetail')
          .doc(uid)
          .set(profileData, SetOptions(merge: true));

      //  Step 3: Update correct signup collection
      final signupCollection =
          ownerRole ? 'OwnerSignupDetails' : 'CustomerSignupDetails';

      await FirebaseFirestore.instance
          .collection(signupCollection)
          .doc(uid)
          .update({
        'name': _nameController.text.trim(),
        'mobile': _mobilenoController.text.trim(),
        'isProfileCompleted': true,
        'profileCompletedTimestamp': FieldValue.serverTimestamp(),
      });

      // Step 4: Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );

        if (ownerRole) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NavBar()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const BottomNavBar(initialIndex: 0)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: const Text("Complete Profile",
              style: TextStyle(color: Colors.black)),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),

                      // Avatar Selection
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAvatarSelector = !_showAvatarSelector;
                          });
                        },
                        child: Center(
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF6EC6FF),
                            radius: 60.r,
                            backgroundImage:
                                AssetImage(_avatars[_selectedAvatarIndex]),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      if (_showAvatarSelector)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _avatars.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAvatarIndex = index;
                                    _showAvatarSelector = false;
                                  });
                                  _saveSelectedAvatar(index);
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF6EC6FF),
                                      radius: 40.r,
                                      backgroundImage:
                                          AssetImage(_avatars[index]),
                                    ),
                                    if (_selectedAvatarIndex == index)
                                      Container(
                                        width: 80.r,
                                        height: 80.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.orange, width: 3.w),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 30.h),

                      Column(
                        children: [
                          // Name Field (Pre-filled and editable)
                          SizedBox(
                            height: 50.h,
                            width: 320.w,
                            child: TextFormField(
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Name",
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.black),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 2.w),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Mobile Field (Pre-filled and editable)
                          SizedBox(
                            height: 50.h,
                            width: 320.w,
                            child: TextFormField(
                              controller: _mobilenoController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your mobile number";
                                } else if (!RegExp(r'^\d{10}$')
                                    .hasMatch(value.trim())) {
                                  return "Mobile number must be 10 digits";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Mobile No",
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                prefixIcon: const Icon(Icons.phone,
                                    color: Colors.black),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 2.w),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Email Field (Read-only)
                          Container(
                            height: 50.h,
                            width: 320.w,
                            child: TextFormField(
                              initialValue: _userEmail ?? "",
                              enabled: false,
                              readOnly: true,
                              style: TextStyle(
                                  fontSize: 15.sp, color: Colors.black),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email,
                                    color: Colors.black),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9.r)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9.r)),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.h, horizontal: 10.w),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50.h),

                      // Continue Button
                      SizedBox(
                        height: 40.h,
                        width: 320.w,
                        child: ElevatedButton(
                          onPressed: _saveProfileToFirestore,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.r)),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobilenoController.dispose();
    super.dispose();
  }
}
