import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:nursingpdq/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../remote_service/remote_service.dart';
import 'home.dart';
import 'login.dart';

var services = RemoteService();
var auth = AuthController();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isConnected = connectivityResult[0] != ConnectivityResult.none;

    if (isConnected) {
      await services.getRefreshToken();
      // List<String> locations = await auth.getLocation();
      // print('5400 -=-=- >>> $locations');
      // 5400 -=-=- >>> [Chennai - Alwarpet, Electroniccity, Hosur, Kauvery 24/7 Clinic Porur, Marathahalli, Radial Road, Salem, Tirunelveli,
      // Trichy - Cantonment, Trichy - Heart City, Trichy - Maa Kauvery, Trichy - Tennur, Vadapalani]

      List<String> locations = [
        'KTN - Tennur',
        'KCN - Cantonment',
        'KHC - Heartcity',
        'KCH - Chennai Alwarpet',
        'KHO - Hosur',
        'KHS - Salem',
        'KTV - Tirunelveli',
        'KVP - Vadapalani',
        'KMA - Maa Kauvery',
      ];
      final prefs = await SharedPreferences.getInstance();
      final userUid = prefs.getBool('isLoggedIn');
      if (mounted) {
        userUid == true
            ? Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              )
            : Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Login(locationsList: locations),
                ),
              );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/kauvery_logo.png", width: 150),
      ),
    );
  }
}
