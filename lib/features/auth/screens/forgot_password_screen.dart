import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lexgo/services/auth_api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum PasswordResetStep { enterEmail, verifyOtp, resetPassword }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  PasswordResetStep _currentStep = PasswordResetStep.enterEmail;
  final AuthApiService _authService = AuthApiService();
  bool _isLoading = false;

  // Step 1 Controllers
  final _emailController = TextEditingController();

  // Step 2 Controllers
  final _otpController = TextEditingController();

  // Step 3 Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _authService.sendOtp(email: email);
      _showSuccess(res['message'] ?? 'OTP Sent successfully.');
      setState(() {
        _currentStep = PasswordResetStep.verifyOtp;
        _otpController.clear();
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      _showError('Please enter a valid 4-digit OTP code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _authService.verifyOtp(otpCode: otp);
      _showSuccess(res['message'] ?? 'OTP Verified successfully.');
      setState(() {
        _currentStep = PasswordResetStep.resetPassword;
      });
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (pass.isEmpty) {
      _showError('Password cannot be empty.');
      return;
    }
    if (pass.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }
    if (pass != confirm) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _authService.resetPassword(
        password: pass,
        confirmPassword: confirm,
      );
      _showSuccess(
        res['message'] ?? 'Password reset successfully. Please log in.',
      );
      if (!mounted) return;
      Navigator.pop(context); // Go back to Login Screen
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF0B162C),
                size: 16,
              ),
              onPressed: () {
                if (_currentStep == PasswordResetStep.resetPassword) {
                  setState(() => _currentStep = PasswordResetStep.verifyOtp);
                } else if (_currentStep == PasswordResetStep.verifyOtp) {
                  setState(() => _currentStep = PasswordResetStep.enterEmail);
                } else {
                  Navigator.pop(context); // Back to login screen
                }
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTitle(),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getSubtitle(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // ── Dynamic Layout Based on Step ──
              if (_currentStep == PasswordResetStep.enterEmail) ...[
                _buildInputField(
                  hint: 'Enter your Email',
                  icon: Icons.mail_outline,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),
                _buildSubmitButton('Verify', _handleSendOtp),
                const SizedBox(height: 48),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        children: [
                          TextSpan(text: 'Remember Password?'),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (_currentStep == PasswordResetStep.verifyOtp) ...[
                _buildOtpField(),
                const SizedBox(height: 32),
                _buildSubmitButton('Verify Code', _handleVerifyOtp),
                const SizedBox(height: 48),
                Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleSendOtp,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        children: [
                          TextSpan(text: "Didn't received code? "),
                          TextSpan(
                            text: 'Resend',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (_currentStep == PasswordResetStep.resetPassword) ...[
                _buildInputField(
                  hint: 'Enter New Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  hint: 'Confirm Password',
                  icon: null, // No icon specified in mockup for confirm
                  isPassword: true,
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 32),
                _buildSubmitButton('Reset password', _handleResetPassword),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case PasswordResetStep.enterEmail:
        return 'Forgot Password?';
      case PasswordResetStep.verifyOtp:
        return 'Verification';
      case PasswordResetStep.resetPassword:
        return 'Create new password';
    }
  }

  String _getSubtitle() {
    switch (_currentStep) {
      case PasswordResetStep.enterEmail:
        return "Don't worry! It happens. Please provide the email address associated with your account.";
      case PasswordResetStep.verifyOtp:
        return "Enter the verification code we just sent on your email address.";
      case PasswordResetStep.resetPassword:
        return "Your new password must be unique from those previously used.";
    }
  }

  Widget _buildInputField({
    required String hint,
    IconData? icon,
    bool isPassword = false,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF0B162C), size: 18)
              : null,
        ),
      ),
    );
  }

  Widget _buildOtpField() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            String digit = _otpController.text.length > index
                ? _otpController.text[index]
                : "";
            bool isFocused = _otpController.text.length == index ||
                (_otpController.text.length == 4 && index == 3);

            return Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused ? const Color(0xFF0B162C) : Colors.grey.shade400,
                  width: isFocused ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                digit,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            autofocus: true,
            style: GoogleFonts.poppins(color: Colors.transparent),
            cursorColor: Colors.transparent,
            onChanged: (v) => setState(() {}),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B162C),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

