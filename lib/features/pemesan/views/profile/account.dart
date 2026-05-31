import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  // Countries code API state
  List<CountryModel> _countries = [];
  bool _isLoadingCountries = false;
  String? _countriesError;

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

    // Fetch countries data eagerly
    _fetchCountries();
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

  Future<void> _fetchCountries() async {
    if (_countries.isNotEmpty) return;
    setState(() {
      _isLoadingCountries = true;
      _countriesError = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://restcountries.com/v3.1/all?fields=name,idd,cca2,flags',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final parsed = data.map((json) => CountryModel.fromJson(json)).toList();

        // Sort alphabetically
        parsed.sort((a, b) => a.name.compareTo(b.name));

        // Filter out empty dialCode
        parsed.removeWhere((c) => c.dialCode.isEmpty);

        if (mounted) {
          setState(() {
            _countries = parsed;
            _isLoadingCountries = false;
          });
        }
      } else {
        throw Exception('Gagal memuat daftar negara.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _countriesError = 'Gagal memuat data negara. Silakan coba lagi.';
          _isLoadingCountries = false;
        });
      }
    }
  }

  void _showCountryCodePicker() {
    _fetchCountries();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double screenHeight = MediaQuery.of(context).size.height;

            final displayedCountries = _countries.where((c) {
              final term = searchQuery.toLowerCase();
              return c.name.toLowerCase().contains(term) ||
                  c.dialCode.contains(term) ||
                  c.code.toLowerCase().contains(term);
            }).toList();

            return Container(
              height: screenHeight * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Kode Negara',
                          style: AppTextStyles.semiBold(
                            18,
                            AppColors.neutral950,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            AppIcons.close,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari negara...',
                        hintStyle: AppTextStyles.regular(
                          14,
                          AppColors.neutral400,
                        ),
                        prefixIcon: Icon(
                          AppIcons.search,
                          color: AppColors.neutral400,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.neutral50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoadingCountries
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.sky500,
                            ),
                          )
                        : _countriesError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _countriesError!,
                                    style: AppTextStyles.regular(
                                      14,
                                      AppColors.red500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  CustomButton(
                                    text: 'Coba Lagi',
                                    size: CustomButtonSize.medium,
                                    onPressed: () async {
                                      setModalState(() {
                                        _isLoadingCountries = true;
                                        _countriesError = null;
                                      });
                                      await _fetchCountries();
                                      setModalState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : displayedCountries.isEmpty
                        ? Center(
                            child: Text(
                              'Negara tidak ditemukan',
                              style: AppTextStyles.regular(
                                14,
                                AppColors.neutral500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: displayedCountries.length,
                            itemBuilder: (context, index) {
                              final country = displayedCountries[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    country.flagUrl,
                                    width: 32,
                                    height: 20,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 32,
                                              height: 20,
                                              color: AppColors.neutral200,
                                              child: const Icon(
                                                Icons.flag,
                                                size: 14,
                                              ),
                                            ),
                                  ),
                                ),
                                title: Text(
                                  country.name,
                                  style: AppTextStyles.medium(
                                    16,
                                    AppColors.neutral950,
                                  ),
                                ),
                                trailing: Text(
                                  country.dialCode,
                                  style: AppTextStyles.semiBold(
                                    16,
                                    AppColors.neutral500,
                                  ),
                                ),
                                onTap: () {
                                  _phoneCodeController.text = country.dialCode;
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onProfileBlocChanged() {
    if (_profileBloc.status == ProfileStatus.loaded &&
        _profileBloc.user != null) {
      final user = _profileBloc.user!;

      if (!_isInitialized) {
        _nameController.text = user.name ?? '';

        // Tanggal lahir: yyyy-MM-dd -> DD-MM-YYYY untuk UI secara aman
        if (user.birthDate != null && user.birthDate!.isNotEmpty) {
          try {
            DateTime? parsedDate;
            if (user.birthDate!.contains('-')) {
              final parts = user.birthDate!.split('-');
              if (parts.length == 3) {
                if (parts[0].length == 4) {
                  parsedDate = DateTime.tryParse(user.birthDate!);
                } else if (parts[2].length == 4) {
                  parsedDate = DateTime.tryParse(
                    '${parts[2]}-${parts[1]}-${parts[0]}',
                  );
                }
              }
            }
            if (parsedDate != null) {
              final day = parsedDate.day.toString().padLeft(2, '0');
              final month = parsedDate.month.toString().padLeft(2, '0');
              _dobController.text = '$day-$month-${parsedDate.year}';
            } else {
              _dobController.text = user.birthDate!;
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
    // Format dob kembali ke yyyy-MM-dd untuk API secara aman
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

    final success = await _profileBloc.updateAccount(
      name: _nameController.text,
      email: _emailController.text,
      birthDate: dobApi ?? '',
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
              final isLoading =
                  _profileBloc.isLoading || _profileBloc.isUpdating;

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
                                            DateTime initialDate = DateTime(
                                              2005,
                                              12,
                                              15,
                                            );
                                            final dobText = _dobController.text;
                                            if (dobText.isNotEmpty) {
                                              try {
                                                final parts = dobText.split(
                                                  '-',
                                                );
                                                if (parts.length == 3) {
                                                  if (parts[2].length == 4) {
                                                    initialDate = DateTime(
                                                      int.parse(parts[2]),
                                                      int.parse(parts[1]),
                                                      int.parse(parts[0]),
                                                    );
                                                  } else if (parts[0].length ==
                                                      4) {
                                                    initialDate = DateTime(
                                                      int.parse(parts[0]),
                                                      int.parse(parts[1]),
                                                      int.parse(parts[2]),
                                                    );
                                                  }
                                                }
                                              } catch (_) {}
                                            }

                                            final DateTime?
                                            picked = await showDatePicker(
                                              context: context,
                                              initialDate: initialDate,
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime.now(),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme:
                                                        const ColorScheme.light(
                                                          primary:
                                                              AppColors.sky500,
                                                          onPrimary:
                                                              Colors.white,
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
                                              : _showCountryCodePicker,
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
                                    readOnly:
                                        true, // Email biasanya readOnly di edit akun
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

class CountryModel {
  final String name;
  final String code; // cca2
  final String dialCode;
  final String flagUrl;

  CountryModel({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagUrl,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<String, dynamic>?;
    final commonName = nameMap?['common'] as String? ?? '';
    final cca2 = json['cca2'] as String? ?? '';

    final idd = json['idd'] as Map<String, dynamic>?;
    final root = idd?['root'] as String? ?? '';
    final suffixes = idd?['suffixes'] as List<dynamic>? ?? [];
    String dialCode = root;
    if (root == '+1') {
      dialCode = '+1';
    } else if (suffixes.isNotEmpty) {
      dialCode = '$root${suffixes[0]}';
    }

    final flags = json['flags'] as Map<String, dynamic>?;
    final flagUrl = flags?['png'] as String? ?? '';

    return CountryModel(
      name: commonName,
      code: cca2,
      dialCode: dialCode,
      flagUrl: flagUrl,
    );
  }
}
