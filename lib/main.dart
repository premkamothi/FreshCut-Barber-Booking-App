import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:project_sem7/uiscreen/StartingPage.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Startingpage(),
      )
    );
  }
}
