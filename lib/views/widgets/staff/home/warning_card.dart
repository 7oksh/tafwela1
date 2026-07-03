import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WarningCard extends StatelessWidget {
  const WarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 28,
          ),

          const SizedBox(width: 12),

          // 🧾 Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تنبيه: يرجى تحديث حالة الازدحام الآن!",
                  style: GoogleFonts.cairo(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "مرت 5 دقائق منذ آخر تحديث للحالة",
                  style: GoogleFonts.cairo(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.graphic_eq,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "تنبيه صوتي ",
                        style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
