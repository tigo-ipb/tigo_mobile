import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/input.dart';
import '../../blocs/auth_bloc.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordView({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final AuthBloc _authBloc;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authBloc.dispose();
    super.dispose();
  }

  void _validateForm() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final isValid =
        password.isNotEmpty &&
        password.length >= 6 &&
        confirm.isNotEmpty &&
        password == confirm;
    setState(() {
      _isButtonEnabled = isValid;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    final success = await _authBloc.resetPassword(
      login: widget.email,
      otp: widget.otp,
      password: password,
      passwordConfirmation: confirm,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password Anda berhasil diubah! Silakan login kembali.',
          ),
          backgroundColor: AppColors.green500,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Pushing back to login/sign in
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authBloc.errorMessage ?? 'Gagal mereset password.'),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _authBloc,
          builder: (context, _) {
            final isLoading = _authBloc.isLoading;

            return Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.arrowNarrowLeft,
                              size: 24,
                              color: AppColors.neutral950,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reset Password',
                              style: AppTextStyles.medium(
                                16,
                                AppColors.neutral950,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),

                            // SVG Image
                            Center(
                              child: SvgPicture.asset(
                                'lib/assets/bro.svg',
                                height: 240,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // New Password Input
                            CustomInput(
                              label: 'Password Baru',
                              hintText: 'Masukkan password baru',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              readOnly: isLoading,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? TablerIcons.eyeOff
                                      : TablerIcons.eye,
                                  color: AppColors.neutral300,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password baru tidak boleh kosong';
                                }
                                if (value.length < 6) {
                                  return 'Password minimal harus 6 karakter';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password Input
                            CustomInput(
                              label: 'Konfirmasi Password',
                              hintText: 'Masukkan ulang password',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              readOnly: isLoading,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? TablerIcons.eyeOff
                                      : TablerIcons.eye,
                                  color: AppColors.neutral300,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Konfirmasi password tidak boleh kosong';
                                }
                                if (value != _passwordController.text) {
                                  return 'Konfirmasi password tidak sama';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: CustomButton(
                    text: 'Ganti',
                    size: CustomButtonSize.large,
                    width: double.infinity,
                    isLoading: isLoading,
                    isDisabled: !_isButtonEnabled,
                    onPressed: _handleSubmit,
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
