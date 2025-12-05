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
      List<String> locations = await auth.getLocation();
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
