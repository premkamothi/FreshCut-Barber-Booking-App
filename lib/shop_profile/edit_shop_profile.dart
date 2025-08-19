import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_sem7/Services.dart';

class EditShopProfile extends StatefulWidget {
  final String uid;
  final String placeId;

  const EditShopProfile({super.key, required this.placeId, required this.uid});

  @override
  State<EditShopProfile> createState() {
    debugPrint("EditShopProfile constructor called with placeId: '$placeId'");
    return _EditShopProfileState();
  }
}

class _EditShopProfileState extends State<EditShopProfile> {

  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _contactControllers = [
    TextEditingController()
  ];
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final FocusNode _aboutFocus = FocusNode();

  TimeOfDay? _monToFriStart;
  TimeOfDay? _monToFriEnd;
  TimeOfDay? _satToSunStart;
  TimeOfDay? _satToSunEnd;

  bool _loading = true;
  String? _currentUid;

  @override
  void initState() {
    super.initState();
    // Delay the fetch to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchShopDetails();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _contactControllers) {
      controller.dispose();
    }
    _addressController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
    _aboutFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchShopDetails() async {
    try {
      setState(() => _loading = true);

      // Debug: Print the placeId to see what we're receiving
      debugPrint("PlaceId received: '${widget.placeId}'");
      debugPrint("PlaceId length: ${widget.placeId.length}");

      // Validate placeId
      if (widget.placeId.isEmpty) {
        setState(() => _loading = false);
        _showErrorAndNavigateBack("Invalid shop ID - placeId is empty");
        return;
      }

      debugPrint("Attempting to fetch from RegisteredShops with placeId: ${widget.placeId}");

      // Step 1: Fetch basic shop data from RegisteredShops using placeId
      DocumentSnapshot registeredShopDoc = await FirebaseFirestore.instance
          .collection('RegisteredShops')
          .doc(widget.uid)
          .get();

      debugPrint("Document exists: ${registeredShopDoc.exists}");

      if (!registeredShopDoc.exists) {
        setState(() => _loading = false);
        _showErrorAndNavigateBack("Shop not found in RegisteredShops collection");
        return;
      }

      final registeredShopData = registeredShopDoc.data() as Map<String, dynamic>;
      debugPrint("RegisteredShop data: $registeredShopData");

      // Step 2: Try to fetch existing profile details from ShopProfileDetails
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('ShopProfileDetails')
          .doc(widget.placeId)
          .get();

      debugPrint("Profile document exists: ${profileDoc.exists}");

      Map<String, dynamic> profileData = {};
      if (profileDoc.exists) {
        profileData = profileDoc.data() as Map<String, dynamic>;
        debugPrint("Profile data: $profileData");
      }

      setState(() {
        // Get UID from registered shop data
        _currentUid = registeredShopData['ownerUid'] ?? widget.uid;


        // Basic shop information from RegisteredShops - try different field names
        _nameController.text = registeredShopData['shopName'] ?? '';
        _addressController.text = registeredShopData['address'] ?? '';


        // Contact numbers from RegisteredShops - try different field names
        String phoneNumber = registeredShopData['number'] ??
            registeredShopData['phoneNumber'] ??
            registeredShopData['contactNumber'] ?? '';

        _contactControllers.clear();
        if (phoneNumber.isNotEmpty) {
          _contactControllers.add(TextEditingController(text: phoneNumber));
        } else {
          // Try to get from array fields
          List contactNumbers = registeredShopData['contactNumbers'] ??
              registeredShopData['mobileNumbers'] ?? [];
          if (contactNumbers.isNotEmpty) {
            for (var contact in contactNumbers) {
              _contactControllers.add(TextEditingController(text: contact.toString()));
            }
          } else {
            _contactControllers.add(TextEditingController());
          }
        }

        // Additional profile data from ShopProfileDetails (if exists)
        _websiteController.text = profileData['websiteLink'] ?? '';
        _aboutController.text = profileData['aboutShop'] ?? '';

        // Load working hours if available
        if (profileData['monFriStart'] != null) {
          _monToFriStart = _parseTime(profileData['monFriStart']);
        }
        if (profileData['monFriEnd'] != null) {
          _monToFriEnd = _parseTime(profileData['monFriEnd']);
        }
        if (profileData['satSunStart'] != null) {
          _satToSunStart = _parseTime(profileData['satSunStart']);
        }
        if (profileData['satSunEnd'] != null) {
          _satToSunEnd = _parseTime(profileData['satSunEnd']);
        }

        // Add any additional contact numbers from profile
        List additionalContacts = profileData['additionalContactNumbers'] ?? [];
        for (var contact in additionalContacts) {
          _contactControllers.add(TextEditingController(text: contact));
        }
      });
    } catch (e) {
      debugPrint("Error fetching shop details: $e");
      setState(() => _loading = false);
      _showErrorAndNavigateBack("Error loading shop details: $e");
    }

    setState(() => _loading = false);
  }

  void _showErrorAndNavigateBack(String message) {
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final format = DateFormat.jm();
      final dt = format.parse(timeStr);
      return TimeOfDay.fromDateTime(dt);
    } catch (e) {
      debugPrint("Error parsing time: $e");
      return TimeOfDay.now();
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUid == null) {
      _showSnackBar("Unable to save: User ID not found", Colors.red);
      return;
    }

    try {
      if (widget.placeId.isEmpty) {
        _showSnackBar("Invalid shop ID", Colors.red);
        return;
      }

      // Collect contacts
      final contacts = _contactControllers
          .map((c) => c.text.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      if (contacts.isEmpty) {
        _showSnackBar("Please add at least one contact number", Colors.red);
        return;
      }

      setState(() => _loading = true);

      final profileData = {
        'ownerUid': _currentUid,
        'placeId': widget.placeId,
        'shopName': _nameController.text.trim(),
        'shopAddress': _addressController.text.trim(),
        'primaryContactNumber': contacts.isNotEmpty ? contacts.first : null,
        'additionalContactNumbers': contacts.length > 1 ? contacts.sublist(1) : [],
        'websiteLink': _websiteController.text.trim(),
        'aboutShop': _aboutController.text.trim(),
        'monFriStart': _monToFriStart != null ? formatTime(_monToFriStart) : null,
        'monFriEnd': _monToFriEnd != null ? formatTime(_monToFriEnd) : null,
        'satSunStart': _satToSunStart != null ? formatTime(_satToSunStart) : null,
        'satSunEnd': _satToSunEnd != null ? formatTime(_satToSunEnd) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      };


      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // ✅ Save full profile under ShopProfileDetails/{placeId}
      final placeIdDoc =
      firestore.collection('ShopProfileDetails').doc(widget.placeId);
      batch.set(placeIdDoc, profileData, SetOptions(merge: true));

      // ✅ Save full profile under ShopProfileDetails/{uid}
      final uidDoc =
      firestore.collection('ShopProfileDetails').doc(_currentUid);
      batch.set(uidDoc, profileData, SetOptions(merge: true));

      await batch.commit();

      setState(() => _loading = false);

      _showSnackBar("Shop profile updated successfully", Colors.green);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Error saving profile: $e");
      _showSnackBar("Error saving profile: $e", Colors.red);
    }
  }



  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart, bool isWeekday) async {
    // Remove focus & close keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    // Delay to allow focus change to finish before opening picker
    await Future.delayed(const Duration(milliseconds: 100));

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
    const lightGrey = Color(0xFFF2F2F2);
    const mediumGreyBorder = Color(0xFFCCCCCC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Edit Shop Profile",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Shop Name
            _buildCardTextField(
              _nameController,
              "Shop Name",
              lightGrey,
            ),
            const SizedBox(height: 10),

            // Contact Numbers (Dynamic)
            ..._buildContactNumberFields(lightGrey),
            const SizedBox(height: 10),

            // Shop Address
            _buildCardTextField(
              _addressController,
              "Shop Address",
              lightGrey,
              maxLines: 2,
            ),
            const SizedBox(height: 10),

            // Website Link
            _buildCardTextField(
              _websiteController,
              "Website Link (Optional)",
              lightGrey,
            ),
            const SizedBox(height: 10),

            // About Shop
            _buildCardTextField(
              _aboutController,
              "About Your Shop (Optional)",
              lightGrey,
              maxLines: 6,
              focusNode: _aboutFocus,
            ),
            const SizedBox(height: 20),

            // Working Hours
            _buildTimeSection(
              "Mon - Fri",
              _monToFriStart,
              _monToFriEnd,
              true,
              lightGrey,
              mediumGreyBorder,
            ),
            const SizedBox(height: 10),
            _buildTimeSection(
              "Sat - Sun",
              _satToSunStart,
              _satToSunEnd,
              false,
              lightGrey,
              mediumGreyBorder,
            ),
            const SizedBox(height: 20),

            // Manage Services
            ListTile(
              leading: const Icon(Icons.build, color: Colors.orange),
              title: const Text(
                "Manage Services",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Services(placeId: widget.placeId),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Update",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardTextField(
      TextEditingController controller,
      String hintText,
      Color bgColor, {
        int maxLines = 1,
        FocusNode? focusNode,
      }) {
    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContactNumberFields(Color bgColor) {
    List<Widget> fields = [];
    for (int i = 0; i < _contactControllers.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: _buildCardTextField(
                  _contactControllers[i],
                  "Contact Number ${i + 1}",
                  bgColor,
                ),
              ),
              if (i == _contactControllers.length - 1 && _contactControllers.length < 5)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.orange),
                  onPressed: () {
                    setState(() {
                      _contactControllers.add(TextEditingController());
                    });
                  },
                ),
              if (_contactControllers.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _contactControllers[i].dispose();
                      _contactControllers.removeAt(i);
                    });
                  },
                ),
            ],
          ),
        ),
      );
    }
    return fields;
  }

  Widget _buildTimeSection(
      String label,
      TimeOfDay? start,
      TimeOfDay? end,
      bool isWeekday,
      Color bgColor,
      Color borderColor,
      ) {
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
                  backgroundColor: bgColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "Start: ${formatTime(start)}",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectTime(context, false, isWeekday),
                style: OutlinedButton.styleFrom(
                  backgroundColor: bgColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "End: ${formatTime(end)}",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}