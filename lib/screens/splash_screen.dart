import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../controllers/Map_controller.dart';
import 'intro_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _getCurrentLocation();

    if (_currentPosition != null) {
      Get.find<MapController>().setPosition(_currentPosition!);
    }

    await Future.delayed(const Duration(seconds: 5));
    Get.off(IntroductionScreens());
  }
  Future<void> _getCurrentLocation() async {
    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;


      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;


      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => Future.error('timeout'),
      );

      if (mounted) setState(() => _currentPosition = position);

    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2F5A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.2,
              child: Image.asset(
                'lib/assets/images/logo_white.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 6),

            // App name

            const SizedBox(height: 6),


            const Text(
              'FUEL & NAVIGATION',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 60),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child:  Text(
                      _currentPosition == null
                          ? 'SEARCHING FOR NEAREST STATION'
                          : 'LOCATION FOUND ✓',
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: LoadingAnimationWidget.inkDrop(
                      color: Colors.white54,

                      size: 30,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 40),


            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                Icon(Icons.lock_outline, color: Colors.white38, size: 12),
                SizedBox(width: 4),
                Text(
                  'SECURE PETROLEUM SERVICES',
                  style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




