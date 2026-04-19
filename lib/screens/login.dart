// lib/screens/login.dart
import 'package:flutter/material.dart';
import 'package:nursingpdq/screens/home.dart';

import '../constants/colors.dart';
import '../controllers/auth_controller.dart';
import '../remote_service/remote_service.dart';
import '../widgets/welcome.dart';

class Login extends StatefulWidget {
  const Login({required this.locationsList, super.key});

  final List<String> locationsList;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _userUnitController = TextEditingController();

  bool obscureText = true;
  bool status = false;

  String? userIdError;
  String? passwordError;
  String? unitError;

  late final List<String> units = widget.locationsList;

  String? _selectedUnit;

  @override
  void initState() {
    super.initState();

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

    _selectedUnit = units.isNotEmpty ? units.first : null;
    _userUnitController.text = unitMap[_selectedUnit] ?? _selectedUnit ?? '';
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passController.dispose();
    _userUnitController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    setState(() {
      userIdError = null;
      passwordError = null;
      unitError = null;
    });

    final uid = _userIdController.text.trim();
    final pass = _passController.text.trim();
    final unit = _userUnitController.text.trim();

    bool hasError = false;

    if (uid.isEmpty) {
      setState(() => userIdError = "Employee Id is required");
      hasError = true;
    }

    if (pass.isEmpty) {
      setState(() => passwordError = "Password is required");
      hasError = true;
    }

    if (unit == null || unit.isEmpty) {
      setState(() => unitError = "Please select a unit");
      hasError = true;
    }

    if (hasError) return;
    setState(() => status = true);

    print('5400 -=-=-=>>> uid-$uid, pass-$pass, unit-$unit');

    String loginResponse = await AuthController().login(uid, pass, unit);
    setState(() => status = false);
    if (loginResponse == 'Valid') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Error, please try again!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFd0149d);
    // Responsive behavior: center card on wide screens
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // breakpoints: mobile: <600, tablet: 600-1024, desktop: >1024
            final maxW = constraints.maxWidth;
            final bool isDesktop = maxW >= 1024;
            final bool isTablet = maxW >= 600 && maxW < 1024;
            final double cardMaxWidth = isDesktop
                ? 700
                : (isTablet ? 540 : double.infinity);
            final horizontalPadding = isDesktop ? 48.0 : 20.0;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top welcome widget (keeps original welcome)
                            const Welcome(),
                            const SizedBox(height: 12),

                            // Card container that holds the form
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: accent),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  /// EMPLOYEE ID
                                  AppTextField(
                                    label: "Employee Id",
                                    controller: _userIdController,
                                    keyboardType: TextInputType.number,
                                    hint: "Employee Id",
                                    errorText: userIdError,
                                  ),
                                  const SizedBox(height: 12),

                                  /// PASSWORD + SHOW/HIDE
                                  AppTextField(
                                    label: "Password",
                                    controller: _passController,
                                    hint: "Password",
                                    obscure: obscureText,
                                    errorText: passwordError,
                                    showToggle: true,
                                    onToggle: () {
                                      setState(
                                        () => obscureText = !obscureText,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  /// UNIT DROPDOWN
                                  const Text(
                                    'Unit',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 6),

                                  // Make dropdown expand full width and responsive
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: accent),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedUnit,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 0,
                                        ),
                                      ),
                                      items: units
                                          .map(
                                            (u) => DropdownMenuItem(
                                              value: u,
                                              child: Text(
                                                u,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        final Map<String, String> unitMap = {
                                          'KTN - Tennur': 'Trichy - Tennur',
                                          'KCN - Cantonment':
                                              'Trichy - Cantonment',
                                          'KHC - Heartcity':
                                              'Trichy - Heart City',
                                          'KCH - Chennai Alwarpet':
                                              'Chennai - Alwarpet',
                                          'KHO - Hosur': 'Hosur',
                                          'KHS - Salem': 'Salem',
                                          'KTV - Tirunelveli': 'Tirunelveli',
                                          'KVP - Vadapalani': 'Vadapalani',
                                          'KMA - Maa Kauvery':
                                              'Trichy - Maa Kauvery',
                                        };

                                        setState(() {
                                          _selectedUnit = v;

                                          // ✅ Convert to full name here
                                          _userUnitController.text =
                                              unitMap[v] ?? v!;

                                          unitError = null;
                                        });
                                      },
                                    ),
                                  ),

                                  if (unitError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        unitError!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 20),

                                  /// LOGIN BUTTON (full width on mobile, centered on wide)
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _onLoginPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // loading overlay
                if (status)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hint;
  final bool obscure;
  final String? errorText;

  final bool showToggle; // NEW
  final VoidCallback? onToggle; // NEW

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.obscure = false,
    this.errorText,
    this.showToggle = false, // NEW
    this.onToggle, // NEW
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFd0149d);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color.fromARGB(255, 245, 245, 245),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            errorText: errorText,
            // borders
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            // show/hide icon
            suffixIcon: showToggle
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: accent,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
