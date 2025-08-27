import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../uiscreen/bottom_nav_bar.dart';

class BookedSlot extends StatefulWidget {
  const BookedSlot({super.key});

  @override
  State<BookedSlot> createState() => _BookedSlotState();
}

class _BookedSlotState extends State<BookedSlot> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String?> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BottomNavBar(initialIndex: 0)),
              );
            },
          ),
          title: const Text(
            "Booked Slots",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<String?>(
            future: _getUserId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("Please login to view your bookings"));
              }

              final userId = snapshot.data!;
              return StreamBuilder<DocumentSnapshot>(
                stream: firestore.collection('BookedSlots').doc(userId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text("No bookings found"));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final bookings = (data['bookings'] as List<dynamic>? ?? []).reversed.toList();

                  if (bookings.isEmpty) {
                    return const Center(child: Text("No bookings available"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index] as Map<String, dynamic>;
                      final shopName = booking['shopName'] ?? "-";
                      final shopAddress = booking['shopAddress'] ?? "-";
                      final slot = booking['slot'] ?? "-";
                      final date = booking['date'] ?? "-";
                      final services = booking['services'] as List<dynamic>? ?? [];

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shopName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(shopAddress, style: TextStyle(color: Colors.grey[700])),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(slot, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: services.map<Widget>((s) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text("${s['name']} - ₹${s['price']}",
                                        style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: (booking['status'] == true)
                                      ? Colors.green.shade100
                                      : (booking['status'] == false && booking['cancelled'] == true)
                                      ? Colors.red.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    (booking['status'] == true)
                                        ? "✅ Your slot is confirmed by barber"
                                        : (booking['status'] == false && booking['cancelled'] == true)
                                        ? "❌ Booking has been canceled by the barber"
                                        : "⏳ Waiting for barber acceptance",
                                    style: TextStyle(
                                      color: (booking['status'] == true)
                                          ? Colors.green.shade800
                                          : (booking['status'] == false && booking['cancelled'] == true)
                                          ? Colors.red.shade800
                                          : Colors.orange.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
        ),
    );
    }
}
