// lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nursingpdq/screens/patient_form.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../providers/patient_provider.dart';
import '../widgets/patient_data.dart';
import '../widgets/qr_scanner.dart';
import '../controllers/auth_controller.dart';
import '../remote_service/remote_service.dart';
import 'dummy.dart';

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
  bool _isFetchingPatient = false;
  String? _scannedId; // shows the scanned barcode while loading

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userId = prefs.getString('user_uid') ?? '';
      userUnit = prefs.getString('user_unit') ?? '';
    });
  }

  // ── Scanner entry point ───────────────────────────────────────────────────

  Future<void> scanner() async {
    if (!mounted) return;

    await services.getRefreshToken();

    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );

    final barcodeScanRes = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QRScannerPage()));

    if (barcodeScanRes == null || barcodeScanRes.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _isFetchingPatient = true;
      _scannedId = barcodeScanRes;
      showPatientDetails = false;
    });


    final result = await auth.getPatientInfo(userUnit, barcodeScanRes);

    if (!mounted) return;

    setState(() => _isFetchingPatient = false);

    switch (result.status) {
      case PatientInfoStatus.success:
        patientProvider.setPatient(result.data!);
        setState(() => showPatientDetails = true);

      case PatientInfoStatus.notFound:
        _showResultDialog(
          icon: Icons.search_off_rounded,
          iconColor: Colors.orange.shade600,
          title: 'No Records Found',
          message: 'No patient records were found for\n"$barcodeScanRes".',
        );

      case PatientInfoStatus.unauthorized:
        _showResultDialog(
          icon: Icons.lock_outline_rounded,
          iconColor: Colors.red.shade600,
          title: 'Session Expired',
          message: 'Your session has expired. Please log in again.',
          onDismiss: () => auth.logOut(context),
        );

      case PatientInfoStatus.serverError:
        _showResultDialog(
          icon: Icons.cloud_off_rounded,
          iconColor: Colors.red.shade400,
          title: 'Server Error',
          message: result.message ?? 'Something went wrong. Please try again.',
        );
    }
    ;
  }

  void _showResultDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              style: FilledButton.styleFrom(
                backgroundColor: iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _logout() => auth.logOut(context);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final horizontalPadding = isDesktop ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
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
                        SizedBox(
                          width: 360,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildUserCard(),
                              const SizedBox(height: 12),
                              if (showPatientDetails) _buildQuickActionsCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
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
      floatingActionButton: _buildFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── User card ─────────────────────────────────────────────────────────────

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
                  child: Icon(
                    Icons.person,
                    color: Colors.black.withOpacity(0.8),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _userInfoRow("🪪", userId),
                      const SizedBox(height: 6),
                      _userInfoRow("🏢", userUnit),
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

  Widget _userInfoRow(String emoji, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Quick actions (desktop sidebar) ──────────────────────────────────────

  Widget _buildQuickActionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          children: [
            TextButton.icon(
              onPressed: _isFetchingPatient ? null : scanner,
              icon: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.primaryColor,
              ),
              label: const Text(
                'Scan Patient',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            const Divider(),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DynamicPatientFormPage(),
                ),
              ),
              icon: const Icon(
                Icons.upload_file,
                color: AppColors.primaryColor,
              ),
              label: const Text(
                'New Patient Form',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main area ─────────────────────────────────────────────────────────────

  Widget _buildMainArea(bool isTablet) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final patient = patientProvider.patient;
    final hasPatient = patient != null && patient.isNotEmpty;

    if (hasPatient) showPatientDetails = true;

    // ── Loading state ────────────────────────────────────────────────────
    if (_isFetchingPatient) {
      return _FetchingPatientCard(scannedId: _scannedId);
    }

    // ── Patient found ────────────────────────────────────────────────────
    if (showPatientDetails && hasPatient) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: SizedBox(
            height: isTablet ? 520 : null,
            child: PatientDetailsPage(),
          ),
        ),
      );
    }

    // ── Empty / scan prompt ──────────────────────────────────────────────
    return _ScanPromptCard(onTap: scanner);
  }

  // ── FABs ──────────────────────────────────────────────────────────────────

  Widget _buildFloatingButtons() {
    if (_isFetchingPatient) return const SizedBox.shrink();

    if (showPatientDetails) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.white,
            heroTag: 'scanner',
            onPressed: scanner,
            child: const Icon(
              Icons.document_scanner_outlined,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            heroTag: 'patient_form',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DynamicPatientFormPage()),
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Fetching Patient Card — shown while API call is in-flight
// ═══════════════════════════════════════════════════════════════════════════════

class _FetchingPatientCard extends StatefulWidget {
  final String? scannedId;
  const _FetchingPatientCard({this.scannedId});

  @override
  State<_FetchingPatientCard> createState() => _FetchingPatientCardState();
}

class _FetchingPatientCardState extends State<_FetchingPatientCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing icon ring
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 80 + (_pulse.value * 12),
                height: 80 + (_pulse.value * 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(
                    0.06 + _pulse.value * 0.06,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.12),
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      size: 32,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fetching Patient Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.scannedId != null)
              Text(
                widget.scannedId!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(4),
                backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                color: AppColors.primaryColor,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Scan Prompt Card
// ═══════════════════════════════════════════════════════════════════════════════

class _ScanPromptCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanPromptCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final animWidth = w < 360
                      ? w * 0.8
                      : (w * 0.6).clamp(180.0, 420.0);
                  return Lottie.asset(
                    'assets/lottie/qrScan.json',
                    width: animWidth,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
