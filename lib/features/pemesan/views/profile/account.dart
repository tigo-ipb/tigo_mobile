import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/input.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../blocs/profile_bloc.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late final ProfileBloc _profileBloc;
  bool _isInitialized = false;

  // Initial values to track changes
  String _initialName = '';
  String _initialDob = '';
  String _initialPhoneCode = '+62';
  String _initialPhone = '';
  String _initialEmail = '';

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _phoneCodeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _phoneCodeController = TextEditingController(text: '+62');
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Listen to changes to enable/disable save button
    _nameController.addListener(_checkChanges);
    _dobController.addListener(_checkChanges);
    _phoneCodeController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);

    _profileBloc = ProfileBloc();
    _profileBloc.addListener(_onProfileBlocChanged);
    _profileBloc.fetchProfile();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_onProfileBlocChanged);
    _profileBloc.dispose();

    _nameController.removeListener(_checkChanges);
    _dobController.removeListener(_checkChanges);
    _phoneCodeController.removeListener(_checkChanges);
    _phoneController.removeListener(_checkChanges);
    _emailController.removeListener(_checkChanges);

    _nameController.dispose();
    _dobController.dispose();
    _phoneCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onProfileBlocChanged() {
    if (_profileBloc.status == ProfileStatus.loaded &&
        _profileBloc.user != null) {
      final user = _profileBloc.user!;

      if (!_isInitialized) {
        _nameController.text = user.name ?? '';

        // Tanggal lahir: yyyy-MM-dd -> DD-MM-YYYY untuk UI
        if (user.birthDate != null && user.birthDate!.isNotEmpty) {
          try {
            final parts = user.birthDate!.split('-');
            if (parts.length == 3) {
              if (parts[0].length == 4) {
                _dobController.text = '${parts[2]}-${parts[1]}-${parts[0]}';
              } else {
                _dobController.text = user.birthDate!;
              }
            }
          } catch (_) {
            _dobController.text = user.birthDate!;
          }
        }

        _phoneCodeController.text = user.phoneCode ?? '+62';
        _phoneController.text = user.phoneNumber ?? '';
        _emailController.text = user.email;

        _initialName = _nameController.text;
        _initialDob = _dobController.text;
        _initialPhoneCode = _phoneCodeController.text;
        _initialPhone = _phoneController.text;
        _initialEmail = _emailController.text;

        _isInitialized = true;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void _checkChanges() {
    final hasChanges = _nameController.text != _initialName ||
        _dobController.text != _initialDob ||
        _phoneCodeController.text != _initialPhoneCode ||
        _phoneController.text != _initialPhone ||
        _emailController.text != _initialEmail;

    if (_isChanged != hasChanges) {
      setState(() {
        _isChanged = hasChanges;
      });
    }
  }

  Future<void> _saveChanges() async {
    // Format dob kembali ke yyyy-MM-dd untuk API
    String? dobApi;
    final dobStr = _dobController.text;
    if (dobStr.isNotEmpty) {
      final parts = dobStr.split('-');
      if (parts.length == 3) {
        if (parts[0].length == 2) {
          dobApi = '${parts[2]}-${parts[1]}-${parts[0]}';
        } else {
          dobApi = dobStr;
        }
      }
    }

    final success = await _profileBloc.updateProfile(
      name: _nameController.text,
      birthDate: dobApi,
      phoneCode: _phoneCodeController.text,
      phoneNumber: _phoneController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _initialName = _nameController.text;
        _initialDob = _dobController.text;
        _initialPhoneCode = _phoneCodeController.text;
        _initialPhone = _phoneController.text;
        _initialEmail = _emailController.text;
        _isChanged = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Perubahan akun berhasil disimpan!'),
            ],
          ),
          backgroundColor: AppColors.green500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _profileBloc.errorMessage ?? 'Gagal menyimpan perubahan.',
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
              final isLoading = _profileBloc.isLoading || _profileBloc.isUpdating;

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
                                'Akun',
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
                  if (_profileBloc.isLoading && !_isInitialized)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.sky500,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi akun untuk:',
                              style: AppTextStyles.regular(
                                12,
                                AppColors.neutral500,
                              ),
                            ),
                            Text(
                              _profileBloc.user?.username ?? '-',
                              style: AppTextStyles.semiBold(
                                24,
                                AppColors.neutral950,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Account Fields Card
                            _buildCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama Field
                                  CustomInput(
                                    label: 'Nama',
                                    controller: _nameController,
                                    hintText: 'Masukkan nama lengkap',
                                    readOnly: isLoading,
                                  ),
                                  const SizedBox(height: 20),

                                  // Tanggal Lahir Field
                                  CustomInput(
                                    label: 'Tanggal Lahir',
                                    controller: _dobController,
                                    hintText: 'DD-MM-YYYY',
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Icon(
                                        AppIcons.calendar,
                                        color: AppColors.neutral300,
                                        size: 24,
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: isLoading
                                        ? null
                                        : () async {
                                            DateTime initialDate = DateTime(2005, 12, 15);
                                            final dobText = _dobController.text;
                                            if (dobText.isNotEmpty) {
                                              final parts = dobText.split('-');
                                              if (parts.length == 3) {
                                                initialDate = DateTime(
                                                  int.parse(parts[2]),
                                                  int.parse(parts[1]),
                                                  int.parse(parts[0]),
                                                );
                                              }
                                            }

                                            final DateTime? picked =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: initialDate,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime.now(),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    colorScheme:
                                                        const ColorScheme.light(
                                                      primary: AppColors.sky500,
                                                      onPrimary: Colors.white,
                                                      onSurface: AppColors
                                                          .neutral900,
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                final day = picked.day
                                                    .toString()
                                                    .padLeft(2, '0');
                                                final month = picked.month
                                                    .toString()
                                                    .padLeft(2, '0');
                                                _dobController.text =
                                                    '$day-$month-${picked.year}';
                                              });
                                            }
                                          },
                                  ),
                                  const SizedBox(height: 20),

                                  // Code & Phone Number Fields (Side-by-side)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Kode
                                      SizedBox(
                                        width: 112,
                                        child: CustomInput(
                                          label: 'Kode',
                                          controller: _phoneCodeController,
                                          hintText: '+62',
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            child: Icon(
                                              AppIcons.chevronDown,
                                              color: AppColors.neutral950,
                                              size: 20,
                                            ),
                                          ),
                                          readOnly: true,
                                          onTap: isLoading
                                              ? null
                                              : () {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Pilihan kode negara',
                                                      ),
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );
                                                },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Nomor Handphone
                                      Expanded(
                                        child: CustomInput(
                                          label: 'Nomor Handphone',
                                          controller: _phoneController,
                                          hintText: '8xxxxxxxxxx',
                                          keyboardType: TextInputType.phone,
                                          readOnly: isLoading,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Email Field
                                  CustomInput(
                                    label: 'Email',
                                    controller: _emailController,
                                    hintText: 'nama@domain.com',
                                    keyboardType: TextInputType.emailAddress,
                                    readOnly: true, // Email biasanya readOnly di edit akun
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                  // Bottom Button container
                  if (!_profileBloc.isLoading || _isInitialized)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: CustomButton(
                        text: 'Simpan Perubahan',
                        onPressed: _saveChanges,
                        isLoading: _profileBloc.isUpdating,
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

  Widget _buildCard({required Widget child}) {
    return SizedBox(width: double.infinity, child: child);
  }
}
