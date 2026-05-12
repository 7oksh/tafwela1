import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/AuthController.dart';

class EmployeeRegister extends StatelessWidget {
  EmployeeRegister({super.key});

  final authController = Get.find<AuthController>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _stationController = TextEditingController();
  final _phoneController = TextEditingController();
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
      Get.snackbar('تنبيه', 'من فضلك املأ كل الحقول',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar('تنبيه', 'كلمة المرور مش متطابقة',
          snackPosition: SnackPosition.BOTTOM);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تسجيل موظف محطة', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A2A4A),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            const Text(
              'بيانات الموظف والمحطة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2A4A)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildField(label: 'الاسم الأول', hint: 'أحمد', controller: _firstNameController)),
                const SizedBox(width: 12),
                Expanded(child: _buildField(label: 'اسم العائلة', hint: 'محمد', controller: _lastNameController)),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(label: 'اسم المحطة', hint: 'محطة مصر - الدقي', controller: _stationController, prefixIcon: const Icon(Icons.ev_station)),
            const SizedBox(height: 16),
            _buildField(label: 'البريد الإلكتروني', hint: 'staff@mail.com', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildField(label: 'رقم الجوال', hint: '01xxxxxxxxx', controller: _phoneController, keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone)),
            const SizedBox(height: 16),
            Obx(() => _buildField(
              label: 'كلمة المرور',
              hint: '••••••••',
              controller: _passwordController,
              obscure: _obscurePassword.value,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                onPressed: () => _obscurePassword.value = !_obscurePassword.value,
              ),
            )),
            const SizedBox(height: 16),
            Obx(() => _buildField(
              label: 'تأكيد كلمة المرور',
              hint: '••••••••',
              controller: _confirmPasswordController,
              obscure: _obscureConfirm.value,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm.value ? Icons.visibility_off : Icons.visibility),
                onPressed: () => _obscureConfirm.value = !_obscureConfirm.value,
              ),
            )),
            const SizedBox(height: 32),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: authController.isLoading.value ? null : _submit,
                icon: authController.isLoading.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  authController.isLoading.value ? 'جاري الإرسال...' : 'إرسال طلب التسجيل',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2A4A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            )),
          ],
        ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF1A2A4A), fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ],
    );
  }
}