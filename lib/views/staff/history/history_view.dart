import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version/controllers/staff/history_controller.dart';
import 'package:new_version/database/entities/staff_history_entity.dart';

class HistoryView extends StatelessWidget {
  HistoryView({super.key});

  final HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('سجل تحديثات الحالة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSegmentedControl(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              List<StaffHistoryEntity> list;
              if (controller.selectedTab.value == 0) {
                list = controller.todayHistory;
              } else if (controller.selectedTab.value == 1) {
                list = controller.yesterdayHistory;
              } else {
                list = controller.weekHistory;
              }

              if (list.isEmpty) {
                return Center(
                  child: Text('لا توجد تحديثات', style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return _buildHistoryCard(list[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() => Row(
          children: [
            _buildTab(0, 'اليوم'),
            _buildTab(1, 'أمس'),
            _buildTab(2, 'الأسبوع'),
          ],
        )),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00B4D8) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.cairo(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(StaffHistoryEntity entity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entity.stationName,
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
              ),
              Text(
                entity.updateTime,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'من: ${_translateStatus(entity.oldStatus)}',
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ),
              Text(
                'إلى: ${_translateStatus(entity.newStatus)}',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: _getStatusColor(entity.newStatus)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'الاستجابة: ${_formatDuration(entity.responseDurationSeconds)}',
                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.orange[800]),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'تم التحديث',
                    style: GoogleFonts.cairo(fontSize: 13, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'low': return 'منخفض';
      case 'medium': return 'متوسط';
      case 'high': return 'مرتفع';
      case 'none': return 'لا يوجد';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'low': return Colors.green;
      case 'medium': return Colors.orange;
      case 'high': return Colors.red;
      case 'none': return Colors.grey;
      default: return Colors.black;
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m}د ${s}ث';
    return '${s}ث';
  }
}
