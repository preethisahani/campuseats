import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/app_state.dart';

import '../../widgets/app_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.student;
  final TextEditingController _idController = TextEditingController(text: 'STU-2024-88');
  final TextEditingController _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;

  void _handleLogin() {
    final appState = Provider.of<AppState>(context, listen: false);

    if (_selectedRole == UserRole.student) {
      const studentName = 'Aarav Sharma';
      appState.login(
        id: _idController.text.trim().isNotEmpty ? _idController.text.trim() : 'STU-2024-88',
        name: studentName,
        email: 'aarav.sharma@campus.edu',
        role: UserRole.student,
      );
      AppToast.showSuccess(context, 'Logged in successfully as $studentName');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      const staffName = 'Chef Vikram (Kitchen Head)';
      appState.login(
        id: 'STAFF-CHEF-01',
        name: staffName,
        email: 'kitchen.canteenA@campus.edu',
        role: UserRole.staff,
      );
      AppToast.showSuccess(context, 'Logged in successfully as $staffName');
      Navigator.pushReplacementNamed(context, '/staff_portal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.surfaceContainer, width: 1.5),
                boxShadow: AppTheme.shadowLevel3,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.restaurant_rounded, color: AppTheme.accentOrange, size: 36),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Campus',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: 'Eats',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Smart Dining & Express Pickup',
                      style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppTheme.onSurfaceVariant),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Role Segment Switcher
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _selectedRole = UserRole.student;
                              _idController.text = 'STU-2024-88';
                            }),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.student ? AppTheme.surfaceWhite : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _selectedRole == UserRole.student ? AppTheme.shadowLevel1 : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school_rounded,
                                    size: 16,
                                    color: _selectedRole == UserRole.student ? AppTheme.primary : AppTheme.outline,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Student',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedRole == UserRole.student ? AppTheme.primary : AppTheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _selectedRole = UserRole.staff;
                              _idController.text = 'STAFF-CHEF-01';
                            }),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.staff ? AppTheme.surfaceWhite : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _selectedRole == UserRole.staff ? AppTheme.shadowLevel1 : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.soup_kitchen_rounded,
                                    size: 16,
                                    color: _selectedRole == UserRole.staff ? AppTheme.primary : AppTheme.outline,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Staff / Kitchen',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedRole == UserRole.staff ? AppTheme.primary : AppTheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ID Input
                  Text(
                    _selectedRole == UserRole.student ? 'Campus Student ID' : 'Staff Employee ID',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        _selectedRole == UserRole.student ? Icons.badge_outlined : Icons.admin_panel_settings_outlined,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Input
                  Text(
                    'Password',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.outline,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _selectedRole == UserRole.student ? 'Enter Student Portal' : 'Enter Kitchen Control',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Demo Switch Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Demo Quick Action: ',
                        style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.outline),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedRole = UserRole.student);
                          _handleLogin();
                        },
                        child: Text(
                          'Student Demo',
                          style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.secondary),
                        ),
                      ),
                      Text('•', style: GoogleFonts.beVietnamPro(color: AppTheme.outline)),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedRole = UserRole.staff);
                          _handleLogin();
                        },
                        child: Text(
                          'Staff Demo',
                          style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentOrange),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
