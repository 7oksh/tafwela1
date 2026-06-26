import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_version/controllers/driver_profile_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/widgets/custom_button.dart';

/// Resolves stored photo value (base64 data URI or plain URL) to [ImageProvider].
ImageProvider? _resolvePhoto(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('data:image')) {
    return MemoryImage(base64Decode(value.split(',').last));
  }
  return NetworkImage(value);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  Uint8List? _pickedBytes;
  bool _deletePhoto = false;
  bool _isSaving = false;

  DriverProfileController get _profile =>
      Get.find<DriverProfileController>();

  @override
  void initState() {
    super.initState();
    final user = _profile.user.value;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl  = TextEditingController(text: user?.lastName  ?? '');
    _emailCtrl     = TextEditingController(text: user?.email     ?? '');
    _phoneCtrl     = TextEditingController(text: user?.phone     ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Image picker ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) {
      setState(() {
        _pickedBytes  = bytes;
        _deletePhoto  = false;
      });
    }
  }

  void _showImageSheet() {
    final hasPhoto = _pickedBytes != null ||
        (_profile.user.value?.photoUrl?.isNotEmpty == true && !_deletePhoto);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('الكاميرا', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('المعرض', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.red),
                title: Text('حذف الصورة',
                    style:
                        GoogleFonts.cairo(color: Colors.red)),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _confirmDelete();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('حذف الصورة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل تريد حذف صورة الملف الشخصي؟',
            style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              setState(() {
                _pickedBytes = null;
                _deletePhoto  = true;
              });
            },
            child: Text('حذف',
                style: GoogleFonts.cairo(
                    color: Colors.red,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty) {
      Get.snackbar('تنبيه', 'من فضلك املأ الاسم',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Determine photo update
      String? photoUrl;
      if (_deletePhoto) {
        photoUrl = ''; // signal to clear
      } else if (_pickedBytes != null) {
        photoUrl =
            'data:image/jpeg;base64,${base64Encode(_pickedBytes!)}';
      }

      await _profile.updateProfile(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        photoUrl: photoUrl,
      );

      Get.back();
      Get.snackbar(
        'تم الحفظ',
        'تم تحديث بياناتك بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar('خطأ', 'فشل الحفظ، تحقق من اتصالك وأعد المحاولة',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
          icon: const Icon(Icons.arrow_forward_ios,
              color: AppColors.white),
        ),
        title: Text(
          AppStrings.editProfile,
          style: GoogleFonts.cairo(
              color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ── Avatar ───────────────────────────────────────────────
            GestureDetector(
              onTap: _showImageSheet,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _buildAvatar(),
                  // Camera icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: AppColors.white, size: 16),
                  ),
                  // Delete icon — only when photo exists
                  if (_pickedBytes != null ||
                      (_profile.user.value?.photoUrl?.isNotEmpty ==
                              true &&
                          !_deletePhoto))
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: _confirmDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.white, width: 2),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: AppColors.white, size: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Fields ───────────────────────────────────────────────
            _Field(label: 'الاسم الأول', ctrl: _firstNameCtrl),
            _Field(label: 'اسم العائلة', ctrl: _lastNameCtrl),
            _Field(
                label: 'البريد الإلكتروني',
                ctrl: _emailCtrl,
                readOnly: true),
            _Field(
                label: 'رقم الهاتف',
                ctrl: _phoneCtrl,
                type: TextInputType.phone),

            const SizedBox(height: 24),

            // ── Save button ──────────────────────────────────────────
            CustomButton(
              label: _isSaving
                  ? (_pickedBytes != null
                      ? 'جاري الحفظ...'
                      : 'جاري الحفظ...')
                  : AppStrings.saveChanges,
              onPressed: _isSaving ? () {} : _save,
              isLoading: _isSaving,
              backgroundColor: AppColors.navyDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? provider;
    if (_pickedBytes != null) {
      provider = MemoryImage(_pickedBytes!);
    } else if (!_deletePhoto) {
      provider = _resolvePhoto(_profile.user.value?.photoUrl);
    }

    return CircleAvatar(
      radius: 55,
      backgroundColor:
          AppColors.navyDark.withValues(alpha: 0.1),
      backgroundImage: provider,
      child: provider == null
          ? const Icon(Icons.person,
              size: 55, color: AppColors.navyDark)
          : null,
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.ctrl,
    this.readOnly = false,
    this.type = TextInputType.text,
  });

  final String label;
  final TextEditingController ctrl;
  final bool readOnly;
  final TextInputType type;

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
            controller: ctrl,
            readOnly: readOnly,
            keyboardType: type,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly
                  ? Colors.grey.shade100
                  : AppColors.white,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
