import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/input.dart';
import '../../../../shared/widgets/custom_button.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  // Initial values to track changes
  String _initialName = 'Aryo Ristiawan Machfudz';
  String _initialDob = '15-12-2005';
  String _initialPhoneCode = '+62';
  String _initialPhone = '8576567793';
  String _initialEmail = 'aryoristiawan@apps.ipb.ac.id';

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _phoneCodeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  bool _isChanged = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialName);
    _dobController = TextEditingController(text: _initialDob);
    _phoneCodeController = TextEditingController(text: _initialPhoneCode);
    _phoneController = TextEditingController(text: _initialPhone);
    _emailController = TextEditingController(text: _initialEmail);

    // Listen to changes to enable/disable save button
    _nameController.addListener(_checkChanges);
    _dobController.addListener(_checkChanges);
    _phoneCodeController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
  }

  @override
  void dispose() {
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

  void _checkChanges() {
    final hasChanges =
        _nameController.text != _initialName ||
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
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Connect to Laravel API using http or dio package
      // Example:
      // final response = await http.put(
      //   Uri.parse('https://your-laravel-api.com/api/profile/update'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode({
      //     'name': _nameController.text,
      //     'dob': _dobController.text,
      //     'phone_code': _phoneCodeController.text,
      //     'phone': _phoneController.text,
      //     'email': _emailController.text,
      //   }),
      // );
      // if (response.statusCode == 200) { ... }

      // Simulated API response delay
      await Future.delayed(const Duration(seconds: 1500 ~/ 1000));

      if (!mounted) return;

      // Update baseline initial values on success
      setState(() {
        _initialName = _nameController.text;
        _initialDob = _dobController.text;
        _initialPhoneCode = _phoneCodeController.text;
        _initialPhone = _phoneController.text;
        _initialEmail = _emailController.text;
        _isChanged = false;
        _isLoading = false;
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan perubahan: $e'),
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
          child: Column(
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
                        style: AppTextStyles.regular(12, AppColors.neutral500),
                      ),
                      Text(
                        'Aryorm',
                        style: AppTextStyles.semiBold(24, AppColors.neutral950),
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
                              readOnly: _isLoading,
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
                              onTap: _isLoading
                                  ? null
                                  : () async {
                                      // Standard Date Picker for a premium user experience
                                      final DateTime?
                                      picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2005, 12, 15),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary: AppColors.sky500,
                                                    onPrimary: Colors.white,
                                                    onSurface:
                                                        AppColors.neutral900,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kode
                                SizedBox(
                                  width: 112,
                                  child: CustomInput(
                                    label: 'Kode',
                                    controller: _phoneCodeController,
                                    hintText: '+62',
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Icon(
                                        AppIcons.chevronDown,
                                        color: AppColors.neutral950,
                                        size: 20,
                                      ),
                                    ),
                                    readOnly: true,
                                    onTap: _isLoading
                                        ? null
                                        : () {
                                            // Optional code picker dialog in future, now just dummy tap response
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Pilihan kode negara',
                                                ),
                                                duration: Duration(seconds: 1),
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
                                    readOnly: _isLoading,
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
                              readOnly: _isLoading,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: CustomButton(
                  text: 'Simpan Perubahan',
                  onPressed: _saveChanges,
                  isLoading: _isLoading,
                  isDisabled: !_isChanged,
                  size: CustomButtonSize.large,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return SizedBox(width: double.infinity, child: child);
  }
}
