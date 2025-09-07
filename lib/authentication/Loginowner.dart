import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_sem7/authentication/ForgetPassword.dart';
import 'package:project_sem7/widgets/NavBar.dart';
import 'package:project_sem7/authentication/Signupowner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loginowner extends StatefulWidget {
  const Loginowner({super.key});

  @override
  State<Loginowner> createState() => _LoginStateowner();
}

class _LoginStateowner extends State<Loginowner> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _authErrorMessage;

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
              SizedBox(height: 80.h),
              Padding(
                padding: const EdgeInsets.only(left: 23),
                child: Text(
                  "Login to your Account",
                  style: TextStyle(
                      fontSize: 45.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
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
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.w),
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
                          prefixIcon:
                              const Icon(Icons.password, color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible);
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.w),
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
                            MaterialPageRoute(
                                builder: (context) => Forgetpassword()),
                          );
                        },
                        child: Text(
                          "Forget Password?",
                          style:
                              TextStyle(color: Colors.orange, fontSize: 15.sp),
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
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              // ✅ Set shared preference flag
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('is_logged_in', true);
                              await prefs.setString('user_type', 'owner');

                              if (mounted) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NavBar(),
                                    ));
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
                              setState(() => _authErrorMessage =
                                  'An error occurred. Please try again.');
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Signupowner()));
                      },
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "Don't have an account?",
                            style: TextStyle(
                                color: Colors.black, fontSize: 14.sp)),
                        TextSpan(
                            text: " Sign up",
                            style: TextStyle(
                                color: Colors.orange, fontSize: 14.sp)),
                      ])),
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
