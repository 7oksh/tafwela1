import 'package:flutter/material.dart';
import '../widgets/dark_mode_button.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تـــفـــويــــــلـــــة'),
          centerTitle: true,
          actions: const [DarkModeButton()],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'اختر نوع الحساب',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                _RoleButton(
                  label: 'مستخدم',
                  icon: Icons.person_outline,
                  onTap: () => _goToLogin(context, isEmployee: false),
                ),
                const SizedBox(height: 20),
                _RoleButton(
                  label: 'موظف محطة',
                  icon: Icons.badge_outlined,
                  onTap: () => _goToLogin(context, isEmployee: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToLogin(BuildContext context, {required bool isEmployee}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(isEmployee: isEmployee),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 26),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
