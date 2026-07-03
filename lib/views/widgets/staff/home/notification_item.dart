import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String time;

  const NotificationItem({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.cairo(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
