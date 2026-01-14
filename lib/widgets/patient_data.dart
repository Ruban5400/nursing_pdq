// lib/screens/patient_edit_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nursingpdq/constants/colors.dart';

import '../providers/patient_provider.dart';

class PatientDetailsPage extends StatefulWidget {
  const PatientDetailsPage({super.key});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  @override
  Widget build(BuildContext context) {
    // Watch provider so UI updates when patient changes
    final provider = context.watch<PatientProvider>();
    final patient = provider.patient;

    // Helper to render a label+value row
    Widget infoRow(String emoji, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // read values with fallbacks
    final ipop = patient?['ip_op_no']?.toString() ?? '';
    final uhid = patient?['uhid']?.toString() ?? '';
    final name = patient?['patient_name']?.toString() ?? '';
    final mobile = patient?['mobile_primary']?.toString() ?? '';
    final age = patient?['age']?.toString() ?? '';
    final gender = patient?['gender']?.toString() ?? '';
    final attender = patient?['attender_contactno']?.toString() ?? '';
    final ward = patient?['ward']?.toString() ?? '';
    final doctorName = patient?['primary_doctor']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Patient Details',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryColor.withOpacity(0.12),
              child: Icon(
                Icons.person,
                color: Colors.black.withOpacity(0.8),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("👤", style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("🆔", style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          ipop,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        infoRow('🏷', 'UHID', uhid),
        const Divider(),
        infoRow('📞', 'Mobile', mobile),
        const Divider(),
        infoRow('🎂', 'Age', age),
        const Divider(),
        infoRow('⚧', 'Gender', gender),
        const Divider(),
        infoRow('👨‍👩‍👧', 'Attender Contact', attender),
        const Divider(),
        infoRow('🏥', 'Ward', ward),
        const Divider(),
        infoRow('👨‍⚕️', 'Doctor Name', doctorName),

      ],
    );
  }
}
