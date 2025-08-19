import 'package:flutter/material.dart';
import 'package:project_sem7/shop_profile/edit_shop_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_sem7/shop_registration/shop_regester.dart';
import 'package:project_sem7/uiscreen/privacy_policy_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ProfileUpdate.dart';
import 'StartingPage.dart';
import 'bottom_nav_bar.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool hasOwnerRole = false;
  bool isLoading = true;
  bool isDarkMode = false;

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

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // or prefs.setBool('is_logged_in', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Startingpage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BottomNavBar(initialIndex: 0)),
            );
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 10),

                // Edit Profile
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.orange),
                  title: const Text("Edit Profile"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Profileupdate()));
                  },
                ),
                const Divider(
                  height: 1,
                  color: Colors.white,
                ),

                // Owner-specific options
                if (hasOwnerRole) ...[
                  ListTile(
                    leading: const Icon(Icons.store, color: Colors.orange),
                    title: const Text("Edit Shop Profile"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in")),
                        );
                        return;
                      }

                      try {
                        final firestore = FirebaseFirestore.instance;
                        Map<String, dynamic>? shopData;

                        // 🔹 Try case where docId = uid
                        final uidDoc =
                        await firestore.collection('RegisteredShops').doc(user.uid).get();

                        if (uidDoc.exists && uidDoc.data() != null) {
                          shopData = uidDoc.data();
                          debugPrint("✅ Found shop with docId = uid");
                        } else {
                          // 🔹 Fallback: query by uid field (covers docId = placeId or autoId)
                          final query = await firestore
                              .collection('RegisteredShops')
                              .where('uid', isEqualTo: user.uid)
                              .limit(1)
                              .get();

                          if (query.docs.isNotEmpty) {
                            shopData = query.docs.first.data();
                            debugPrint("✅ Found shop by querying uid field");
                          }
                        }

                        if (shopData == null ||
                            shopData['googlePlaceId'] == null ||
                            shopData['ownerUid'] == null) {
                          debugPrint("❌ shopData missing required fields: $shopData");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No registered shop found")),
                          );
                          return;
                        }

                        final placeId = shopData['googlePlaceId'] as String;
                        final uid = shopData['ownerUid'] as String;

                        debugPrint("👉 Navigating with googlePlaceId=$placeId, ownerUid=$uid");

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditShopProfile(
                              placeId: placeId,
                              uid: uid,
                            ),
                          ),
                        );

                      } catch (e, st) {
                        debugPrint("🔥 Error fetching registered shop: $e\n$st");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                  ),


                  const Divider(
                    height: 1,
                    color: Colors.white,
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.add_business, color: Colors.orange),
                    title: const Text("Register Shop"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShopRegister()));
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.white,
                  ),
                ],

                // Privacy Policy
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.orange),
                  title: const Text("Privacy Policy"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage()));
                  },
                ),
                const Divider(
                  height: 1,
                  color: Colors.white,
                ),
                // Dark Mode Toggle
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Colors.orange),
                  title: const Text("Dark Mode"),
                  value: isDarkMode,
                  onChanged: (val) {
                    setState(() {
                      isDarkMode = val;
                    });
                  },
                ),
                // const Divider(
                //   height: 1,
                //   color: Colors.white,
                // ),
                // Logout
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
    );
  }
}
