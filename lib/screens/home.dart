import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nursingpdq/screens/patient_form.dart';
import 'package:nursingpdq/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../providers/patient_provider.dart';
import '../widgets/patient_data.dart';
import '../widgets/qr_scanner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userId = '';
  var userUnit = '';
  bool showPatientDetails = false;
  Map<String, dynamic> patientData = {};

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_uid') ?? '';
      userUnit = prefs.getString('user_unit') ?? '';
    });
  }

  void scanner() async {
    await services.getRefreshToken();
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onScanComplete: (String barcodeScanRes) async {
            if (barcodeScanRes.isNotEmpty) {
              var patientDetails = await auth.getPatientInfo(
                userUnit,
                barcodeScanRes,
              );

              // ❗ Save directly to Provider
              patientProvider.setPatient(patientDetails);

              setState(() {
                showPatientDetails = true;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4f8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Nursing PDQ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => auth.logOut(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TOP USER CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              // elevation: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'User Details',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primaryColor.withOpacity(
                            0.1,
                          ),
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
                                  Text(
                                    "🪪",
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    userId,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    "🏢",
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    userUnit,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // QR Scanner Card
            if (showPatientDetails == true)
              Expanded(child: PatientDetailsPage())
            else
              InkWell(
                onTap: scanner,
                child: Card(
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Lottie.asset(
                          'assets/lottie/qrScan.json',
                          width: MediaQuery.of(context).size.width * 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showPatientDetails == true)
            FloatingActionButton(
              backgroundColor: Colors.white,
              heroTag: 'scanner',
              onPressed: scanner,
              child: const Icon(
                Icons.document_scanner_outlined,
                color: AppColors.primaryColor,
              ),
            ),
          const SizedBox(width: 20),
          if (showPatientDetails == true)
          FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            heroTag: 'patient_form',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DynamicPatientFormPage(),
                ),
              );
            },
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
