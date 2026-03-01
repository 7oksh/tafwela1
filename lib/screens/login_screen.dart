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
  // اسم المستخدم الذي يظهر في التطبيق (Hello فلان)
  final _displayNameController = TextEditingController();
  bool _isRegister = false; // للمستخدم: إنشاء حساب جديد أو دخول
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final auth = AuthService();
    final emailOrUsername = _usernameController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();

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
        final error = await auth.registerUser(emailOrUsername, password, displayName);
        setState(() => _loading = false);
        if (!mounted) return;
        if (error == null) {
          _navigateAfterLogin(displayName, UserRole.user, null);
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
                    if (!widget.isEmployee && _isRegister) ...[
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (!_isRegister) return null;
                          if (v == null || v.trim().isEmpty) {
                            return 'أدخل اسم المستخدم ';
                          }
                          if (v.trim().length < 3) {
                            return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
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
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (_) {
                        if (!widget.isEmployee && _isRegister) {
                          setState(() {});
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'أدخل كلمة المرور';
                        }
                        if (!widget.isEmployee && _isRegister) {
                          final password = v;
                          final hasUpper = password.contains(RegExp(r'[A-Z]'));
                          final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
                          final hasDigit = password.contains(RegExp(r'\d'));
                          final hasSymbol = password.contains(RegExp(r'[@#_\-\!\$\%\^\&\*\(\)\+\=\.\,\?\:;]'));
                          if (password.length < 8 ||
                              !hasLetter ||
                              !hasDigit ||
                              !hasUpper ||
                              !hasSymbol) {
                            return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل وتحتوي على حرف كبير، حروف وأرقام، ورمز مثل @ أو # أو _.';
                          }
                        }
                        return null;
                      },
                    ),
                    if (!widget.isEmployee && _isRegister) ...[
                      const SizedBox(height: 8),
                      _PasswordRequirements(password: _passwordController.text),
                    ],
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
                            _passwordController.clear();
                            _displayNameController.clear();
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

class _PasswordRequirements extends StatelessWidget {
  final String password;

  const _PasswordRequirements({required this.password});

  @override
  Widget build(BuildContext context) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSymbol = password.contains(RegExp(r'[@#_\-\!\$\%\^\&\*\(\)\+\=\.\,\?\:;]'));

    Text _item(String text, bool ok) {
      return Text(
        '• $text',
        style: TextStyle(
          fontSize: 12,
          color: ok ? Colors.green : Colors.red,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'متطلبات كلمة المرور:',
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
        _item('8 أحرف على الأقل', password.length >= 8),
        _item('تحتوي على حروف وأرقام', hasLetter && hasDigit),
        _item('تحتوي على حرف كبير واحد على الأقل (A-Z)', hasUpper),
        _item('تحتوي على رمز مثل @ أو # أو _', hasSymbol),
      ],
    );
  }
}
