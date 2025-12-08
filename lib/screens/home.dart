// lib/screens/home.dart
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
import '../controllers/auth_controller.dart';
import '../remote_service/remote_service.dart';

final auth = AuthController();
final services = RemoteService();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userId = '';
  var userUnit = '';
  bool showPatientDetails = false;

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

  Future<void> scanner() async {
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

              // Save directly to Provider
              patientProvider.setPatient(patientDetails);

              if (!mounted) return;
              setState(() {
                showPatientDetails = true;
              });
            }
          },
        ),
      ),
    );
  }

  void _logout() => auth.logOut(context);

  @override
  Widget build(BuildContext context) {
    // Breakpoints
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1024;
    final bool isTablet = width >= 600 && width < 1024;
    final horizontalPadding = isDesktop ? 32.0 : 16.0;

    // Left column width on desktop
    final leftWidth = isDesktop ? 360.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xfff0f4f8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text('Nursing PDQ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 900),
              child: isDesktop
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: user card + small controls
                  SizedBox(
                    width: leftWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserCard(),
                        const SizedBox(height: 12),
                        if(showPatientDetails)
                        _buildQuickActionsCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // RIGHT: main content (QR / Patient details)
                  Expanded(child: _buildMainArea(isTablet)),
                ],
              )
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserCard(),
                    const SizedBox(height: 12),
                    _buildMainArea(isTablet),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButtons(isDesktop),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildUserCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('User Details', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, color: Colors.black.withOpacity(0.8), size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Text("🪪", style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(userId, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Text("🏢", style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(userUnit, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 16), overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          children: [
            TextButton.icon(
              onPressed: scanner,
              icon: const Icon(Icons.qr_code_scanner, color: AppColors.primaryColor),
              label: const Text('Scan Patient', style: TextStyle(color: Colors.black87)),
            ),
            const Divider(),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DynamicPatientFormPage())),
              icon: const Icon(Icons.upload_file, color: AppColors.primaryColor),
              label: const Text('New Patient Form', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainArea(bool isTablet) {
    // Using Provider.watch inside build is fine (we want UI update when patient changes)
    final patientProvider = Provider.of<PatientProvider>(context);
    final patient = patientProvider.patient;
    final bool hasPatient = patient != null && patient.isNotEmpty;

    if (hasPatient) showPatientDetails = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPatientDetails && hasPatient)
        // Patient details area
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: SizedBox(
                // on large screens show a comfortable height; on mobile let it expand
                height: isTablet ? 520 : null,
                child: PatientDetailsPage(),
              ),
            ),
          )
        else
        // QR Scanner card (tap anywhere to start)
          InkWell(
            onTap: scanner,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final animationWidth = w < 360 ? w * 0.8 : (w * 0.6).clamp(180.0, 420.0);
                      return Lottie.asset('assets/lottie/qrScan.json', width: animationWidth, fit: BoxFit.contain);
                    }),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingButtons(bool isDesktop) {
    // If patient details are visible show action buttons, else show single scan FAB
    if (showPatientDetails) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            heroTag: 'scanner',
            onPressed: scanner,
            child: const Icon(Icons.document_scanner_outlined, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            heroTag: 'patient_form',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DynamicPatientFormPage()));
            },
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      );
    }
    else {
      return SizedBox();
        FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        heroTag: 'scan_only',
        onPressed: scanner,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      );
    }
  }
}
