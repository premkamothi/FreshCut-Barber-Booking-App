import 'package:flutter/material.dart';
import 'package:project_sem7/shop_profile/edit_shop_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_nav_bar.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool hasOwnerRole = false; // ✅ Decides button visibility
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOwnerRole();
  }

  Future<void> _checkOwnerRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          hasOwnerRole = false;
          isLoading = false;
        });
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('ProfileDetail')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          hasOwnerRole = data['ownerRole'] == true;
          isLoading = false;
        });
      } else {
        setState(() {
          hasOwnerRole = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasOwnerRole = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavBar(initialIndex: 0)),
            );
          },
        ),
        title: const Text("Settings", style: TextStyle(color: Colors.black)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 16),
          const Text("Settings Page", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),

          // ✅ Show only if ownerRole is true
          if (hasOwnerRole)
            Center(
              child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditShopProfile()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    "Edit Shop Profile",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
