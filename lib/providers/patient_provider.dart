// patient_provider.dart
import 'package:flutter/material.dart';

class PatientProvider extends ChangeNotifier {
  Map<String, dynamic>? _patient;

  Map<String, dynamic>? get patient => _patient;

  bool get hasPatient => _patient != null;   // ✅ ADD THIS

  void setPatient(Map<String, dynamic> data) {
    _patient = data;
    notifyListeners();
  }

  // void updateField(String key, dynamic value) {
  //   if (_patient != null) {
  //     print('5400 provider ---updateField  $_patient');
  //     _patient![key] = value;
  //     notifyListeners();
  //   }
  // }

  void clearPatient() {
    _patient = null;
    notifyListeners();
  }
}
