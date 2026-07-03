import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/views/widgets/common/custom_button.dart';
import 'package:new_version/utils/app_snackbar.dart';
import 'package:new_version/services/biometric_auth_service.dart';
import 'package:new_version/utils/constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _currentObscure = true.obs;
  final _newObscure = true.obs;
  final _confirmObscure = true.obs;
  final _isLoading = false.obs;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValidPassword(String password) {
    if (password.length < 8) return false;
    return RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  Future<void> _updatePassword() async {
    if (!_isValidPassword(_newController.text)) {
      AppSnackbar.error('كلمة المرور يجب أن تحتوي على 8 أحرف مع أرقام وحروف', title: 'خطأ');
      return;
    }
    if (_newController.text != _confirmController.text) {
      AppSnackbar.error('كلمتا المرور غير متطابقتين', title: 'خطأ');
      return;
    }

    _isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final biometricAuth = Get.find<BiometricAuthService>();
      bool didAuthenticate = await biometricAuth.authenticate();
      if (!didAuthenticate) {
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newController.text);

      Get.back();
      AppSnackbar.success('تم تحديث كلمة المرور بنجاح', title: 'تم');
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(e.message ?? 'فشل تحديث كلمة المرور', title: 'خطأ');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_forward_ios, color: AppColors.white),
        ),
        title: Text(
          AppStrings.changePassword,
          style: GoogleFonts.cairo(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحديث الأمان',
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل مع أرقام وحروف',
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Obx(() => _PasswordField(
                  label: 'كلمة المرور الحالية',
                  controller: _currentController,
                  obscure: _currentObscure.value,
                  onToggle: () => _currentObscure.toggle(),
                )),
            Obx(() => _PasswordField(
                  label: 'كلمة المرور الجديدة',
                  controller: _newController,
                  obscure: _newObscure.value,
                  onToggle: () => _newObscure.toggle(),
                )),
            Obx(() => _PasswordField(
                  label: 'تأكيد كلمة المرور الجديدة',
                  controller: _confirmController,
                  obscure: _confirmObscure.value,
                  onToggle: () => _confirmObscure.toggle(),
                )),
            const SizedBox(height: 32),
            Obx(
              () => CustomButton(
                label: AppStrings.updatePassword,
                icon: Icons.lock_reset,
                onPressed: _updatePassword,
                isLoading: _isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscure,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
