import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'SignIn.dart';
import 'dart:async';


class Startingpage extends StatefulWidget {
  const Startingpage({super.key});

  @override
  State<Startingpage> createState() => _StartingpageState();
}

class _StartingpageState extends State<Startingpage> {
  final PageController _controller = PageController();
  int currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> data = [
    {
      "image": "assets/images/image1.jpg",
      "title": "Find Barbers and Salons Easily in Your Hands"
    },
    {
      "image": "assets/images/images3.jpg",
      "title": "Book Your Favorite Barber Quickly"
    },
    {
      "image": "assets/images/image2.jpg",
      "title": "Come be handsome with us right now!"
    },
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (currentPage < data.length - 1) {
        currentPage++;
        _controller.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {});
      } else {
        _timer?.cancel(); // Or restart if looping
      }
    });
  }


  void _nextPage() {
    if (currentPage < data.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _timer?.cancel(); // Stop timer if user manually clicks Get Started
      Navigator.push(context, MaterialPageRoute(builder: (_) => Signin()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 520.h,
              child: PageView.builder(
                controller: _controller,
                itemCount: data.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 370.h,
                        width: double.infinity.w,
                        child: Image.asset(
                          data[index]['image']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          data[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                data.length,
                    (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: currentPage == index ? 25.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color:
                    currentPage == index ? Colors.orange : Colors.grey,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50.h),
            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: SizedBox(
                width: 300.w,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    currentPage == data.length - 1
                        ? "Get Started"
                        : "Next",
                    style:
                    TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

