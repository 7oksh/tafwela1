import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/services/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();

    return Obx(() {
      final connected = connectivity.isConnected.value;
      final lastChecked = connectivity.lastCheckedAt.value;

      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: connected ? const Offset(0, -1) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: connected ? 0.0 : 1.0,
          child: Material(
            color: const Color(0xFFB71C1C),
            elevation: 4,
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لا يوجد اتصال بالإنترنت — يتم عرض آخر بيانات محفوظة',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lastChecked,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
