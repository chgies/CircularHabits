import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for 3 seconds to show the animation
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/habits');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final animationSize = screenWidth / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: animationSize,
          height: animationSize,
          child: const RiveAnimation.asset(
            'assets/animations/CircleLoop.riv',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
