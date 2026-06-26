import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/utils/constants.dart';
import 'package:new_version/utils/helpers.dart';

/// Map pin widget — status glow above station name (used on placeholder map).
class StationMapPin extends StatelessWidget {
  const StationMapPin({
    super.key,
    required this.station,
    this.isSelected = false,
    this.onTap,
  });

  final StationModel station;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = Helpers.crowdStatusColor(station.crowdStatus);
    final statusLabel = Helpers.crowdStatusLabel(station.crowdStatus);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status — glowing badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.65),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  statusLabel,
                  style: GoogleFonts.cairo(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Station name
          Container(
            constraints: const BoxConstraints(maxWidth: 130),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEEF2FF) : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: AppColors.primaryBlue, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              station.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.navyDark,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Pin
          Container(
            width: isSelected ? 40 : 36,
            height: isSelected ? 40 : 36,
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.local_gas_station,
              color: AppColors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
