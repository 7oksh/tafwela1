import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeDetailsView extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> data;

  const EmployeeDetailsView({super.key, required this.uid, required this.data});

  Future<void> _updateStatus(String status) async {
    await FirebaseFirestore.instance.collection('staff').doc(uid).update({
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الموظف'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: ${data['firstName'] ?? ''} ${data['lastName'] ?? ''}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('البريد الإلكتروني: ${data['email'] ?? ''}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('رقم الهاتف: ${data['phone'] ?? ''}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('المحطة: ${data['stationName'] ?? ''}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('staff').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final currentData = snapshot.data!.data() as Map<String, dynamic>?;
                final currentStatus = currentData?['status'] ?? 'pending';
                return Text('الحالة الحالية: $currentStatus', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
              }
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateStatus('approved'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus('pending'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text('Pending', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus('denied'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Denied', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
