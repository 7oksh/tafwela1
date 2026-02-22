import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:tafwela/screens/welcom_screen.dart';
import '../services/auth_service.dart';
import '../widgets/dark_mode_button.dart';
import 'user_home_screen.dart';
import 'employee_home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isEmployee;

  const LoginScreen({super.key, required this.isEmployee});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false; // للمستخدم: إنشاء حساب جديد أو دخول
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final auth = AuthService();
    final emailOrUsername = _usernameController.text.trim();
    final password = _passwordController.text;

    if (widget.isEmployee) {
      final user = await auth.loginEmployee(emailOrUsername, password);
      setState(() => _loading = false);
      if (!mounted) return;
      if (user != null) {
        _navigateAfterLogin(user.username, user.role, user.stationId);
      } else {
        setState(() => _errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة');
      }
      return;
    }

    try {
      if (_isRegister) {
        final error = await auth.registerUser(emailOrUsername, password);
        setState(() => _loading = false);
        if (!mounted) return;
        if (error == null) {
          _navigateAfterLogin(emailOrUsername, UserRole.user, null);
        } else {
          setState(() => _errorMessage = error);
        }
      } else {
        final error = await auth.loginUser(emailOrUsername, password);
        setState(() => _loading = false);
        if (!mounted) return;
        if (error == null) {
          final stored = await auth.getStoredUser();
          _navigateAfterLogin(stored?.username ?? emailOrUsername, UserRole.user, null);
        } else {
          setState(() => _errorMessage = error);
        }
      }
    } catch (e, st) {
      debugPrint('LoginScreen _submit: $e\n$st');
      setState(() {
        _loading = false;
        _errorMessage = 'حدث خطأ غير متوقع. جرّب مرة أخرى.';
      });
    }
  }

  void _navigateAfterLogin(String username, UserRole role, String? stationId) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(
          username: username,
          role: role,
          stationId: stationId,
          onContinue: (ctx) {
            if (!ctx.mounted) return;
            final home = role == UserRole.employee
                ? const EmployeeHomeScreen()
                : const UserHomeScreen();
            Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => home),
            );
          },
          onLogout: (ctx) async {
            await AuthService().logout();
            if (!ctx.mounted) return;
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginScreen(isEmployee: widget.isEmployee),
              ),
                  (_) => false,
            );
          },
        ),
      ),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEmployee ? 'دخول موظف' : 'تسجيل الدخول'),
          centerTitle: true,
          actions: const [DarkModeButton()],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: widget.isEmployee ? 'اسم المستخدم' : 'البريد الإلكتروني',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(widget.isEmployee ? Icons.person : Icons.email),
                      ),
                      keyboardType: widget.isEmployee ? TextInputType.text : TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return widget.isEmployee ? 'أدخل اسم المستخدم' : 'أدخل البريد الإلكتروني';
                        }
                        if (!widget.isEmployee && !v.trim().contains('@')) {
                          return 'أدخل بريداً إلكترونياً صحيحاً';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'أدخل كلمة المرور';
                        }
                        if (!widget.isEmployee && _isRegister && v.length < 6) {
                          return 'كلمة المرور 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                    if (!widget.isEmployee) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegister = !_isRegister;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isRegister
                              ? 'لديك حساب؟ سجّل الدخول'
                              : 'لا تملك حساباً؟ إنشاء حساب',
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(_isRegister ? 'إنشاء الحساب' : 'دخول'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
