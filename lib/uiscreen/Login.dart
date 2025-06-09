import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_sem7/uiscreen/ForgetPassword.dart';
import 'package:project_sem7/uiscreen/Home.dart';
import 'package:project_sem7/uiscreen/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _authErrorMessage;

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
        await prefs.setBool('isLoggedIn', true);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 70.h),
              Text(
                "Login to your Account",
                style: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold),
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
                            return "Email must contain @gmail.com";
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
                          prefixIcon: const Icon(Icons.password, color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
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
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 200.w),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Forgetpassword()),
                          );
                        },
                        child: Text(
                          "Forget Password?",
                          style: TextStyle(color: Colors.orange, fontSize: 15.sp),
                        ),
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
                              await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              // ✅ Set shared preference flag
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('isLoggedIn', true);

                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Home()),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String message = '';
                              if (e.code == 'invalid-credential') {
                                message = "Wrong email or password.";
                              } else {
                                message = 'Login failed: ${e.message}';
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
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Center(
                      child: Text("or", style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
                    ),
                    SizedBox(height: 30.h),
                    SizedBox(
                      height: 40.h,
                      width: 220.w,
                      child: TextButton(
                        onPressed: _signInWithGoogle,
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/google_logo.png",
                              height: 40.h,
                              width: 40.w,
                            ),
                            Text(
                              "Continue with Google",
                              style: TextStyle(color: Colors.black, fontSize: 15.sp),
                            ),
                          ],
                        ),
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
