import 'package:flutter/material.dart';
class AppColors {
static  const Color primaryColor = Color.fromARGB(255, 199, 24, 164);
static  const Color lightPrimaryColor = Color(0xFFFFECDF);

static  const Color secondaryColor = Color(0xFF979797);

static const Color circleColor = Color.fromARGB(255, 199, 24, 164);

static const Color socialCardBgColor = Color(0xFFF5F6F9);

static const Color inActiveIconColor = Color(0xFFB6B6B6);

static const Color searchFieldTextColor = Color(0xff858585);

static const primaryGradientColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 199, 24, 164),
      Color.fromARGB(255, 199, 24, 164)
    ],
  );

static const circleGradientColor = LinearGradient(
    begin: Alignment.center,
    end: Alignment.bottomCenter,
    colors: [Color(0xfffab8c3), Color.fromARGB(255, 199, 24, 164)],
  );
static const Color textColor = Color(0xFF757575);

static const primaryShadow = BoxShadow(
    color: Color(0x19393939),
    blurRadius: 60,
    offset: Offset(0, 30),
  );

static const drawerShadow = BoxShadow(
    color: Color.fromARGB(255, 199, 24, 164),
    offset: Offset(-28, 35),
    spreadRadius: 5,
    blurRadius: 7,
  );
}