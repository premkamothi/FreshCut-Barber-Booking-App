import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_sem7/uiscreen/Home.dart';
import 'Profile.dart';

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
  String? _authErrorMessage; // ✅ Inline error message variable

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    } catch (e) {
      print("Google sign-in error: $e");
      // You can handle Google sign-in error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
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
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      validator: (email) {
                        if (email == null || email.isEmpty) {
                          return "Please enter the email";
                        } else if (!email.contains('@gmail.com')) {
                          return "Please enter valid email";
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
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: Icon(
                          Icons.password,
                          color: Colors.black,
                        ),
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
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      validator: (password) {
                        if (password == null || password.isEmpty) {
                          return "Please enter the password";
                        }
                        return null; // Password is valid
                      },
                    ),
                  ),
                  if (_authErrorMessage != null) // ✅ Show error inline
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
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

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String message = '';
                            if (e.code == 'user-not-found') {
                              message = 'No user found for this email.';
                            } else if (e.code == 'wrong-password') {
                              message = 'Wrong password provided.';
                            } else {
                              message = 'Login failed: ${e.message}';
                            }

                            setState(() {
                              _authErrorMessage = message; // ✅ Set error message inline
                            });
                          } catch (e) {
                            setState(() {
                              _authErrorMessage = 'An error occurred. Please try again.';
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    child: Text(
                      "or",
                      style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                    ),
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
    );
  }
}
