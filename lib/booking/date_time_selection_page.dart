import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DateTimeSelectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedServices;

  const DateTimeSelectionPage({
    super.key,
    required this.selectedServices,
  });

  @override
  State<DateTimeSelectionPage> createState() => _DateTimeSelectionPageState();
}

class _DateTimeSelectionPageState extends State<DateTimeSelectionPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = null;
    print("DEBUG: Selected services: ${widget.selectedServices}");
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: _selectedTime type: ${_selectedTime.runtimeType}");
    print("DEBUG: _selectedTime value: $_selectedTime");

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
          // Calendar Section
          Padding(
            padding: EdgeInsets.all(12.w),
            child: SizedBox(
              height: 340.h,
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

          // Time Selection Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Text(
              "Book Slot",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Time Picker - Using Card Style
          _timePickerCardStyle(),

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
              onPressed: _handleContinuePressed,
              child: Text(
                "Continue",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card Style Time Picker
  Widget _timePickerCardStyle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () async {
            try {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: _selectedTime ?? TimeOfDay.now(),
              );

              if (pickedTime != null && mounted) {
                setState(() {
                  _selectedTime = pickedTime;
                });
                print("DEBUG: Time selected: $pickedTime");
              }
            } catch (e) {
              print("ERROR in time picker: $e");
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Colors.orange,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Time",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _selectedTime == null
                            ? "Tap to choose time"
                            : _selectedTime!.format(context),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _selectedTime == null ? Colors.grey : Colors.orange,
                          fontWeight: _selectedTime == null ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey[400],
                  size: 24.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Alternative: FAB Style Time Picker
  Widget _timePickerFabStyle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          if (_selectedTime != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    "Time Selected: ${_selectedTime!.format(context)}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          FloatingActionButton.extended(
            onPressed: () async {
              try {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );

                if (pickedTime != null && mounted) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                  print("DEBUG: Time selected: $pickedTime");
                }
              } catch (e) {
                print("ERROR in time picker: $e");
              }
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.access_time),
            label: Text(
              _selectedTime == null ? "Pick Time" : "Change Time",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Alternative: Border Style Time Picker
  Widget _timePickerBorderStyle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GestureDetector(
        onTap: () async {
          try {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: _selectedTime ?? TimeOfDay.now(),
            );

            if (pickedTime != null && mounted) {
              setState(() {
                _selectedTime = pickedTime;
              });
              print("DEBUG: Time selected: $pickedTime");
            }
          } catch (e) {
            print("ERROR in time picker: $e");
          }
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedTime == null ? Colors.grey[300]! : Colors.orange,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: _selectedTime == null ? Colors.grey[50] : Colors.orange.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: _selectedTime == null ? Colors.grey[600] : Colors.orange,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                _selectedTime == null
                    ? "Select Time Slot"
                    : "Selected: ${_selectedTime!.format(context)}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _selectedTime == null ? Colors.grey[600] : Colors.orange,
                ),
              ),
              const Spacer(),
              Icon(
                _selectedTime == null ? Icons.add : Icons.check_circle,
                color: _selectedTime == null ? Colors.grey[400] : Colors.green,
                size: 20.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinuePressed() {
    try {
      if (_selectedDay == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select date and time"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Calculate total price
      int totalPrice = widget.selectedServices
          .map<int>((service) => service["price"] as int)
          .reduce((a, b) => a + b);

      // Safe access to _selectedTime
      final timeText = _selectedTime!.format(context);

      print("=== BOOKING DETAILS ===");
      print("Selected Services: ${widget.selectedServices.map((s) => s["name"]).join(", ")}");
      print("Total Price: ₹$totalPrice");
      print("Date: ${DateFormat('dd MMM yyyy').format(_selectedDay!)}");
      print("Time: $timeText");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Booking confirmed for ${DateFormat('dd MMM yyyy').format(_selectedDay!)} at $timeText\nTotal: ₹$totalPrice",
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to next page or perform booking action
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingConfirmationPage()));

    } catch (e) {
      print("ERROR in continue button: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}