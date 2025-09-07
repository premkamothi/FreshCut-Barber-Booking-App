import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_sem7/authentication/Login.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _message = "";

  void resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = "Please enter your email!";
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        _message = "Password reset email sent! Check your mail.";
      });

      // Wait for a moment to show the message, then navigate
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    } catch (e) {
      setState(() {
        _message = "Error: Invalid email or no account found.";
      });
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
          child: Container(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50.h),
              Container(
                height: 260.h,
                width: 260.w,
                child: Image.asset("assets/images/ForgetPassword.png"),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 50.h,
                width: 320.w,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
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
                      borderSide: BorderSide(color: Colors.black, width: 2.w),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Error Message
              if (_message.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
                  child: Text(
                    _message,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(height: 40.h),
              SizedBox(
                height: 40.h,
                width: 320.w,
                child: ElevatedButton(
                    onPressed: resetPassword,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.r)))),
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
