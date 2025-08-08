import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Register.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final TextEditingController searchController = TextEditingController();
  final String apiKey = "AIzaSyA5xVaMFV6c5rM4BCq1uVzUmXD_MxGwEZY"; // Replace with your Google Places API Key
  List<dynamic> barberShops = [];
  bool isLoading = false;
  String? userId;

  Future<void> searchGlobalBarbers(String query) async {
    if (query.trim().isEmpty) return;
    final encodedQuery = Uri.encodeComponent(query);
    final url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&type=hair_care&key=$apiKey";

    setState(() => isLoading = true);

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => barberShops = data['results']);
      } else {
        setState(() => barberShops = []);
      }
    } catch (e) {
      setState(() => barberShops = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    searchGlobalBarbers("barber near me");
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black87),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => searchGlobalBarbers(value),
                  decoration: const InputDecoration(
                    hintText: 'Search barber shop by name...',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 16.sp),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () => searchGlobalBarbers(searchController.text),
              )
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: barberShops.length,
        itemBuilder: (context, index) {
          final shop = barberShops[index];
          final String name = shop['name'] ?? 'No Name';
          final String address = shop['formatted_address'] ?? 'No Address';

          return ListTile(
            leading: const Icon(Icons.store),
            title: Text(name),
            subtitle: Text(address),
              onTap: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final ownerEmail = user?.email ?? '';
                  final uid = user?.uid;

                  if (uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in.')),
                    );
                    return;
                  }

                  final query = await FirebaseFirestore.instance
                      .collection('BarberShops')
                      .where('name', isEqualTo: name)
                      .where('address', isEqualTo: address)
                      .get();

                  if (query.docs.isNotEmpty) {
                    // ✅ Shop already exists — update email if needed
                    final doc = query.docs.first;
                    await FirebaseFirestore.instance
                        .collection('BarberShops')
                        .doc(doc.id)
                        .update({'email': ownerEmail});

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  } else {
                    // ❌ New shop — create with UID as document ID
                    await FirebaseFirestore.instance
                        .collection('BarberShops')
                        .doc(uid)
                        .set({
                      'ownerID': userId,
                      'name': name,
                      'address': address,
                      'email': ownerEmail,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to process shop.')),
                  );
                }
              }
          );
        },
      ),
    );
  }
}
