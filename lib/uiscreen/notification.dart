import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final firestore = FirebaseFirestore.instance;
  late String shopPlaceId;

  // Track bookings that have been acted upon in this session
  final Set<String> processedBookings = {};

  Future<String?> _getShopPlaceId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final shopDoc =
    await firestore.collection("RegisteredShops").doc(user.uid).get();
    if (!shopDoc.exists) return null;

    final data = shopDoc.data();
    return data?['googlePlaceId'] as String?;
  }

  void _updateBookingStatus(
      Map<String, dynamic> booking, bool accepted, String bookingId) async {
    // Prevent decline if already accepted
    if (booking['status'] == true && !accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking already accepted, cannot decline")),
      );
      return;
    }

    final barberDocRef = firestore.collection("BookedSlots").doc(shopPlaceId);
    final userDocRef =
    firestore.collection("BookedSlots").doc(booking['userId']);

    final updatedBooking = {
      ...booking,
      "status": accepted,
    };

    // Update barber's bookings
    await barberDocRef.update({
      "bookings": FieldValue.arrayRemove([booking]),
    });
    await barberDocRef.update({
      "bookings": FieldValue.arrayUnion([updatedBooking]),
    });

    // Update user's bookings
    final userData = await userDocRef.get();
    if (userData.exists) {
      final userBookings =
      (userData.data()!['bookings'] as List<dynamic>? ?? []);
      final oldBooking = userBookings.firstWhere(
            (b) =>
        b['slot'] == booking['slot'] &&
            b['placeId'] == booking['placeId'] &&
            b['date'] == booking['date'],
        orElse: () => null,
      );

      if (oldBooking != null) {
        await userDocRef.update({
          "bookings": FieldValue.arrayRemove([oldBooking]),
        });
        await userDocRef.update({
          "bookings": FieldValue.arrayUnion([updatedBooking]),
        });
      }
    }

    // Mark as processed to disable buttons
    setState(() {
      processedBookings.add(bookingId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(accepted ? "Booking accepted" : "Booking declined")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: FutureBuilder<String?>(
        future: _getShopPlaceId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No shop registered for this user"));
          }

          shopPlaceId = snapshot.data!;
          return StreamBuilder<DocumentSnapshot>(
            stream: firestore
                .collection("BookedSlots")
                .doc(shopPlaceId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return const Center(child: Text("No bookings found"));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final bookings =
              (data['bookings'] as List<dynamic>? ?? []).reversed.toList();

              if (bookings.isEmpty) {
                return const Center(child: Text("No bookings available"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index] as Map<String, dynamic>;
                  final bookingId =
                      "${booking['slot']}-${booking['date']}-${booking['userId']}";
                  final profile = booking['user'] as Map<String, dynamic>? ?? {};
                  final services = booking['services'] as List<dynamic>? ?? [];

                  // Disable buttons ONLY if clicked in this session
                  final buttonsDisabled =
                  processedBookings.contains(bookingId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar + Profile
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: profile['avatar'] != null
                                    ? NetworkImage(profile['avatar'])
                                    : const AssetImage(
                                    "assets/images/avatar1.png") as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile['name'] ?? "No Name",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(profile['mobile'] ?? "No Phone",
                                      style:
                                      const TextStyle(color: Colors.grey)),
                                  Text(profile['email'] ?? "No Email",
                                      style:
                                      const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Slot & Date
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(booking['slot'] ?? "-",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 16),
                              const Icon(Icons.calendar_today,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(booking['date'] ?? "-",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Services
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: services.map<Widget>((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text("${s['name']} - ₹${s['price']}",
                                    style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),

                          // Total Price
                          Text("Total: ₹${booking['totalPrice'] ?? 0}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),

                          // Accept/Decline buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonsDisabled
                                        ? Colors.grey
                                        : Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: buttonsDisabled
                                      ? null
                                      : () => _updateBookingStatus(
                                      booking, true, bookingId),
                                  child: const Text("Accept",
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonsDisabled
                                        ? Colors.grey
                                        : Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: buttonsDisabled
                                      ? null
                                      : () => _updateBookingStatus(
                                      booking, false, bookingId),
                                  child: const Text("Decline",
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ],
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
