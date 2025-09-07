import 'package:flutter/material.dart';
import 'package:project_sem7/authentication/Loginowner.dart';
import '../authentication/Login.dart';
import 'StartingPage.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildOverlayText(String text) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black45,
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Customer Image (Top Half)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/image2.jpg',
                    fit: BoxFit.cover,
                  ),

                  // Overlay Text in Center
                  Align(
                    alignment: Alignment.center,
                    child: buildOverlayText("Tap here for Customer"),
                  ),

                  // Custom Back Button in Top Left
                  Positioned(
                    top: 40, // Adjust for status bar
                    left: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Startingpage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barber Image (Bottom Half)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginowner()),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/image3.jpg',
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: buildOverlayText("Tap here for Shop Owner"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
