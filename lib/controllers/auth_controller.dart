import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nursingpdq/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api.dart';
import '../providers/patient_provider.dart';
import '../remote_service/remote_service.dart';
import '../screens/dummy.dart';

final _secureStorage = const FlutterSecureStorage();

class AuthController {
  Future<String> login(String userId, String passcode, unit) async {
    try {
      var encryptedPasscode = md5.convert(utf8.encode(passcode)).toString();
      var refreshToken = await _secureStorage.read(key: 'access_token');
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final Map<String, String> unitMap = {
        'KTN - Tennur': 'Trichy - Tennur',
        'KCN - Cantonment': 'Trichy - Cantonment',
        'KHC - Heartcity': 'Trichy - Heart City',
        'KCH - Chennai Alwarpet': 'Chennai - Alwarpet',
        'KHO - Hosur': 'Hosur',
        'KHS - Salem': 'Salem',
        'KTV - Tirunelveli': 'Tirunelveli',
        'KVP - Vadapalani': 'Vadapalani',
        'KMA - Maa Kauvery': 'Trichy - Maa Kauvery',
      };


      print('5400 -=-=--unitMap $unitMap');


      await prefs.setString('user_uid', userId);
      await prefs.setString('user_unit', unit!);


      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      };
      Map<String, String> payload = {
        "UserName": userId,
        "PassWord": encryptedPasscode,
      };

      String response = await RemoteService().postDataToApi(headers, payload);
      if (response == 'Valid') {
        await prefs.setBool('isLoggedIn', true);
      } else {
        await prefs.setBool('isLoggedIn', false);
      }
      return response;
    } catch (err) {
      return 'Server Error';
    }
  }

  // Future<dynamic> getLocation() async {
  //   try {
  //     var refreshToken = await _secureStorage.read(key: 'access_token');
  //     Map<String, String> headers = {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': 'Bearer $refreshToken',
  //     };
  //
  //     var response = await RemoteService().getDataFromApi(
  //       ApiList.getLocationsApi,
  //       headers,
  //     );
  //
  //     final rows = response['result'][0]['result']['row'] as List<dynamic>;
  //
  //     final List<String> branchNames = rows
  //         .map((row) => row['branchname'].toString())
  //         .toList();
  //
  //     return branchNames;
  //   } catch (err) {
  //     return 'Server Error';
  //   }
  // }

  Future<PatientInfoResult> getPatientInfo(
      String userLocation,
      String barcodeScanResult,
      ) async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        return PatientInfoResult.unauthorized();
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final payload = {
        'type': 'getIPOP',
        'unit': userLocation,
        'ipop_no': barcodeScanResult,
      };

      final json = await RemoteService().postDataFromApi(
        ApiList.getPatientDetailsApi,
        headers,
        payload,
      );

      // Parse the nested structure safely
      final resultList = json['result'] as List<dynamic>?;
      final innerResult =
      resultList?.firstOrNull?['result'] as Map<String, dynamic>?;
      final rows = innerResult?['row'] as List<dynamic>?;
      final patientData = rows?.firstOrNull as Map<String, dynamic>?;

      if (patientData == null || patientData.isEmpty) {
        return PatientInfoResult.notFound();
      }

      return PatientInfoResult.success(patientData);

    } on ApiException catch (e) {
      return switch (e.type) {
        ApiExceptionType.unauthorized  => PatientInfoResult.unauthorized(),
        ApiExceptionType.noRecords     => PatientInfoResult.notFound(),
        ApiExceptionType.network       => PatientInfoResult.serverError(
            'No internet connection.'),
        ApiExceptionType.timeout       => PatientInfoResult.serverError(
            'Request timed out. Please try again.'),
        ApiExceptionType.serverError   => PatientInfoResult.serverError(e.message),
      };
    } catch (e) {
      print('5400 -=-=-=-=>>>  $e');
      return PatientInfoResult.serverError(e.toString());
    }
  }

  Future postPatientForm(Map patientForm, Map patientDetails) async {
    final prefs = await SharedPreferences.getInstance();
    var empId = prefs.getString('user_uid');
    var unit = prefs.getString('user_unit');
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, String> payload = {
        "form_id": "1",
        "submitted_by": "5400",
        "patient_meta": patientDetails.toString(),
        "submitted_data": patientForm.toString(),
        "employee_no": empId ?? '',
        "unit_name": unit ?? '',
        "patient_ip_no": patientDetails['ip_op_no']?.toString() ?? '',
      };

      var patientResponse = await RemoteService().postDataFromApi(
        ApiList.sendPatientForm,
        headers,
        payload,
      );

      final Map<String, dynamic> json = patientResponse;

      return json;
    } catch (err) {
      return 'Server Error';
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      // 1) clear secure tokens
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'access_token_expiry');

      // 2) clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.clear();
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      patientProvider.clearPatient();
      // 3) Navigate to splash/login and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } catch (e, st) {
      // logging + optional user feedback
      debugPrint('logout failed: $e\n$st');
      // Optionally show a SnackBar:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Try again.')),
      );
    }
  }
}
