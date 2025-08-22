import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_sem7/booking/review_summary.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/mearge_barber_model.dart';

class DateTimeSelectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedServices;
  final MergedBarber barber;

  const DateTimeSelectionPage({
    super.key,
    required this.selectedServices,
    required this.barber,
  });

  @override
  State<DateTimeSelectionPage> createState() => _DateTimeSelectionPageState();
}

class _DateTimeSelectionPageState extends State<DateTimeSelectionPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedIndex = -1;
  List<String> timeSlots = [];

  late String? monFriStart;
  late String? monFriEnd;
  late String? satSunStart;
  late String? satSunEnd;

  @override
  void initState() {
    super.initState();

    monFriStart = widget.barber.monFriStart;
    monFriEnd = widget.barber.monFriEnd;
    satSunStart = widget.barber.satSunStart;
    satSunEnd = widget.barber.satSunEnd;

    print("DEBUG: Barber working hours: "
        "Mon-Fri $monFriStart - $monFriEnd | Sat-Sun $satSunStart - $satSunEnd");
  }

  /// Parse "09:00 AM" into TimeOfDay
  TimeOfDay _parseTime(String time) {
    final df = DateFormat.jm(); // "h:mm a"
    final dt = df.parse(time);
    return TimeOfDay.fromDateTime(dt);
  }

  /// Generate hourly slots based on working hours
  /// Generate hourly slots based on working hours
  void _generateTimeSlots(DateTime day, {bool fallback = true}) {
    List<String> slots = [];

    bool isWeekend = (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday);

    String? startStr = isWeekend ? satSunStart : monFriStart;
    String? endStr = isWeekend ? satSunEnd : monFriEnd;

    if (startStr == null || endStr == null) {
      setState(() {
        timeSlots = [];
        selectedIndex = -1;
      });
      return;
    }

    TimeOfDay start = _parseTime(startStr);
    TimeOfDay end = _parseTime(endStr);

    DateTime now = DateTime.now();
    DateTime startDateTime = DateTime(day.year, day.month, day.day, start.hour, start.minute);
    DateTime endDateTime = DateTime(day.year, day.month, day.day, end.hour, end.minute);

    DateTime slot = startDateTime;

    while (slot.isBefore(endDateTime)) {
      DateTime slotEnd = slot.add(const Duration(hours: 1));
      if (slotEnd.isAfter(endDateTime)) break;

      if (day.year == now.year && day.month == now.month && day.day == now.day) {
        // today → only future slots
        if (slot.isAfter(now)) {
          slots.add("${DateFormat.jm().format(slot)} - ${DateFormat.jm().format(slotEnd)}");
        }
      } else {
        // future day → keep all slots
        slots.add("${DateFormat.jm().format(slot)} - ${DateFormat.jm().format(slotEnd)}");
      }

      slot = slotEnd;
    }

    if (slots.isEmpty && fallback) {
      // 🔥 fallback: move to tomorrow and generate again
      DateTime tomorrow = day.add(const Duration(days: 1));

      setState(() {
        _selectedDay = tomorrow;
        _focusedDay = tomorrow;
      });

      // regenerate slots for tomorrow
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateTimeSlots(tomorrow, fallback: false);
      });
      return;
    }

    setState(() {
      timeSlots = slots;
      selectedIndex = -1;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Select Date & Time"),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar
          Padding(
            padding: EdgeInsets.all(12.w),
            child: SizedBox(
              height: 343.h,
              child: TableCalendar<dynamic>(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!mounted) return;
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _generateTimeSlots(selectedDay);
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ),

          // Slots
          // Slots Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Text(
              "Book Slot",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),

// 🔥 Show message if no slots
          if (timeSlots.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Text(
                "No slots available for this day. Please select another date.",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(timeSlots.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      height: 50,
                      width: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedIndex == index ? Colors.orange : Colors.white,
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        timeSlots[index],
                        style: TextStyle(
                          color: selectedIndex == index ? Colors.white : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),


          const Spacer(),

          // Continue Button
          Container(
            padding: EdgeInsets.all(16.w),
            width: double.infinity,
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              onPressed: selectedIndex == -1 || _selectedDay == null
                  ? null
                  : () async {
                final user = FirebaseAuth.instance.currentUser!;
                String uid = user.uid;

                String selectedSlot = timeSlots[selectedIndex];
                String selectedDate = DateFormat("yyyy-MM-dd").format(_selectedDay!);

                // ✅ Calculate total price
                int totalPrice = widget.selectedServices.fold(0, (sum, s) => sum + (s['price'] as int));

                Map<String, dynamic> bookingData = {
                  "userId": uid,
                  "barberId": widget.barber.placeId,
                  "services": widget.selectedServices,
                  "totalPrice": totalPrice,
                  "date": selectedDate,
                  "slot": selectedSlot,
                  "createdAt": DateTime.now().toIso8601String(), // ✅ safe timestamp
                };

                final firestore = FirebaseFirestore.instance;

                try {
                  // Save under Barber's document
                  await firestore.collection("BookedSlots").doc(widget.barber.placeId).set({
                    "placeId": widget.barber.placeId,
                    "bookings": FieldValue.arrayUnion([bookingData]),
                    "updatedAt": FieldValue.serverTimestamp(), // ✅ here is valid
                  }, SetOptions(merge: true));

                  // Save under User's document
                  await firestore.collection("BookedSlots").doc(uid).set({
                    "userId": uid,
                    "bookings": FieldValue.arrayUnion([bookingData]),
                    "updatedAt": FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  // Navigate to Review Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewSummary(
                        // barber: widget.barber,
                        // selectedServices: widget.selectedServices,
                        // selectedDate: _selectedDay!,
                        // selectedSlot: selectedSlot,
                      ),
                    ),
                  );
                } catch (e) {
                  print("❌ Error saving booking: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to book slot. Try again.")),
                  );
                }
              },

              child: Text(
                "Continue",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
