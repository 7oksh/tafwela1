import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:new_version/controllers/AuthController.dart';
import 'package:new_version/screens/Customer_register.dart';
import 'package:new_version/screens/Employee_register.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final authController = Get.find<AuthController>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;
  final int choose = Get.arguments ?? 0;

  void _submit() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('تنبيه', 'من فضلك ادخل الإيميل وكلمة المرور');
      return;
    }

    authController.loginUser(
      email: _emailController.text,
      password: _passwordController.text,
      userType: choose,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView(
            children: [
              SizedBox(height: screenHeight * 0.06),

              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDDE3F0)),
                  ),
                  child: const Icon(
                    Icons.local_gas_station,
                    color: Color(0xFF1A2A4A),
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'TAFWELA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A2A4A),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Fueling your journey efficiently',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF1A2A4A), fontSize: 13),
              ),

              const SizedBox(height: 40),

              // ===== EMAIL =====
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'اسم المستخدم أو البريد الإلكتروني',
                  style: TextStyle(
                    color: Color(0xFF1A2A4A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'أدخل بريدك الإلكتروني',
                  hintStyle:
                  const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Color(0xFFB0BEC5)),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 20),

              // ===== PASSWORD =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'كلمة المرور',
                    style: TextStyle(
                      color: Color(0xFF1A2A4A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Forgot password
                    },
                    child: const Text(
                      'نسيت؟',
                      style: TextStyle(
                        color: Color(0xFF1A2A4A),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword.value,
                decoration: InputDecoration(
                  hintText: 'أدخل كلمة المرور',
                  hintStyle: const TextStyle(
                      color: Color(0xFFB0BEC5), fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: Color(0xFFB0BEC5)),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                    _obscurePassword.value = !_obscurePassword.value,
                    child: Icon(
                      _obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFFB0BEC5),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )),

              const SizedBox(height: 28),

              // ===== LOGIN BUTTON =====
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  authController.isLoading.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2A4A),
                    disabledBackgroundColor:
                    const Color(0xFF1A2A4A).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),

              const SizedBox(height: 24),

              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFFDDE3F0))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style:
                      TextStyle(color: Color(0xFFB0BEC5), fontSize: 11),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFDDE3F0))),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Google Sign-In
                      },
                      icon: const FaIcon(FontAwesomeIcons.google,
                          size: 20, color: Color(0xFFDB4437)),
                      label: const Text('Google',
                          style: TextStyle(color: Color(0xFF1A2A4A))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFDDE3F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Facebook Sign-In
                      },
                      icon: const FaIcon(FontAwesomeIcons.facebook,
                          size: 20, color: Color(0xFF1877F2)),
                      label: const Text('Facebook',
                          style: TextStyle(color: Color(0xFF1A2A4A))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFDDE3F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (choose == 1) {
                        Get.to(() => CustomerRegister());
                      } else if (choose == 2) {
                        Get.to(() => EmployeeRegister());
                      }
                    },
                    child: const Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        color: Color(0xFF1A2A4A),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(
                    ' ليس لديك حساب؟',
                    style:
                    TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}