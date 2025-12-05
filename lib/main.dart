import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:nursingpdq/providers/patient_provider.dart';
import 'package:nursingpdq/screens/splash_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        // add other providers...
      ],
      child: const PDQApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // WARNING: Accepts all certificates. ONLY for development!
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
    return client;
  }
}



final Color primaryColor = const Color.fromARGB(255, 199, 24, 164);
final MaterialColor primarySwatch =
    MaterialColor(primaryColor.value, <int, Color>{
      50: Color.lerp(primaryColor, Colors.white, 0.1)!,
      100: Color.lerp(primaryColor, Colors.white, 0.2)!,
      200: Color.lerp(primaryColor, Colors.white, 0.3)!,
      300: Color.lerp(primaryColor, Colors.white, 0.4)!,
      400: Color.lerp(primaryColor, Colors.white, 0.5)!,
      500: primaryColor,
      600: Color.lerp(primaryColor, Colors.black, 0.1)!,
      700: Color.lerp(primaryColor, Colors.black, 0.2)!,
      800: Color.lerp(primaryColor, Colors.black, 0.3)!,
      900: Color.lerp(primaryColor, Colors.black, 0.4)!,
    });

class PDQApp extends StatelessWidget  {
  const PDQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDQ',
      theme: ThemeData(fontFamily: 'Raleway', primarySwatch: primarySwatch),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
