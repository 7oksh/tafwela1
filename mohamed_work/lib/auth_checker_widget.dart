import 'package:flutter/material.dart';
import 'package:tafwela/screens/welcom_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/employee_home_screen.dart';
import 'services/auth_service.dart';

/// يتحقق من حالة تسجيل الدخول ويوجه المستخدم للشاشة المناسبة
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final AuthService _auth = AuthService();
  late final Future<StoredUser?> _userFuture = _auth.getStoredUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoredUser?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          return WelcomeScreen(
            username: user.username,
            role: user.role,
            onContinue: (ctx) {
              if (!ctx.mounted) return;
              final home = user.role == UserRole.employee
                  ? const EmployeeHomeScreen()
                  : const UserHomeScreen();
              Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => home),
              );
            },
            onLogout: (ctx) async {
              await _auth.logout();
              if (!ctx.mounted) return;
              Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                    (_) => false,
              );
            },
          );
        }
        return const RoleSelectionScreen();
      },
    );
  }
}
