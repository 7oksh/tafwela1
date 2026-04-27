import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    Get.off(() =>  Container(

      ),
    );
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

            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_gas_station,
                color: Color(0xFF1A2F5A),
                size: 50,
              ),
            ),

            const SizedBox(height: 24),

            // App name
            const Text(
              'TAFWELA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),

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




