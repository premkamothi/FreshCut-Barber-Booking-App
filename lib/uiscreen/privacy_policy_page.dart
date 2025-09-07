import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool? isOwner;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isOwner = false;
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
          isOwner = data['ownerRole'] == true;
          isLoading = false;
        });
      } else {
        setState(() {
          isOwner = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isOwner = false;
        isLoading = false;
      });
    }
  }

  Widget _buildPolicyText() {
    String title = isOwner == true
        ? "Barber / Owner Privacy Policy"
        : "Customer Privacy Policy";

    List<Map<String, dynamic>> sections = isOwner == true
        ? [
            {
              "heading": "Information Collection",
              "points": [
                "Shop profile details, working hours, and service pricing.",
                "Booking data and customer reviews."
              ]
            },
            {
              "heading": "Usage of Data",
              "points": [
                "Display shop details to customers for booking.",
                "Improve service recommendations."
              ]
            },
            {
              "heading": "Data Sharing",
              "points": [
                "Shared only with customers using the platform.",
                "Never sold to third parties."
              ]
            },
            {
              "heading": "Security",
              "points": ["Encrypted storage for sensitive information."]
            },
          ]
        : [
            {
              "heading": "Information Collection",
              "points": [
                "Name, contact information, and booking preferences.",
                "Location data for nearby barber search."
              ]
            },
            {
              "heading": "Usage of Data",
              "points": [
                "Show available barbers and manage bookings.",
                "Improve recommendations and app performance."
              ]
            },
            {
              "heading": "Data Sharing",
              "points": [
                "Your details are shared only with barbers you book.",
                "Never sold to third parties."
              ]
            },
            {
              "heading": "Security",
              "points": ["Encrypted storage and secure communication."]
            },
          ];

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "We value your trust and are committed to protecting your personal information. Please read this policy to understand how we handle your data.",
              style:
                  TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Sections
            ...sections.map((section) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section["heading"],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(section["points"].length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                size: 18, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                section["points"][index],
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFF3E0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Privacy Policy",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Top icon
                        Center(
                          child: Icon(
                            Icons.privacy_tip_rounded,
                            size: 70,
                            color: Colors.orange.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildPolicyText(),
                      ],
                    ),
                  ),
                  // Bottom Accept Button
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;

                          try {
                            await FirebaseFirestore.instance
                                .collection(
                                    'RegisteredShops') // <-- your target collection
                                .doc(uid)
                                .set({
                              'privacyPolicyAccepted': true,
                              'privacyAcceptedAt':
                                  FieldValue.serverTimestamp(), // optional
                            }, SetOptions(merge: true));

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Privacy policy accepted')),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: const Text(
                          "Accept",
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
      ),
    );
  }
}
