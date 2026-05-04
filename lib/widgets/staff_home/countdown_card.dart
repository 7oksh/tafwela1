import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownCard extends StatelessWidget {
  final int minutes;
  final int seconds;

  const CountdownCard({
    super.key,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "الوقت المتبقي للتحديث الإلزامي",
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              timeBox(_format(seconds), "ثواني"),


              const SizedBox(width: 10),

              const Text(
                ":",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 10),



              timeBox(_format(minutes), "دقائق"),
            ],
          ),
        ],
      ),
    );
  }

  Widget timeBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  //  format 5 → 05
  String _format(int value) {
    return value.toString().padLeft(2, '0');
  }
}
