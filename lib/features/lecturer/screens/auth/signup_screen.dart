import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _roles = ['student', 'lecturer', 'admin'];
  static const _programs = ['LL.B', 'LL.M', 'M.A', 'PFD'];
  static const _navyBlue = Color(0xFF0B162C);

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _otherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _universityController = TextEditingController();
  final _academicLevelController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'lecturer';
  String? _selectedProgram;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  bool get _isStudent => _selectedRole == 'student';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _otherNameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _academicLevelController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the terms and conditions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await auth.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        otherName: _otherNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        university: _universityController.text.trim(),
        acadamicLevel: _isStudent ? _academicLevelController.text.trim() : null,
        program: _isStudent ? _selectedProgram : null,
        studentId: _isStudent ? _studentIdController.text.trim() : null,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        role: _selectedRole,
      );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(_emailController.text.trim());
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Signup failed')),
      );
    }
  }

  String? _requiredValidator(String? value, String label) {
    if ((value ?? '').trim().isEmpty) return '$label is required';
    return null;
  }

  String? _nameValidator(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label is required';
    if (text.length < 3 || text.length > 15) {
      return '$label must be 3–15 characters';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required';
    final normalized = text.startsWith('+') ? text.substring(1) : text;
    if (!RegExp(r'^\d+$').hasMatch(normalized) ||
        normalized.length < 10 ||
        normalized.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!text.contains('@') || !text.contains('.')) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? value) {
    if ((value ?? '').isEmpty) return 'Password is required';
    if ((value ?? '').length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if ((value ?? '').isEmpty) return 'Confirm password is required';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isConfirmPassword = false,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    final isObscured =
        isPassword ? _obscurePassword : (isConfirmPassword ? _obscureConfirmPassword : false);
    final showToggle = isPassword || isConfirmPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(fontSize: 12, color: Color(0xFFE84C3D)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isObscured,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: showToggle
                  ? IconButton(
                      icon: Icon(
                        isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _navyBlue,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isPassword) {
                            _obscurePassword = !_obscurePassword;
                          } else {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }
                        });
                      },
                    )
                  : Icon(icon, color: _navyBlue, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(fontSize: 12, color: Color(0xFFE84C3D)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: _navyBlue,
              ),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
              onChanged: onChanged,
              validator: validator,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navyBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ──────────────────────────────────────────────────────
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────────────
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _navyBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join LexGo and start teaching smarter.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Error banner ───────────────────────────────────────────────
                if (auth.error?.isNotEmpty == true) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Fields ─────────────────────────────────────────────────────
                _buildInputField(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  icon: Icons.person_outline,
                  controller: _firstNameController,
                  validator: (v) => _nameValidator(v, 'First name'),
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  icon: Icons.person_outline,
                  controller: _lastNameController,
                  validator: (v) => _nameValidator(v, 'Last name'),
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'Other Name',
                  hint: 'Optional',
                  icon: Icons.person_outline,
                  controller: _otherNameController,
                  required: false,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'Phone Number',
                  hint: 'e.g. +233 55 000 0000',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'University',
                  hint: 'Your institution',
                  icon: Icons.school_outlined,
                  controller: _universityController,
                  validator: (v) => _requiredValidator(v, 'University'),
                ),
                const SizedBox(height: 14),

                // ── Role dropdown ──────────────────────────────────────────────
                _buildDropdownField(
                  label: 'Role',
                  value: _selectedRole,
                  items: _roles,
                  onChanged: auth.isBusy
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedRole = value;
                            if (!_isStudent) {
                              _academicLevelController.clear();
                              _studentIdController.clear();
                              _selectedProgram = null;
                            }
                          });
                        },
                ),

                // ── Student-only fields ────────────────────────────────────────
                if (_isStudent) ...[
                  const SizedBox(height: 14),
                  _buildInputField(
                    label: 'Academic Level',
                    hint: 'e.g. Level 300',
                    icon: Icons.bar_chart_outlined,
                    controller: _academicLevelController,
                    validator: (v) => _requiredValidator(v, 'Academic level'),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdownField(
                    label: 'Program',
                    value: _selectedProgram,
                    items: _programs,
                    onChanged: auth.isBusy
                        ? null
                        : (value) => setState(() => _selectedProgram = value),
                    validator: (v) =>
                        v == null ? 'Program is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildInputField(
                    label: 'Student ID',
                    hint: 'Your student ID number',
                    icon: Icons.badge_outlined,
                    controller: _studentIdController,
                    validator: (v) => _requiredValidator(v, 'Student ID'),
                  ),
                ],
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'Password',
                  hint: 'Create a password',
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  validator: _passwordValidator,
                ),
                const SizedBox(height: 14),
                _buildInputField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  isConfirmPassword: true,
                  validator: _confirmPasswordValidator,
                ),
                const SizedBox(height: 20),

                // ── Terms checkbox ─────────────────────────────────────────────
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      activeColor: _navyBlue,
                      onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _agreeToTerms = !_agreeToTerms),
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _navyBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Sign Up button ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isBusy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navyBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: auth.isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Login link ─────────────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
