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
  final Set<String> processedBookings = {}; // Track acted bookings

  /// Get shop owner UID (RegisteredShops document ID)
  Future<String?> _getShopOwnerUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final shopDoc =
    await firestore.collection("RegisteredShops").doc(user.uid).get();
    if (!shopDoc.exists) return null;

    return shopDoc.id;
  }

  /// Accept / Decline booking → updates "status" inside bookings array
  Future<void> _updateBookingStatus(
      String docId, // Owner's BookedSlots docId
      String bookingId,
      bool accepted,
      ) async {
    try {
      final bookingDocRef = firestore.collection("BookedSlots").doc(docId);
      final snapshot = await bookingDocRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final allowedUserIds = List<String>.from(data['allowedUserIds'] ?? []);

      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      if (!allowedUserIds.contains(currentUserId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are not authorized to update this booking")),
        );
        return;
      }

      // ------------------------------
      // Owner side update (match by bookingId)
      // ------------------------------
      List bookings = List.from(data['bookings'] ?? []);
      int ownerBookingIndex =
      bookings.indexWhere((b) => (b['bookingId'] ?? "") == bookingId);

      if (ownerBookingIndex == -1) return;

      bookings[ownerBookingIndex]['status'] = accepted;
      final booking = Map<String, dynamic>.from(bookings[ownerBookingIndex]);

      await bookingDocRef.update({
        'bookings': bookings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // UI feedback
      setState(() => processedBookings.add(bookingId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accepted ? "Booking Accepted ✅" : "Booking Declined ❌")),
      );

      // ------------------------------
      // User side update (mirror by bookingId)
      // ------------------------------
      final userId = booking['userId'] as String;
      final userDocRef = firestore.collection("BookedSlots").doc(userId);

      final userSnapshot = await userDocRef.get();
      if (!userSnapshot.exists) return;

      final userData = userSnapshot.data()!;
      List userBookings = List.from(userData['bookings'] ?? []);

      int userBookingIndex =
      userBookings.indexWhere((b) => (b['bookingId'] ?? "") == bookingId);

      if (userBookingIndex != -1) {
        userBookings[userBookingIndex]['status'] = accepted;
        await userDocRef.update({
          'bookings': userBookings,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Error updating booking status: $e");
    }
  }




  /// Customer visited / not on time
  Future<void> _updateArrivalStatus(
      String docId, int bookingIndex, bool arrived) async {
    try {
      final bookingDocRef =
      firestore.collection("BookedSlots").doc(docId);

      final snapshot = await bookingDocRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final bookings = List.from(data['bookings'] ?? []);
      if (bookingIndex < 0 || bookingIndex >= bookings.length) return;

      final booking = bookings[bookingIndex];
      booking['arrived'] = arrived;

      await bookingDocRef.update({
        'bookings': bookings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => processedBookings.add(
          "${booking['slot']}-${booking['date']}-${booking['userId']}"));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(arrived
                ? "Customer has been visited ✅"
                : "Customer not on time ❌")),
      );
    } catch (e) {
      debugPrint("Error updating arrival status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: FutureBuilder<String?>(
        future: _getShopOwnerUid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No shop registered for this user"));
          }

          final ownerUid = snapshot.data!;
          return StreamBuilder<DocumentSnapshot>(
            stream:
            firestore.collection("BookedSlots").doc(ownerUid).snapshots(),
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
                  final profile = booking['profile'] as Map<String, dynamic>? ?? {};
                  final services = booking['services'] as List<dynamic>? ?? [];
                  final bool? status = booking['status'];
                  final bool? arrived = booking['arrived'];

                  final showAcceptDeclineButtons =
                      !processedBookings.contains(bookingId) && status == null;
                  final showArrivalButtons =
                      status == true && arrived == null;

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
                          // Profile
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: profile['avatar'] != null
                                    ? NetworkImage(profile['avatar'])
                                    : const AssetImage(
                                    "assets/images/avatar1.png")
                                as ImageProvider,
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

                          // Time + Date
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

                          // Action Buttons / Status
                          if (showAcceptDeclineButtons) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _updateBookingStatus(
                                        ownerUid, booking['bookingId'], true),
                                    child: const Text("Accept",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _updateBookingStatus(
                                        ownerUid, booking['bookingId'], false),
                                    child: const Text("Decline",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (showArrivalButtons) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _updateArrivalStatus(
                                        ownerUid, index, true),
                                    child: const Text("Customer visited",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => _updateArrivalStatus(
                                        ownerUid, index, false),
                                    child: const Text("Not on time",
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (status != null) ...[
                            Text(
                              arrived == true
                                  ? "Customer has been visited ✅"
                                  : arrived == false
                                  ? "Customer not on time ❌"
                                  : status
                                  ? "Booking Accepted ✅"
                                  : "Booking Declined ❌",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: arrived == true
                                    ? Colors.green
                                    : arrived == false
                                    ? Colors.red
                                    : status
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
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
