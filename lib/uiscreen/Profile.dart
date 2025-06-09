import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_sem7/uiscreen/Home.dart';
import 'package:project_sem7/uiscreen/SignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedAvatarIndex = 0;
  bool _showAvatarSelector = false;
  String? _userEmail;

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

  void _fetchUserEmail(){
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      setState(() {
        _userEmail = user.email;
      });
    }
  }

  void _saveProfileToFirestore() async{
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = {
      'name': _nameController.text.trim(),
      'mobile': _mobilenoController.text.trim(),
      'email': _userEmail ?? "",
      'avatar': _avatars[_selectedAvatarIndex],
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('ProfileDetail').doc(uid).set(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Hide keyboard on tap outside
          FocusScope.of(context).unfocus();
        },
        child:  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Signin()),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30.h),
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
                  backgroundImage: AssetImage(_avatars[_selectedAvatarIndex]),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            backgroundImage: AssetImage(_avatars[index]),
                          ),
                          if (_selectedAvatarIndex == index)
                            Container(
                              width: 80.r,
                              height: 80.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.orange, width: 3.w),
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
                SizedBox(
                  height: 50.h,
                  width: 320.w,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Enter Name",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.person, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.w),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 50.h,
                  width: 320.w,
                  child: TextFormField(
                    controller: _mobilenoController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Enter Mobile No",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      prefixIcon: const Icon(Icons.phone, color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.w),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 50.h,
                  width: 320.w,
                  child: TextFormField(
                    initialValue: _userEmail ?? "",
                    enabled: false,
                    readOnly: true,
                    style: TextStyle(fontSize: 15.sp,color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email,color: Colors.black,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9.r)),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9.r)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      // You can also customize the fill color if you want it white
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50.h),
            SizedBox(height: 40.w,width: 320.w,
              child: ElevatedButton(onPressed: _saveProfileToFirestore,
                  style:ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.r)),
                      ),
                      backgroundColor: Colors.orange
                  ),child: Text("Continue",style: TextStyle(color: Colors.white,fontSize: 15.sp,fontWeight: FontWeight.bold),)),),
            SizedBox(height: 40.h),
          ],
        ),
      ),
      )
    );
  }
}
