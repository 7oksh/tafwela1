import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordView extends StatelessWidget {
  ChangePasswordView({super.key});

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool currentObscure = true.obs;
  final RxBool newObscure = true.obs;
  final RxBool confirmObscure = true.obs;

  // Password Validation
  bool isValidPassword(String password) {
    if (password.length < 8) return false;
    bool hasLetters = RegExp(r'[A-Za-z]').hasMatch(password);
    bool hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    return hasLetters && hasNumbers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B245B),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "تغيير كلمة المرور",
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                "تحديث الأمان",
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1E2D),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل مع أرقام وحروف",
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 15, color: Colors.grey),
              ),

              const SizedBox(height: 35),

              // Current Password
              Obx(() => buildPasswordField(
                label: "كلمة المرور الحالية",
                hint: "أدخل كلمة المرور الحالية",
                controller: currentPasswordController,
                obscure: currentObscure.value,
                onToggle: () => currentObscure.value = !currentObscure.value,
              )),

              // New Password
              Obx(() => buildPasswordField(
                label: "كلمة المرور الجديدة",
                hint: "أدخل كلمة المرور الجديدة",
                controller: newPasswordController,
                obscure: newObscure.value,
                onToggle: () => newObscure.value = !newObscure.value,
              )),

              // Confirm Password
              Obx(() => buildPasswordField(
                label: "تأكيد كلمة المرور الجديدة",
                hint: "أعد كتابة كلمة المرور",
                controller: confirmPasswordController,
                obscure: confirmObscure.value,
                onToggle: () => confirmObscure.value = !confirmObscure.value,
              )),

              const SizedBox(height: 30),

              // Security Tips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "نصائح الأمان",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0B245B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    securityItem("8 أحرف على الأقل"),
                    securityItem("يجب أن تحتوي على أرقام"),
                    securityItem("يجب أن تحتوي على حروف"),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Button
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 12,
                    shadowColor: const Color(0xFF245DFF).withOpacity(0.4),
                    backgroundColor: const Color(0xFF245DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {
                    // Validation
                    if (!isValidPassword(newPasswordController.text)) {
                      Get.snackbar(
                        "خطأ",
                        "كلمة المرور يجب أن تحتوي على 8 أحرف مع أرقام وحروف",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    // Match Validation
                    if (newPasswordController.text != confirmPasswordController.text) {
                      Get.snackbar(
                        "خطأ",
                        "كلمتا المرور غير متطابقتين",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    // Success
                    Get.snackbar(
                      "تم التحديث",
                      "تم تغيير كلمة المرور بنجاح",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_reset, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        "تحديث كلمة المرور",
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            obscureText: obscure,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              hintStyle: GoogleFonts.cairo(color: Colors.grey),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF245DFF), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  Widget securityItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }
}
