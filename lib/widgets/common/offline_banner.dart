import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/services/connectivity_service.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = Get.find<ConnectivityService>().isConnected.value;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: connected
            ? const SizedBox.shrink(key: ValueKey('online'))
            : Material(
                key: const ValueKey('offline'),
                color: const Color(0xFFE65100),
                elevation: 2,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'أنت غير متصل بالإنترنت - البيانات المعروضة قد تكون قديمة',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
