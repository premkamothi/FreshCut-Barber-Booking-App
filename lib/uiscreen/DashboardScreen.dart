import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StartingPage.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            IconButton(onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              Navigator.push(context, MaterialPageRoute(builder: (context) => Startingpage()));
            }, icon: Icon(Icons.logout)),
            Text("DashBoard Page")
          ],
        )
    );
  }
}
