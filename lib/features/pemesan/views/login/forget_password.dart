import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/input.dart';
import '../../blocs/auth_bloc.dart';

class ForgetPasswordView extends StatefulWidget {
  final String role;

  const ForgetPasswordView({super.key, required this.role});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final AuthBloc _authBloc;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _authBloc.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();
    final isValid =
        email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    setState(() {
      _isButtonEnabled = isValid;
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await _authBloc.forgotPassword(login: email);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email konfirmasi reset password berhasil dikirim!'),
          backgroundColor: AppColors.green500,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _authBloc.errorMessage ?? 'Gagal mengirim email reset password.',
          ),
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
                              'Lupa Password',
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

                // Main Form Content
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
                                'lib/assets/amico.svg',
                                height: 240,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Description Text
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'Kamu akan dikirimkan email untuk konfirmasi reset password',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.regular(
                                  14,
                                  AppColors.neutral950,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email Input
                            CustomInput(
                              label: 'Email',
                              hintText: 'Masukkan email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              readOnly: isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value.trim())) {
                                  return 'Format email tidak valid';
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
                    text: 'Kirim',
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
