import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionScreens extends StatelessWidget {
  const IntroductionScreens({super.key});

  void _goToLogin() {
    Get.off(() => const Scaffold());
  }

  PageDecoration _pageDecoration() => const PageDecoration(
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      height: 1.5,
    ),
    bodyTextStyle: TextStyle(
      color: Colors.white60,
      fontSize: 14,
      height: 1.6,
    ),
    pageColor: Color(0xFF1A2F5A),
    imagePadding: EdgeInsets.only(top: 40),
    bodyPadding: EdgeInsets.symmetric(horizontal: 24),
    titlePadding: EdgeInsets.only(top: 24, bottom: 12),
  );

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'دلوقتي تقدر تلاقي أقرب بنزينة ليك في ثواني',
          body: 'تفويله بيساعدك توصل لأقرب محطة وقود بسهولة '
              ,
          image: Image.asset('lib/assets/sc1.png'),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: 'تابع حالة الزحمة لحظة بلحظة',
          body: 'اعرف حالة المحطة قبل ما تروح ووفر وقتك ومجهودك في تحديثاتنا اللحظاتية',
          image: Image.asset('lib/assets/sc2.png'),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: 'ابدأ مشوارك ووفر بنزينك',
          body: 'انضم لآلاف المستخدمين في تفويله وابعد عن الزحمة',
          image: Image.asset('lib/assets/sc3.png'),
          decoration: _pageDecoration(),
        ),
      ],

      next: const Text(
        'التالي',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      done: const Text(
        'ابدأ الآن',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onDone: _goToLogin,

      skip: const Text(
        'تخطي',
        style: TextStyle(color: Colors.white60),
      ),
      showSkipButton: true,
      onSkip: _goToLogin,

      dotsDecorator: DotsDecorator(
        size: const Size(8, 8),
        activeSize: const Size(20, 8),
        color: Colors.white30,
        activeColor: Colors.white,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      globalBackgroundColor: const Color(0xFF1A2F5A),
      showNextButton: true,
      isProgress: true,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildImage(IconData icon) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        icon,
        size: 80,
        color: Colors.white,
      ),
    );
  }
}