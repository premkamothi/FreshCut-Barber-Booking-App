import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_sem7/uiscreen/Profile.dart';
import 'package:project_sem7/uiscreen/main_home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_nav_bar.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with RouteAware {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _authErrorMessage;

  @override
  void initState() {
    super.initState();
    _clearFields(); // Ensure cleared initially
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _authErrorMessage = null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Ensures fresh login
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final String uid = userCredential.user?.uid ?? '';

      // Check if user profile exists in Firestore
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('ProfileDetail')
          .doc(uid)
          .get();

      final prefs = await SharedPreferences.getInstance();

      if (doc.exists) {
        // Profile already created, set logged in
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_type', 'customer');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNavBar(initialIndex: 0)),
          );
        }
      } else {
        // First-time login, go to Profile screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        }
      }
    } catch (e) {
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard on tap outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 70.h),
              Padding(
                padding: const EdgeInsets.only(left: 23),
                child: Text(
                  "Create your Account",
                  style: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 40.h),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.h,
                      width: 320.w,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.email, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2.w),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        validator: (email) {
                          if (email == null || email.isEmpty) {
                            return "Please enter the email";
                          } else if (!email.contains('@gmail.com')) {
                            return "Please enter valid email that contains @gmail.com";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 50.h,
                      width: 320.w,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.lock, color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2.w),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        validator: (password) {
                          if (password == null || password.isEmpty) {
                            return "Please enter the password";
                          } else if (password.length < 6) {
                            return 'Password must be at least 6 characters long';
                          } else if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
                            return 'Password must contain at least one letter';
                          } else if (!RegExp(r'\d').hasMatch(password)) {
                            return 'Password must contain at least one number';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_authErrorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 15.h),
                        child: Text(
                          _authErrorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      height: 40.h,
                      width: 320.w,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Profile()),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String message = '';
                              if (e.code == 'email-already-in-use') {
                                message = 'This email is already in use.';
                              } else {
                                message = 'Signup failed: ${e.message}';
                              }
                              setState(() => _authErrorMessage = message);
                            } catch (e) {
                              setState(() => _authErrorMessage = 'An error occurred. Please try again.');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                        child: Text(
                          "Sign up",
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 100.h),
                    SizedBox(
                      height: 40.h,
                      width: 220.w,
                      child: ElevatedButton(
                        onPressed: _signInWithGoogle,
                        child: Row(
                          children: [
                            SizedBox(width: 5.w),
                            Image.asset(
                              "assets/images/google_logo.png",
                              height: 25.h,
                              width: 25.w,
                            ),
                            SizedBox(width: 4.w),
                            Text("Continue with Google",
                                style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          side: BorderSide(width: 1)
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
