import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_sem7/uiscreen/Login.dart';
import 'package:project_sem7/uiscreen/Signup.dart';

import 'Home.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // ✅ Navigate to Home screen after successful sign-in
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      print("Google sign-in error: $e");
      // You can show a SnackBar or AlertDialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 130.h),
              Container(
                height: 230.h,
                width: 230.w,
                child: Image.asset("assets/images/signin.png"),
              ),
              SizedBox(height: 20.h),
              Text("Let's Login",style: TextStyle(fontSize: 35.sp,fontWeight: FontWeight.bold),),
              SizedBox(height: 25.h),
              SizedBox(height: 40.h,width: 220.w,
              child: TextButton(onPressed: _signInWithGoogle, child: Row(
                children: [
                  Image.asset("assets/images/google_logo.png",height: 40.h,width: 40.w,),
                  Text("Continue with Google",style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                ],
              )),),
              SizedBox(height: 30.h),
              Text("or",style: TextStyle(color: Colors.grey,fontSize: 15.sp),),
              SizedBox(height: 30.h),
              SizedBox(height: 50.h,width: 300.w,
              child: ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.r)),
                    )
                  ),
                  child: Text("Sign in with password", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15.sp),)),),
              SizedBox(height: 10.h),
              SizedBox(height: 50.h,width: 250.w,
              child: TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
              }, child: RichText(text: TextSpan(
                children:[
                  TextSpan(text: "Don't have an account?",style: TextStyle(color: Colors.grey,fontSize: 15.sp)),
                  TextSpan(text: " Signup",style: TextStyle(color: Colors.orange,fontSize: 15.sp)),
                ]
              ))),)
            ],
          ),
        ),
      )
    );
  }
}
