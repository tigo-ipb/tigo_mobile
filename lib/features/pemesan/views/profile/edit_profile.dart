import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/input.dart';
import '../../../../shared/widgets/custom_button.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  // Initial value to track changes
  String _initialUsername = 'Aryorm';
  final String _dummyAvatar =
      'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=256&auto=format&fit=crop';

  // Controller
  late final TextEditingController _usernameController;

  bool _isChanged = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: _initialUsername);
    _usernameController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_checkChanges);
    _usernameController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final hasChanges = _usernameController.text != _initialUsername;
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
      // Simulated API response delay
      await Future.delayed(const Duration(seconds: 1500 ~/ 1000));

      if (!mounted) return;

      setState(() {
        _initialUsername = _usernameController.text;
        _isChanged = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Profil berhasil diperbarui!'),
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
          content: Text('Gagal memperbarui profil: $e'),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _changePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilihan ubah foto profil'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
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
                            'Edit Profile',
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
                  child: Column(
                    children: [
                      // Circular Profile Avatar with edit badge
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(_dummyAvatar),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isLoading ? null : _changePhoto,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.sky50,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
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

                      // Username Input Field
                      CustomInput(
                        label: 'Username',
                        controller: _usernameController,
                        hintText: 'Masukkan username',
                        readOnly: _isLoading,
                      ),
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
}
