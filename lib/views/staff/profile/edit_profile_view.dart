import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_version/utils/app_snackbar.dart';
import 'package:new_version/controllers/staff/staff_controller.dart';

/// Returns the correct [ImageProvider] for a stored photo value.
/// Handles base64 data URIs (data:image/...;base64,...) and plain URLs.
ImageProvider? _resolveImageProvider(String value) {
  if (value.isEmpty) return null;
  if (value.startsWith('data:image')) {
    final base64Str = value.split(',').last;
    return MemoryImage(base64Decode(base64Str));
  }
  return NetworkImage(value);
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _staffCtrl = Get.find<StaffController>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;

  Uint8List? _croppedBytes;
  bool _deletePhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final parts = _staffCtrl.staffName.value.split(' ');
    _firstNameCtrl = TextEditingController(text: parts.first);
    _lastNameCtrl =
        TextEditingController(text: parts.skip(1).join(' '));
    _phoneCtrl =
        TextEditingController(text: _staffCtrl.staffPhone.value);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Image pick → crop ───────────────────────────────────────────────────────

  void _confirmDeletePhoto() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('حذف الصورة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل تريد حذف صورة الملف الشخصي؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              setState(() {
                _croppedBytes = null;
                _deletePhoto = true;
              });
            },
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (mounted) setState(() => _croppedBytes = bytes);
  }

  void _showImageSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final hasPhoto = _croppedBytes != null ||
            _staffCtrl.photoUrl.value.isNotEmpty && !_deletePhoto;
        return SafeArea(
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
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('حذف الصورة',
                      style: GoogleFonts.cairo(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _confirmDeletePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      AppSnackbar.warning(
        'الاسم مطلوب',
        title: 'تنبيه',
        position: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String? newPhotoData;

      if (_deletePhoto) {
        newPhotoData = ''; // signal to clear
      } else if (_croppedBytes != null) {
        newPhotoData = 'data:image/jpeg;base64,${base64Encode(_croppedBytes!)}';
      }

      final update = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      };
      if (newPhotoData != null) update['photoUrl'] = newPhotoData;

      await FirebaseFirestore.instance
          .collection('staff')
          .doc(uid)
          .update(update);

      // Instantly reflect in the reactive controller
      _staffCtrl.updateProfileLocally(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        newPhotoUrl: newPhotoData,
      );

      Get.back();
      AppSnackbar.success(
        'تم تحديث بياناتك بنجاح',
        title: 'تم الحفظ',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        position: SnackPosition.BOTTOM,
      );
    } catch (e) {
      AppSnackbar.error(
        'فشل الحفظ، تحقق من اتصالك وأعد المحاولة',
        title: 'خطأ في الحفظ',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        position: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B245B),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تعديل البيانات',
          style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: Get.back,
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            // ── Profile photo ──────────────────────────────────────
            GestureDetector(
              onTap: _showImageSheet,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  _buildAvatar(),
                  // Camera icon (bottom-left)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B245B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                  ),
                  // Delete icon (bottom-right) — only when photo exists
                  if (_croppedBytes != null ||
                      (_staffCtrl.photoUrl.value.isNotEmpty && !_deletePhoto))
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _confirmDeletePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Fields ─────────────────────────────────────────────
            _buildField('الاسم الأول', 'أدخل الاسم الأول',
                _firstNameCtrl),
            _buildField(
                'اسم العائلة', 'أدخل اسم العائلة', _lastNameCtrl),
            _buildField('رقم الهاتف', '+20xxxxxxxxx', _phoneCtrl,
                type: TextInputType.phone),

            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B245B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _croppedBytes != null
                                ? 'جاري رفع الصورة...'
                                : 'جاري الحفظ...',
                            style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text(
                        'حفظ التغييرات',
                        style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    ImageProvider? provider;

    if (_croppedBytes != null) {
      provider = MemoryImage(_croppedBytes!);
    } else if (!_deletePhoto) {
      provider = _resolveImageProvider(_staffCtrl.photoUrl.value);
    }

    return CircleAvatar(
      radius: 58,
      backgroundColor:
          const Color(0xFF1E3A5F).withValues(alpha: 0.15),
      backgroundImage: provider,
      child: provider == null
          ? const Icon(Icons.person,
              size: 58, color: Color(0xFF1E3A5F))
          : null,
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            hintStyle: GoogleFonts.cairo(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
