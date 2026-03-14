import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/dark_mode_button.dart';

/// شاشة مؤقتة بعد "Hello + اسم المستخدم" - واجهة التطبيق الرئيسية نناقشها لاحقاً
class PlaceholderHomeScreen extends StatelessWidget {
  final UserRole role;

  const PlaceholderHomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('محطات البنزين'),
          centerTitle: true,
          actions: const [DarkModeButton()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  role == UserRole.employee ? Icons.badge : Icons.person,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  role == UserRole.employee
                      ? 'واجهة الموظف - تحديث حالة المحطة'
                      : 'واجهة المستخدم - الخريطة والقائمة',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم تصميم هذه الشاشة لاحقاً',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
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
