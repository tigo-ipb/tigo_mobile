import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/input.dart';
import '../../../../main.dart';

class SetupAccountView extends StatefulWidget {
  final String role;

  const SetupAccountView({super.key, required this.role});

  @override
  State<SetupAccountView> createState() => _SetupAccountViewState();
}

class _SetupAccountViewState extends State<SetupAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneCodeController = TextEditingController(text: '+62');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Profile photo state
  XFile? _profilePhoto;

  // Countries code API state
  List<CountryModel> _countries = [];
  bool _isLoadingCountries = false;
  String? _countriesError;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _usernameController.dispose();
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

  Future<void> _changePhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _profilePhoto = pickedFile;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Foto profil berhasil dipilih!'),
            ],
          ),
          backgroundColor: AppColors.green500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowNarrowLeft, color: AppColors.neutral950),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Setup Akun',
          style: AppTextStyles.medium(18, AppColors.neutral950),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular Profile Avatar with edit badge
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _profilePhoto != null
                              ? (kIsWeb
                                    ? Image.network(
                                        _profilePhoto!.path,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(_profilePhoto!.path),
                                        fit: BoxFit.cover,
                                      ))
                              : CustomPaint(painter: CheckerboardPainter()),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _changePhoto,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.sky50,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              AppIcons.edit,
                              size: 16,
                              color: AppColors.sky500,
                            ),
                          ),
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Nama Input
                CustomInput(
                  label: 'Nama',
                  hintText: 'Masukkan nama',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
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
                  onTap: () async {
                    DateTime initialDate = DateTime(2005, 12, 15);
                    final dobText = _dobController.text;
                    if (dobText.isNotEmpty) {
                      try {
                        final parts = dobText.split('-');
                        if (parts.length == 3) {
                          if (parts[2].length == 4) {
                            initialDate = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                          } else if (parts[0].length == 4) {
                            initialDate = DateTime(
                              int.parse(parts[0]),
                              int.parse(parts[1]),
                              int.parse(parts[2]),
                            );
                          }
                        }
                      } catch (_) {}
                    }

                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.sky500,
                              onPrimary: Colors.white,
                              onSurface: AppColors.neutral900,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        final day = picked.day.toString().padLeft(2, '0');
                        final month = picked.month.toString().padLeft(2, '0');
                        _dobController.text = '$day-$month-${picked.year}';
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tanggal lahir tidak boleh kosong';
                    }
                    return null;
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
                        onTap: _showCountryCodePicker,
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor handphone tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email Input
                CustomInput(
                  label: 'Email',
                  hintText: 'Masukkan email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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

                // Buat Akun Button
                CustomButton(
                  text: 'Buat Akun',
                  size: CustomButtonSize.large,
                  width: double.infinity,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Akun berhasil dibuat!'),
                          backgroundColor: AppColors.green500,
                        ),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE5E5E5);
    final bgPaint = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    double step = 8;
    for (double i = 0; i < size.width; i += step) {
      for (double j = 0; j < size.height; j += step) {
        if ((i / step).floor() % 2 == (j / step).floor() % 2) {
          canvas.drawRect(Rect.fromLTWH(i, j, step, step), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
