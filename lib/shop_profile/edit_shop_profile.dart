import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_sem7/Services.dart';
import 'package:project_sem7/uiscreen/main_home_page.dart';
import 'package:project_sem7/uiscreen/settings.dart'; // For formatting time

class EditShopProfile extends StatefulWidget {
  const EditShopProfile({super.key});

  @override
  State<EditShopProfile> createState() => _EditShopProfileState();
}

class _EditShopProfileState extends State<EditShopProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  TimeOfDay? _monToFriStart;
  TimeOfDay? _monToFriEnd;
  TimeOfDay? _satToSunStart;
  TimeOfDay? _satToSunEnd;

  Future<void> _selectTime(BuildContext context, bool isStart, bool isWeekday) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.orange,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: const Color(0xFFFFFAF2),
                hourMinuteColor: Colors.orangeAccent,
                hourMinuteTextColor: Colors.white,
                dialBackgroundColor: Colors.white,
                dialHandColor: Colors.orange,
                dialTextColor: MaterialStateColor.resolveWith(
                      (states) => states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.black,
                ),
                entryModeIconColor: Colors.orange,

                // 🔶 AM/PM toggle styles
                dayPeriodColor: MaterialStateColor.resolveWith((states) {
                  return states.contains(MaterialState.selected)
                      ? Colors.orange
                      : Colors.orange.withOpacity(0.2);
                }),
                dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                  return states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.black;
                }),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
            child: child!,
          );
        }

    );
    if (picked != null) {
      setState(() {
        if (isWeekday) {
          isStart ? _monToFriStart = picked : _monToFriEnd = picked;
        } else {
          isStart ? _satToSunStart = picked : _satToSunEnd = picked;
        }
      });
    }
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return "--:--";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final lightOrange = const Color(0xFFFFFAF2); // Very light orange

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
          },
        ),
        title: const Text("Edit Shop Profile", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildCardTextField(_nameController, "Shop Name", lightOrange),
            const SizedBox(height: 10),
            _buildCardTextField(_numberController, "Contact Number", lightOrange),
            const SizedBox(height: 10),
            _buildCardTextField(_addressController, "Shop Address", lightOrange),
            const SizedBox(height: 10),
            _buildCardTextField(_websiteController, "Website Link", lightOrange),
            const SizedBox(height: 10),
            _buildCardTextField(_aboutController, "About Your Shop", lightOrange, maxLines: 6),

            const SizedBox(height: 20),
            _buildTimeSection("Mon - Fri", _monToFriStart, _monToFriEnd, true),
            const SizedBox(height: 10),
            _buildTimeSection("Sat - Sun", _satToSunStart, _satToSunEnd, false),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add Photos",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image, color: Colors.orange),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Logic for picking photo (future)
                    },
                    icon: const Icon(Icons.add_a_photo, color: Colors.orange),
                    label: const Text(
                      "Add Photo",
                      style: TextStyle(color: Colors.orange),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add Photos of your Specialists",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image, color: Colors.orange),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Logic for picking photo (future)
                    },
                    icon: const Icon(Icons.add_a_photo, color: Colors.orange),
                    label: const Text(
                      "Add Photo",
                      style: TextStyle(color: Colors.orange),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Services()));
                    },
                    icon: const Icon(Icons.build),
                    label: const Text("Manage Services"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14), // Equal vertical padding
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Services())); // Replace with Preview screen
                    },
                    icon: const Icon(Icons.preview),
                    label: const Text("Preview"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),



            const SizedBox(height: 30),
            SizedBox(
              width: 346,
              child: ElevatedButton(
                onPressed: () {
                  // Handle update
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  "Update",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTextField(
      TextEditingController controller, String hintText, Color bgColor,
      {int maxLines = 1}) {
    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection(String label, TimeOfDay? start, TimeOfDay? end, bool isWeekday) {
    final lightOrange = const Color(0xFFFFFAF2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectTime(context, true, isWeekday),
                style: OutlinedButton.styleFrom(
                  backgroundColor: lightOrange,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Start: ${formatTime(start)}"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectTime(context, false, isWeekday),
                style: OutlinedButton.styleFrom(
                  backgroundColor: lightOrange,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("End: ${formatTime(end)}"),
              ),
            ),
          ],
        ),
      ],
    );
  }

}
