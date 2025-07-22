import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_sem7/uiscreen/DashboardScreen.dart';
import 'package:project_sem7/uiscreen/Loginowner.dart';
import 'package:project_sem7/uiscreen/RegisterPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Signupowner.dart'; // You can change this to DashboardScreen if needed

class Signinowner extends StatefulWidget {
  const Signinowner({super.key});

  @override
  State<Signinowner> createState() => _SigninownerState();
}

class _SigninownerState extends State<Signinowner> {
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Ensure fresh login
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final String email = userCredential.user?.email ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_type', 'owner');

      // Check if email already exists in BarberShops
      final query = await FirebaseFirestore.instance
          .collection('BarberShops')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        // ✅ Email already exists → user is already registered
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboardscreen()), // Replace with Dashboard if needed
          );
        }
      } else {
        // ❌ Email not found → user needs to register
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Registerpage()),
          );
        }
      }
    } catch (e) {
      debugPrint("Google Sign-in failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Sign-in failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 80.h),
            SizedBox(
              height: 230.h,
              width: 230.w,
              child: Image.asset("assets/images/signin.png"),
            ),
            SizedBox(height: 20.h),
            Text("Let's Login", style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 25.h),
            SizedBox(
              height: 40.h,
              width: 220.w,
              child: TextButton(
                onPressed: _signInWithGoogle,
                child: Row(
                  children: [
                    Image.asset("assets/images/google_logo.png", height: 40.h, width: 40.w),
                    SizedBox(width: 10.w),
                    Text("Continue with Google", style: TextStyle(color: Colors.black, fontSize: 15.sp)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Text("or", style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
            SizedBox(height: 30.h),
            SizedBox(
              height: 50.h,
              width: 300.w,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Loginowner()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                  ),
                ),
                child: Text("Sign in with password",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              height: 30.h,
              width: 250.w,
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Signupowner()));
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: "Don't have an account? ", style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
                      TextSpan(text: "Signup", style: TextStyle(color: Colors.orange, fontSize: 15.sp)),
                    ],
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
