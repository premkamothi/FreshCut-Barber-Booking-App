import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('ProfileDetail').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: Icon(Icons.account_circle, size: 30),
          )
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            SizedBox(height: 150.h,width: 150.w,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: getUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading...", style: TextStyle(color: Colors.white));
                  } else if (snapshot.hasError) {
                    return Text("Error loading profile", style: TextStyle(color: Colors.white));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Text("No profile found", style: TextStyle(color: Colors.white));
                  }

                  final userData = snapshot.data!;
                  final name = userData['name'] ?? 'Guest';
                  final avatarPath = userData['avatar'] ?? 'assets/images/default_avatar.png';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF6EC6FF),
                        radius: 40.r,
                        backgroundImage: AssetImage(avatarPath),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Hi, $name",
                        style: TextStyle(color: Colors.white, fontSize: 18.sp),
                      ),
                    ],
                  );
                },
              ),
            ),),
            ListTile(
              leading: Icon(Icons.account_circle,size: 30,color: Colors.black,),
              title: Text("Profile",style: TextStyle(fontSize: 20.sp,),),
            ),
          ],
        ),
      ),
    );
  }
}
