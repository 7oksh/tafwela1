import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/dark_mode_button.dart';

class WelcomeScreen extends StatelessWidget {
  final String username;
  final UserRole role;
  final String? stationId;
  final void Function(BuildContext context) onContinue;
  final void Function(BuildContext context) onLogout;

  const WelcomeScreen({
    super.key,
    required this.username,
    required this.role,
    this.stationId,
    required this.onContinue,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مرحباً'),
          centerTitle: true,
          actions: const [DarkModeButton()],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.waving_hand,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 24),
                Text(
                  'Hello',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Builder(
                  builder: (ctx) => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => onContinue(ctx),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('فتح التطبيق'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (ctx) => TextButton(
                    onPressed: () => onLogout(ctx),
                    child: const Text('تسجيل الخروج'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
