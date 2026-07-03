import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/models/user_model.dart';
import 'package:new_version/controllers/auth/auth_controller.dart';
import 'package:new_version/models/user_role.dart';
import 'package:new_version/controllers/driver/driver_profile_controller.dart';
import 'package:new_version/controllers/driver/home_controller.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/views/driver/change_password_screen.dart';
import 'package:new_version/views/driver/edit_profile_screen.dart';
import 'package:new_version/views/driver/favorites_screen.dart';
import 'package:new_version/views/widgets/common/profile_menu_tile.dart';
import 'package:new_version/utils/app_snackbar.dart';

DecorationImage? _resolveDecorationImage(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('data:image')) {
    return DecorationImage(
      image: MemoryImage(base64Decode(value.split(',').last)),
      fit: BoxFit.cover,
    );
  }
  return DecorationImage(image: NetworkImage(value), fit: BoxFit.cover);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<DriverProfileController>();

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Obx(() {
        final user = profile.user.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(user: user, showBackButton: showBackButton),
              Transform.translate(
                offset: const Offset(0, -60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _StatsRow(
                        orders: user.ordersCount,
                        points: user.points,
                      ),
                      const SizedBox(height: 16),
                      _MenuSection(profile: profile),
                      const SizedBox(height: 16),
                      _LogoutButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.showBackButton});

  final UserModel user;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (showBackButton ? 8 : 24),
        bottom: 80,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navyHeader,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          if (showBackButton)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.white),
              ),
            ),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
              image: _resolveDecorationImage(user.photoUrl),
              color: AppColors.white.withValues(alpha: 0.2),
            ),
            child: _resolveDecorationImage(user.photoUrl) == null
                ? const Icon(Icons.person, size: 48, color: AppColors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: GoogleFonts.cairo(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.cairo(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.orders, required this.points});

  final int orders;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(value: '$orders', label: 'طلب')),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(child: _StatItem(value: '$points', label: 'نقطة')),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.navyDark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.profile});

  final DriverProfileController profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuTile(
            icon: Icons.person_outline,
            title: AppStrings.editProfile,
            subtitle: 'تحديث بياناتك الشخصية',
            onTap: () => Get.to(() => const EditProfileScreen()),
          ),
          _divider(),
          ProfileMenuTile(
            icon: Icons.favorite_border,
            title: 'محطاتي المفضلة',
            subtitle: 'عرض المحطات المحفوظة',
            onTap: () {
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().changeTab(2);
              } else {
                Get.to(() => const FavoritesScreen());
              }
            },
          ),
          _divider(),
          ProfileMenuTile(
            icon: Icons.tune,
            title: 'تفضيلات البحث',
            subtitle: 'نوع الوقود والماركة المفضلة',
            onTap: () => AppSnackbar.warning('هذه الميزة قيد التطوير', title: 'قريباً'),
          ),
          _divider(),
          ProfileMenuTile(
            icon: Icons.notifications_none,
            title: 'الإشعارات',
            subtitle: 'تحديثات المحطات والرسائل',
            trailing: Obx(
              () => Switch(
                value: profile.notificationsEnabled.value,
                onChanged: (v) => profile.notificationsEnabled.value = v,
                activeTrackColor: AppColors.primaryBlue,
              ),
            ),
          ),
          _divider(),
          ProfileMenuTile(
            icon: Icons.language,
            title: 'لغة التطبيق',
            subtitle: 'العربية (المملكة العربية السعودية)',
            onTap: () {},
          ),
          _divider(),
          ProfileMenuTile(
            icon: Icons.headset_mic_outlined,
            title: 'الدعم الفني',
            subtitle: 'تواصل معنا للمساعدة',
            onTap: () => AppSnackbar.warning('support@tafwela.com', title: 'الدعم'),
          ),
          _divider(),
          ProfileMenuTile(
            icon: Icons.shield_outlined,
            title: 'كلمة المرور والأمان',
            subtitle: 'تغيير الرمز السري',
            onTap: () => Get.to(() => const ChangePasswordScreen()),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade200);
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ProfileMenuTile(
        icon: Icons.logout,
        title: AppStrings.logout,
        titleColor: AppColors.danger,
        trailing: const SizedBox.shrink(),
        onTap: () => Get.find<AuthController>().signOut(UserRole.customer),
      ),
    );
  }
}
