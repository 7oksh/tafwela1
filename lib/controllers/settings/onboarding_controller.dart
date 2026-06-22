import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../views/auth/choose_view.dart';

class OnboardingController extends GetxController {
  final box = GetStorage('Settings');

  // Check if we should show onboarding
  bool isFirstTime() {
    // If it returns null, it's the first time
    return box.read('isFirstTime') ?? true;
  }

  // Call this when the user clicks 'Get Started'
  void completeOnboarding() {
    box.write('isFirstTime', false);
    // Navigate to Home and remove Intro from history stack
    Get.off(() => const ChooseView());
  }
}
