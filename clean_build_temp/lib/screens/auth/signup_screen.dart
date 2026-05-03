import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _roles = ['student', 'lecturer', 'admin'];
  static const _programs = ['LL.B', 'LL.M', 'M.A', 'PFD'];

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
        const SnackBar(content: Text('Account created. Please sign in.')),
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
      return '$label must be 3-15 characters';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required';
    final normalized = text.startsWith('+') ? text.substring(1) : text;
    final digitsOnly = RegExp(r'^\d+$').hasMatch(normalized);
    if (!digitsOnly || normalized.length < 10 || normalized.length > 15) {
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      appBar: AppBar(
        backgroundColor: AppColors.brandDark,
        foregroundColor: AppColors.brandWhite,
        elevation: 0,
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.brandWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                if (auth.error?.isNotEmpty == true) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brandDanger.withAlpha(18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(
                        color: AppColors.brandDanger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First name',
                  validator: (value) => _nameValidator(value, 'First name'),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last name',
                  validator: (value) => _nameValidator(value, 'Last name'),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _otherNameController,
                  label: 'Other name (optional)',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _universityController,
                  label: 'University',
                  validator: (value) => _requiredValidator(value, 'University'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: _inputDecoration('Role'),
                  items: _roles
                      .map(
                        (role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ),
                      )
                      .toList(),
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
                if (_isStudent) ...[
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _academicLevelController,
                    label: 'Academic level',
                    validator: (value) =>
                        _requiredValidator(value, 'Academic level'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProgram,
                    decoration: _inputDecoration('Program'),
                    items: _programs
                        .map(
                          (program) => DropdownMenuItem<String>(
                            value: program,
                            child: Text(program),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Program is required' : null,
                    onChanged: auth.isBusy
                        ? null
                        : (value) => setState(() => _selectedProgram = value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _studentIdController,
                    label: 'Student ID',
                    validator: (value) => _requiredValidator(value, 'Student ID'),
                  ),
                ],
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  validator: _passwordValidator,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  obscureText: _obscureConfirmPassword,
                  validator: _confirmPasswordValidator,
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: auth.isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    auth.isBusy ? 'Creating account...' : 'Sign up',
                    style: const TextStyle(
                      color: AppColors.brandWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      decoration: _inputDecoration(label).copyWith(suffixIcon: suffixIcon),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

