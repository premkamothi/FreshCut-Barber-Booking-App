import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_sem7/widgets/NavBar.dart';
import 'package:project_sem7/uiscreen/StartingPage.dart';
import 'package:project_sem7/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:project_sem7/providers/liked_shops_provider.dart';
import 'package:project_sem7/providers/booking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  String? userType = prefs.getString('user_type') ?? '';

  Widget initialScreen;

  if (!isLoggedIn) {
    initialScreen = Startingpage();
  } else if (userType == 'owner') {
    initialScreen = NavBar();
  } else if (userType == 'customer') {
    initialScreen = BottomNavBar(initialIndex: 0);
  } else {
    initialScreen = Startingpage();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LikedShopsProvider()), //
            ChangeNotifierProvider(create: (_) => BookingProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: initialScreen,
          ),
        );
      },
    );
  }
}