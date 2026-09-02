import 'package:firebase_auth/firebase_auth.dart';
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
  int _selectedTab = 0; // 0: Student, 1: Staff, 2: Kitchen Canteen
  final TextEditingController _idController = TextEditingController(text: 'STU-2024-88');
  final TextEditingController _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;

  void _handleLogin() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final idText = _idController.text.trim();

    String loggedInUser = '';
    String email = '';
    UserRole role;
    String id = '';

    if (_selectedTab == 0) {
      role = UserRole.student;
      id = idText.isNotEmpty ? idText : 'STU-2024-88';
      String studentName = 'Student';
      if (idText.contains('@')) {
        email = idText;
        final prefix = idText.split('@').first;
        studentName = prefix[0].toUpperCase() + prefix.substring(1);
      } else if (idText.isNotEmpty) {
        studentName = idText;
        email = '${idText.toLowerCase()}@campus.edu';
      } else {
        email = 'student@campus.edu';
      }
      loggedInUser = studentName;
    } else if (_selectedTab == 1) {
      role = UserRole.staff;
      id = idText.isNotEmpty ? idText : 'STAFF-2024-01';
      String staffName = 'Staff Member';
      if (idText.contains('@')) {
        email = idText;
        final prefix = idText.split('@').first;
        staffName = prefix[0].toUpperCase() + prefix.substring(1);
      } else if (idText.isNotEmpty) {
        staffName = idText;
        email = '${idText.toLowerCase()}@campus.edu';
      } else {
        email = 'staff.member@campus.edu';
      }
      loggedInUser = staffName;
    } else {
      role = UserRole.staff;
      id = 'STAFF-CHEF-01';
      loggedInUser = 'Chef Vikram (Kitchen Head)';
      email = 'kitchen.canteenA@campus.edu';
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          loggedInUser = user.displayName!.trim();
        } else if (user.email != null && user.email!.contains('@')) {
          final prefix = user.email!.split('@').first;
          loggedInUser = prefix[0].toUpperCase() + prefix.substring(1);
        }
      }
    } catch (_) {}

    appState.login(
      id: id,
      name: loggedInUser,
      email: email,
      role: role,
    );

    AppToast.showSuccess(context, 'Successfully Logged In!', duration: const Duration(seconds: 3));

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void _updateDefaultId(int tabIndex) {
    setState(() {
      _selectedTab = tabIndex;
      if (tabIndex == 0) {
        _idController.text = 'STU-2024-88';
      } else if (tabIndex == 1) {
        _idController.text = 'STAFF-2024-01';
      } else {
        _idController.text = 'STAFF-CHEF-01';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.surfaceContainer, width: 1.5),
                  boxShadow: AppTheme.shadowLevel3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppTheme.accentOrange,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // App Name
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Campus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: 'Eats',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Smart Dining & Express Pickup',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Role Selection Tabs (Student / Staff / Kitchen Canteen)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _buildRoleTab(0, 'Student', Icons.school_rounded),
                          _buildRoleTab(1, 'Staff', Icons.badge_rounded),
                          _buildRoleTab(2, 'Kitchen', Icons.soup_kitchen_rounded),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email/Campus ID Input
                    Text(
                      _selectedTab == 0
                          ? 'Campus Student ID / Email'
                          : _selectedTab == 1
                              ? 'Staff Employee ID / Email'
                              : 'Kitchen Canteen ID',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _idController,
                      style: GoogleFonts.beVietnamPro(fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          _selectedTab == 0
                              ? Icons.school_outlined
                              : _selectedTab == 1
                                  ? Icons.badge_outlined
                                  : Icons.soup_kitchen_outlined,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        hintText: _selectedTab == 0
                            ? 'e.g. STU-2024-88'
                            : _selectedTab == 1
                                ? 'e.g. STAFF-2024-01'
                                : 'e.g. STAFF-CHEF-01',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    Text(
                      'Password',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.beVietnamPro(fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.outline,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.primary,
                              content: Text(
                                'Password reset email sent (Simulation)',
                                style: GoogleFonts.beVietnamPro(),
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Login Button
                    ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _selectedTab == 0
                            ? 'Login to Student Portal'
                            : _selectedTab == 1
                                ? 'Login to Staff Portal'
                                : 'Login to Kitchen Canteen',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Social Auth Divider ("OR")
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppTheme.surfaceContainer, thickness: 1.5)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.outline,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppTheme.surfaceContainer, thickness: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Continue with Google Button
                    OutlinedButton(
                      onPressed: () {
                        _updateDefaultId(0);
                        _handleLogin();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.surfaceContainer, width: 1.5),
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continue with Google',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Footer Link: Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppTheme.primary,
                                content: Text(
                                  'Sign Up navigation (Simulation)',
                                  style: GoogleFonts.beVietnamPro(),
                                ),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentOrange,
                              decoration: TextDecoration.underline,
                            ),
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
      ),
    );
  }

  Widget _buildRoleTab(int tabIndex, String label, IconData icon) {
    final isSelected = _selectedTab == tabIndex;
    return Expanded(
      child: InkWell(
        onTap: () => _updateDefaultId(tabIndex),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surfaceWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? AppTheme.shadowLevel1 : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppTheme.primary : AppTheme.outline,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.primary : AppTheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
