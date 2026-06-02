import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/input.dart';
import '../../blocs/checkout_bloc.dart';
import '../../blocs/profile_bloc.dart';
import '../../models/event_detail_model.dart';
import '../../models/country_model.dart';
import '../../../../shared/dialogs/payment_success.dart';
import '../../../../main.dart';

class TicketIdentityView extends StatefulWidget {
  final EventDetailModel eventDetail;
  final List<TicketOrderItem> ticketItems;
  final int totalPrice;

  const TicketIdentityView({
    super.key,
    required this.eventDetail,
    required this.ticketItems,
    required this.totalPrice,
  });

  @override
  State<TicketIdentityView> createState() => _TicketIdentityViewState();
}

class _TicketIdentityViewState extends State<TicketIdentityView> {
  late final CheckoutBloc _checkoutBloc;
  late final ProfileBloc _profileBloc;
  bool _isInitialized = false;

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneCodeController = TextEditingController(text: '+62');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isAgreed = false;

  // Countries code API state
  List<CountryModel> _countries = [];
  bool _isLoadingCountries = false;
  String? _countriesError;

  @override
  void initState() {
    super.initState();
    _checkoutBloc = CheckoutBloc();
    _profileBloc = ProfileBloc();

    _nameController.addListener(_updateFormState);
    _dobController.addListener(_updateFormState);
    _phoneCodeController.addListener(_updateFormState);
    _phoneController.addListener(_updateFormState);
    _emailController.addListener(_updateFormState);

    _profileBloc.addListener(_onProfileBlocChanged);
    _profileBloc.fetchProfile();
    _fetchCountries();
  }

  @override
  void dispose() {
    _checkoutBloc.dispose();
    _profileBloc.removeListener(_onProfileBlocChanged);
    _profileBloc.dispose();

    _nameController.removeListener(_updateFormState);
    _dobController.removeListener(_updateFormState);
    _phoneCodeController.removeListener(_updateFormState);
    _phoneController.removeListener(_updateFormState);
    _emailController.removeListener(_updateFormState);

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

        _isInitialized = true;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void _updateFormState() {
    setState(() {});
  }

  Future<void> _fetchCountries() async {
    if (_countries.isNotEmpty) return;
    setState(() {
      _isLoadingCountries = true;
      _countriesError = null;
    });
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://restcountries.com/v3.1/all?fields=name,idd,cca2,flags',
            ),
          )
          .timeout(const Duration(seconds: 4));

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
        throw Exception('Gagal memuat.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _countries = CountryModel.defaultCountries;
          _isLoadingCountries = false;
        });
      }
    }
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _isAgreed;
  }

  String _formatPrice(int price) {
    if (price <= 0) return 'Rp.0';
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp.$formatted';
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime(2005, 12, 15);
    final dobText = _dobController.text;
    if (dobText.isNotEmpty) {
      final parts = dobText.split('-');
      if (parts.length == 3) {
        try {
          final year = int.parse(parts[2]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[0]);

          if (year >= 1900) {
            initialDate = DateTime(year, month, day);
          } else {
            // Might be yyyy-MM-dd format
            final altYear = int.parse(parts[0]);
            final altMonth = int.parse(parts[1]);
            final altDay = int.parse(parts[2]);
            if (altYear >= 1900) {
              initialDate = DateTime(altYear, altMonth, altDay);
            }
          }
        } catch (_) {
          // Keep fallback initialDate
        }
      }
    }

    final now = DateTime.now();
    if (initialDate.isBefore(DateTime(1900))) {
      initialDate = DateTime(1900);
    }
    if (initialDate.isAfter(now)) {
      initialDate = now;
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
                                AppColors.neutral50,
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

  Future<void> _onCheckout() async {
    if (!_isFormValid) return;

    // Format dob kembali ke yyyy-MM-dd untuk API
    String dobApi = '';
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

    final customerPhone = _phoneCodeController.text + _phoneController.text;

    final success = await _checkoutBloc.checkout(
      eventId: widget.eventDetail.id,
      ticketItems: widget.ticketItems,
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      customerPhone: customerPhone,
      customerBirthDate: dobApi,
    );

    if (!mounted) return;

    if (success) {
      final result = _checkoutBloc.result;
      if (widget.totalPrice == 0 ||
          result == null ||
          result.paymentUrl == null) {
        _showSuccessDialog();
      } else {
        final uri = Uri.tryParse(result.paymentUrl!);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showSuccessDialog();
        }
      }
    } else {
      _showErrorSnackBar(_checkoutBloc.errorMessage ?? 'Checkout gagal.');
    }
  }

  void _showSuccessDialog() {
    PaymentSuccessDialog.show(
      context,
      eventName: widget.eventDetail.name,
      onViewTicket: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialIndex: 2),
          ),
          (route) => false,
        );
      },
      onBackToHome: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(initialIndex: 0),
          ),
          (route) => false,
        );
      },
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.regular(13, Colors.white)),
        backgroundColor: AppColors.red500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([_profileBloc, _checkoutBloc]),
            builder: (context, _) {
              final isLoading =
                  _profileBloc.isLoading ||
                  _profileBloc.isUpdating ||
                  _checkoutBloc.isLoading;

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
                                'Pilih Ticket',
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
                              'Informasi tiket',
                              style: AppTextStyles.medium(
                                18,
                                AppColors.neutral950,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Fields Card/Container
                            SizedBox(
                              width: double.infinity,
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
                                        : () => _selectDate(context),
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
                                              : () => _showCountryCodePicker(),
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
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
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
                                    readOnly: isLoading,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Agreement Checkbox
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAgreed = !_isAgreed;
                                });
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: _isAgreed
                                          ? AppColors.sky500
                                          : Colors.white,
                                      border: Border.all(
                                        color: _isAgreed
                                            ? AppColors.sky500
                                            : AppColors.neutral950,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: _isAgreed
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text:
                                            'Saya telah membaca dan menyetujui ',
                                        style: AppTextStyles.regular(
                                          14,
                                          AppColors.neutral950,
                                        ).copyWith(height: 1.4),
                                        children: [
                                          TextSpan(
                                            text:
                                                'Ketentuan Layanan dan Kebijakan Privasi',
                                            style:
                                                AppTextStyles.regular(
                                                  14,
                                                  AppColors.neutral950,
                                                ).copyWith(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                  // Bottom Button Container
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: ListenableBuilder(
                      listenable: _checkoutBloc,
                      builder: (context, _) {
                        return CustomButton(
                          text: 'Bayar - ${_formatPrice(widget.totalPrice)}',
                          size: CustomButtonSize.large,
                          isDisabled: !_isFormValid,
                          isLoading: _checkoutBloc.isLoading,
                          onPressed: _onCheckout,
                          width: double.infinity,
                        );
                      },
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
