import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/utils/constants.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.cairo(fontSize: 14),
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintTextDirection: TextDirection.rtl,
          hintStyle: GoogleFonts.cairo(color: AppColors.textSecondary),
          prefixIcon: IconButton(
            onPressed: onFilterTap,
            icon: const Icon(Icons.tune, color: AppColors.navyDark),
          ),
          suffixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
