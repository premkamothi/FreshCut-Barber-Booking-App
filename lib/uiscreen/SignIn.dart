import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        _user = userCredential.user;
      });
    } catch (e) {
      print("Sign-in error: $e");
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 150),
              Container(
                height: 250,
                width: 250,
                child: Image.asset("assets/images/signin.png"),
              ),
              const SizedBox(height: 30),
              if (_user == null)
                ElevatedButton(
                  onPressed: _signInWithGoogle,
                  child: const Text("Continue with Google"),
                )
              else
                Column(
                  children: [
                    Text("Signed in as: ${_user!.displayName}"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _signOut,
                      child: const Text("Sign Out"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      )
    );
  }
}
