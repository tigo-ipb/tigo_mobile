import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/input.dart';
import 'sign_up.dart';
import 'verifikasi.dart';
import 'forget_password.dart';
import 'setup_account.dart';
import '../../../../main.dart';
import '../../blocs/auth_bloc.dart';
import 'dart:math' as math;
import '../../../penyelenggara/views/dashboard/organizer_dashboard.dart';

class SignInView extends StatefulWidget {
  final String role;

  const SignInView({super.key, required this.role});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AuthBloc _authBloc;
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? '215018091868-ao9di7709r6grl6nv1ganlmqa9jgenas.apps.googleusercontent.com'
          : null,
      // serverClientId di-set null khusus jika berjalan di Web (kIsWeb)
      serverClientId: kIsWeb
          ? '215018091868-ao9di7709r6grl6nv1ganlmqa9jgenas.apps.googleusercontent.com'
          : null,
      scopes: const ['email', 'profile'],
    );
  }

  @override
  void dispose() {
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
                              'Role',
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
                                    'Selamat Datang!',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.semiBold(
                                      32,
                                      AppColors.sky500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Apakah kamu siap untuk event selanjutnya?',
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

                            // Username/Email Input
                            CustomInput(
                              label: 'Username/Email',
                              hintText: 'Masukkan username/email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              readOnly: isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username atau Email tidak boleh kosong';
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
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Sign In Button
                            CustomButton(
                              text: 'Masuk',
                              size: CustomButtonSize.large,
                              width: double.infinity,
                              isLoading: isLoading,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await _authBloc.login(
                                    login: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                  if (!context.mounted) return;

                                  if (success) {
                                    // Cek apakah user login sebagai organizer atau customer
                                    if (widget.role == 'organizer') {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const OrganizerDashboard(),
                                        ),
                                        (route) => false,
                                      );
                                    } else {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } else {
                                    final errorMessage =
                                        _authBloc.errorMessage ?? '';
                                    final isUnverified =
                                        errorMessage.toLowerCase().contains(
                                          'verifikasi',
                                        ) ||
                                        errorMessage.toLowerCase().contains(
                                          'verify',
                                        ) ||
                                        errorMessage.toLowerCase().contains(
                                          'otp',
                                        ) ||
                                        errorMessage.toLowerCase().contains(
                                          'belum aktif',
                                        ) ||
                                        errorMessage.toLowerCase().contains(
                                          'aktifkan',
                                        );

                                    if (isUnverified) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VerificationView(
                                                email: _emailController.text,
                                                role: widget.role,
                                              ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            errorMessage.isNotEmpty
                                                ? errorMessage
                                                : 'Gagal masuk. Periksa kembali kredensial Anda.',
                                          ),
                                          backgroundColor: AppColors.red500,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
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
                              isLoading: isLoading,
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      try {
                                        try {
                                          await _googleSignIn.disconnect();
                                        } catch (
                                          _
                                        ) {} // Abaikan jika belum pernah login

                                        // await _googleSignIn.signOut();
                                        final GoogleSignInAccount? googleUser =
                                            await _googleSignIn.signIn();
                                        if (googleUser == null) {
                                          return;
                                        }

                                        final GoogleSignInAuthentication
                                        googleAuth =
                                            await googleUser.authentication;

                                        final String? idToken =
                                            googleAuth.idToken;
                                        final String? accessToken =
                                            googleAuth.accessToken;

                                        print("=== DEBUG GOOGLE LOGIN ====");
                                        print("ID Token: $idToken");
                                        print("Access Token: $accessToken");
                                        print("============================");

                                        // Terkadang di Web, idToken null tapi accessToken ada.
                                        // Kita ambil mana saja yang tersedia untuk dikirim ke backend.
                                        final String? tokenToSend =
                                            idToken ?? accessToken;

                                        if (tokenToSend == null) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Gagal mendapatkan token dari Google.',
                                              ),
                                              backgroundColor: AppColors.red500,
                                            ),
                                          );
                                          return;
                                        }

                                        final success = await _authBloc
                                            .googleLogin(idToken: tokenToSend);

                                        if (!context.mounted) return;

                                        if (success) {
                                          if (_authBloc.status ==
                                              AuthStatus.needsSetup) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SetupAccountView(
                                                      role: widget.role,
                                                      email:
                                                          _authBloc.user?.email,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            if (widget.role == 'organizer') {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const OrganizerDashboard(),
                                                ),
                                                (route) => false,
                                              );
                                            } else {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MainScreen(),
                                                ),
                                                (route) => false,
                                              );
                                            }
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                _authBloc.errorMessage ??
                                                    'Gagal masuk dengan Google.',
                                              ),
                                              backgroundColor: AppColors.red500,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      } catch (error) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error Google Sign-In: $error',
                                            ),
                                            backgroundColor: AppColors.red500,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgetPasswordView(
                                                    role: widget.role,
                                                  ),
                                            ),
                                          );
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
                                  // Belum punya akun
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Belum punya akun? ',
                                        style: AppTextStyles.regular(
                                          14,
                                          AppColors.neutral500,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpView(role: widget.role),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Buat akun',
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
