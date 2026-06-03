import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/input.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../blocs/profile_bloc.dart';

class PasswordView extends StatefulWidget {
  const PasswordView({super.key});

  @override
  State<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final ProfileBloc _profileBloc;

  // Controllers (Ditambah satu untuk konfirmasi)
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  // State flags
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true; // Flag untuk mata konfirmasi
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Listen to changes to enable/disable button
    _currentPasswordController.addListener(_checkChanges);
    _newPasswordController.addListener(_checkChanges);
    _confirmPasswordController.addListener(_checkChanges);

    _profileBloc = ProfileBloc();
  }

  @override
  void dispose() {
    _profileBloc.dispose();

    _currentPasswordController.removeListener(_checkChanges);
    _newPasswordController.removeListener(_checkChanges);
    _confirmPasswordController.removeListener(_checkChanges);

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final isValid =
        _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    if (_isChanged != isValid) {
      setState(() {
        _isChanged = isValid;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Pastikan Password Baru dan Konfirmasi sama persis (Validasi Ekstra)
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Konfirmasi password tidak cocok dengan password baru.',
          ),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await _profileBloc.updatePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation:
          _confirmPasswordController.text, // Menggunakan controller yang benar
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _isChanged = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Password berhasil diperbarui!'),
            ],
          ),
          backgroundColor: AppColors.green500,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _profileBloc.errorMessage ?? 'Gagal memperbarui password.',
          ),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _profileBloc,
            builder: (context, _) {
              final isLoading = _profileBloc.isUpdating;

              return Column(
                children: [
                  // Custom Header using specified format style
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
                                'Password',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Password Saat Ini Input
                            CustomInput(
                              label: 'Password Saat Ini',
                              controller: _currentPasswordController,
                              hintText: '************',
                              obscureText: _obscureCurrentPassword,
                              readOnly: isLoading,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureCurrentPassword =
                                        !_obscureCurrentPassword;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Icon(
                                    _obscureCurrentPassword
                                        ? TablerIcons.eyeOff
                                        : TablerIcons.eye,
                                    color: AppColors.neutral300,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password saat ini tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Password Baru Input
                            CustomInput(
                              label: 'Password Baru',
                              controller: _newPasswordController,
                              hintText: 'Masukkan password baru',
                              obscureText: _obscureNewPassword,
                              readOnly: isLoading,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Icon(
                                    _obscureNewPassword
                                        ? TablerIcons.eyeOff
                                        : TablerIcons.eye,
                                    color: AppColors.neutral300,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password baru tidak boleh kosong';
                                }
                                if (value.length < 8) {
                                  return 'Password baru minimal 8 karakter';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Konfirmasi Password Baru Input
                            CustomInput(
                              label: 'Konfirmasi Password Baru',
                              controller: _confirmPasswordController,
                              hintText: 'Masukkan ulang password baru',
                              obscureText: _obscureConfirmPassword,
                              readOnly: isLoading,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Icon(
                                    _obscureConfirmPassword
                                        ? TablerIcons.eyeOff
                                        : TablerIcons.eye,
                                    color: AppColors.neutral300,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Konfirmasi password tidak boleh kosong';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Password tidak cocok';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Button container
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: CustomButton(
                      text: 'Update Password',
                      onPressed: _updatePassword,
                      isLoading: isLoading,
                      isDisabled: !_isChanged,
                      size: CustomButtonSize.large,
                      width: double.infinity,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
