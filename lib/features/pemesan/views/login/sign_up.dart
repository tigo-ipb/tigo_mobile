import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/input.dart';
import 'dart:math' as math;
import '../../blocs/auth_bloc.dart';
import 'verifikasi.dart';

class SignUpView extends StatefulWidget {
  final String role;

  const SignUpView({super.key, required this.role});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _authBloc.dispose();
    super.dispose();
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
                              'Masuk',
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Buat Akun Baru',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.semiBold(
                                      32,
                                      AppColors.sky500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Buat akun untuk menikmati tigo, mulai dari info event sampai pemesanan tiket event.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.regular(
                                      14,
                                      AppColors.neutral500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Username Input
                            CustomInput(
                              label: 'Username',
                              hintText: 'Masukkan username',
                              controller: _usernameController,
                              readOnly: isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

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
                            const SizedBox(height: 20),

                            // Password Input
                            CustomInput(
                              label: 'Password',
                              hintText: 'Masukkan password',
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
                                  return 'Password tidak boleh kosong';
                                }
                                if (value.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Sign Up Button (Buat)
                            CustomButton(
                              text: 'Buat',
                              size: CustomButtonSize.large,
                              width: double.infinity,
                              isLoading: isLoading,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await _authBloc.register(
                                    username: _usernameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                  if (!context.mounted) return;
                                  if (success) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VerificationView(
                                          email: _emailController.text,
                                          role: widget.role,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _authBloc.errorMessage ??
                                              'Pendaftaran gagal',
                                        ),
                                        backgroundColor: AppColors.red500,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            // Divider "atau"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.neutral200,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    'atau',
                                    style: AppTextStyles.regular(
                                      14,
                                      AppColors.neutral500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.neutral200,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Google Login Button
                            CustomButton(
                              text: 'Lanjutkan dengan Google',
                              size: CustomButtonSize.large,
                              isOutlined: true,
                              backgroundColor: AppColors.neutral300,
                              textColor: AppColors.neutral900,
                              width: double.infinity,
                              leadingWidget: const GoogleIcon(size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Lanjutkan dengan Google dipilih',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 48),

                            // Footer links
                            Center(
                              child: Column(
                                children: [
                                  // Lupa password
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Lupa password? ',
                                        style: AppTextStyles.regular(
                                          14,
                                          AppColors.neutral500,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Navigate to Forgot Password View
                                        },
                                        child: Text(
                                          'Klik di sini',
                                          style: AppTextStyles.medium(
                                            14,
                                            AppColors.sky500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Sudah punya akun
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sudah punya akun? ',
                                        style: AppTextStyles.regular(
                                          14,
                                          AppColors.neutral500,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Masuk',
                                          style: AppTextStyles.medium(
                                            14,
                                            AppColors.sky500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

// Google G Icon Painter
class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double r = w / 2;

    final center = Offset(r, r);

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final strokeR = r - (w * 0.11);
    final rect = Rect.fromCircle(center: center, radius: strokeR);

    canvas.drawArc(
      rect,
      135 * math.pi / 180,
      90 * math.pi / 180,
      false,
      yellowPaint,
    );
    canvas.drawArc(
      rect,
      45 * math.pi / 180,
      90 * math.pi / 180,
      false,
      greenPaint,
    );
    canvas.drawArc(
      rect,
      220 * math.pi / 180,
      95 * math.pi / 180,
      false,
      redPaint,
    );
    canvas.drawArc(
      rect,
      -45 * math.pi / 180,
      90 * math.pi / 180,
      false,
      bluePaint,
    );

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(r, r - (w * 0.11), r + strokeR, r + (w * 0.11)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
