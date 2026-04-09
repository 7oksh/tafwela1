import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CustomerRegister extends StatelessWidget {
  CustomerRegister({super.key});

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _obscurePassword = true.obs;
  final _obscureConfirm = true.obs;

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
                const SizedBox(height: 8),
                const Icon(Icons.local_gas_station, color: Colors.white, size: 36),
                const SizedBox(height: 6),
                const Text(
                  'TAFWELA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'ابعد عن الزحمة',
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
                    label: 'البريد الإلكتروني',
                    hint: 'example@mail.com',
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
                        _obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFFB0BEC5),
                      ),
                    ),
                    helperText: 'كلمة مرور قوية',
                    helperColor: Colors.green,
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
                        _obscureConfirm.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFFB0BEC5),
                      ),
                    ),
                    helperText: 'كلمة مرور قوية',
                    helperColor: Colors.green,
                  )),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2A4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
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
                          onPressed: () {},
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
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('عندك حساب؟ ', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text(
                          'سجل دخول',
                          style: TextStyle(
                            color: Color(0xFF1A2A4A),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'بالتسجيل أنت توافق على الشروط والأحكام وسياسة الخصوصية الخاصة بتفويله',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
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
    String? helperText,
    Color? helperColor,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A2A4A),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
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
            helperText: helperText,
            helperStyle: TextStyle(color: helperColor, fontSize: 11),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
        ),
      ],
    );
  }
}