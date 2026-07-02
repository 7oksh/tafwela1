import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/utils/app_snackbar.dart';
import '../../models/user_role.dart';

class EmployeeRegisterView extends StatelessWidget {
  EmployeeRegisterView({super.key});

  final authController = Get.find<AuthController>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _stationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _obscurePassword = true.obs;
  final _obscureConfirm = true.obs;

  void _submit() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _stationController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      AppSnackbar.warning(
        'من فضلك املأ كل الحقول',
        title: 'تنبيه',
        position: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackbar.warning(
        'كلمة المرور مش متطابقة',
        title: 'تنبيه',
        position: SnackPosition.BOTTOM,
      );
      return;
    }
    authController.registerStaff(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      stationName: _stationController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1A2A4A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.2,
                  child: Image.asset(
                    'lib/assets/images/logo_white.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'تسجيل موظف محطة',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          label: 'الاسم الأول',
                          hint: 'أحمد',
                          controller: _firstNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          label: 'اسم العائلة',
                          hint: 'محمد',
                          controller: _lastNameController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'اسم المحطة',
                    hint: 'أدخل اسم محطة الوقود',
                    controller: _stationController,
                    prefixIcon: const Icon(Icons.ev_station, color: Color(0xFFB0BEC5)),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'البريد الإلكتروني',
                    hint: 'staff@mail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'رقم الجوال',
                    hint: '01xxxxxxxxx',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFFB0BEC5)),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _buildField(
                    label: 'كلمة المرور',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscure: _obscurePassword.value,
                    suffixIcon: GestureDetector(
                      onTap: () => _obscurePassword.value = !_obscurePassword.value,
                      child: Icon(
                        _obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFFB0BEC5),
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                  Obx(() => _buildField(
                    label: 'تأكيد كلمة المرور',
                    hint: '••••••••',
                    controller: _confirmPasswordController,
                    obscure: _obscureConfirm.value,
                    suffixIcon: GestureDetector(
                      onTap: () => _obscureConfirm.value = !_obscureConfirm.value,
                      child: Icon(
                        _obscureConfirm.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFFB0BEC5),
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: authController.isLoading.value ? null : _submit,
                      icon: authController.isLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Icon(Icons.arrow_back, color: Colors.white),
                      label: Text(
                        authController.isLoading.value ? 'جاري الإرسال...' : 'إرسال طلب التسجيل',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2A4A),
                        disabledBackgroundColor: const Color(0xFF1A2A4A).withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Color(0xFFDDE3F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR SIGN UP WITH',
                          style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFDDE3F0))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                          onPressed: authController.isLoading.value
                              ? null
                              : () => authController.signInWithGoogle(
                                    userType: UserRole.staff,
                                  ),
                          icon: const FaIcon(FontAwesomeIcons.google, size: 18, color: Color(0xFFDB4437)),
                          label: const Text('Google', style: TextStyle(color: Color(0xFF1A2A4A))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFDDE3F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: authController.isLoading.value
                              ? null
                              : () => authController.signInWithFacebook(
                                    userType: UserRole.staff,
                                  ),
                          icon: const FaIcon(FontAwesomeIcons.facebook, size: 18, color: Color(0xFF1877F2)),
                          label: const Text('Facebook', style: TextStyle(color: Color(0xFF1A2A4A))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFDDE3F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('عندك حساب بالفعل؟ ', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text(
                          'سجل دخول',
                          style: TextStyle(color: Color(0xFF1A2A4A), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF1A2A4A), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          textDirection: textDirection,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
