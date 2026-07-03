import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/controllers/map/map_controller.dart';
import 'package:new_version/models/user_role.dart';
import 'package:new_version/routes/app_routes.dart';
import 'package:new_version/services/connectivity_service.dart';
import 'package:new_version/views/admin/admin_main_view.dart';
import '../auth/choose_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
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
    
    final box = GetStorage('Settings');
    final isFirstTime = box.read('isFirstTime') ?? true;
    
    if (isFirstTime) {
      Get.offNamed(AppRoutes.intro);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final lastRoleStr = box.read('lastUserRole') as String?;
    
    if (currentUser != null && lastRoleStr != null) {
      final lastRole = UserRole.values.firstWhere(
        (r) => r.name == lastRoleStr,
        orElse: () => UserRole.customer,
      );
      
      if (Get.find<ConnectivityService>().isConnected.value) {
        // Online: re-validate status against Firestore (handles revoked/blocked accounts)
        await Get.find<AuthController>().routeAuthenticatedUser(currentUser.uid, lastRole);
      } else {
        // Offline: trust the cached role, route directly without Firestore checks.
        // Reuse the same navigation targets as routeAuthenticatedUser's happy path.
        switch (lastRole) {
          case UserRole.staff:
            Get.offAllNamed(AppRoutes.staffMain);
            break;
          case UserRole.admin:
            Get.offAll(() => const AdminMainView());
            break;
          case UserRole.customer:
            Get.offAllNamed(AppRoutes.driverMain);
            break;
        }
      }
    } else {
      Get.off(() => const ChooseView());
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever)
        return;

      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () => Future.error('timeout'),
          );

      if (mounted) setState(() => _currentPosition = position);
    } catch (e) {
      // تجاهل الأخطاء
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
                    child: Text(
                      _currentPosition == null
                          ? 'SEARCHING FOR NEAREST STATION'
                          : 'LOCATION FOUND ✓',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
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
              children: [
                Icon(Icons.lock_outline, color: Colors.white38, size: 12),
                SizedBox(width: 4),
                Text(
                  'SECURE PETROLEUM SERVICES',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
