import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/input.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../blocs/profile_bloc.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final ProfileBloc _profileBloc;
  bool _isInitialized = false;

  // Initial value to track changes
  String _initialUsername = '';

  // Controller
  late final TextEditingController _usernameController;

  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _usernameController.addListener(_checkChanges);

    _profileBloc = ProfileBloc();
    _profileBloc.addListener(_onProfileBlocChanged);
    _profileBloc.fetchProfile();
  }

  @override
  void dispose() {
    _profileBloc.removeListener(_onProfileBlocChanged);
    _profileBloc.dispose();

    _usernameController.removeListener(_checkChanges);
    _usernameController.dispose();
    super.dispose();
  }

  void _onProfileBlocChanged() {
    if (_profileBloc.status == ProfileStatus.loaded &&
        _profileBloc.user != null) {
      final user = _profileBloc.user!;
      if (!_isInitialized) {
        _usernameController.text = user.username ?? '';
        _initialUsername = _usernameController.text;
        _isInitialized = true;
        if (mounted) {
          setState(() {});
        }
      }
    }
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
    final success = await _profileBloc.updateProfile(
      username: _usernameController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _initialUsername = _usernameController.text;
        _isChanged = false;
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _profileBloc.errorMessage ?? 'Gagal memperbarui profil.',
          ),
          backgroundColor: AppColors.red500,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

      final success = await _profileBloc.updateProfile(
        username: _usernameController.text,
        profilePhoto: pickedFile,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Foto profil berhasil diperbarui!'),
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
              _profileBloc.errorMessage ?? 'Gagal memperbarui foto profil.',
            ),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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

              final avatarUrl =
                  _profileBloc.user?.profilePhoto != null &&
                      _profileBloc.user!.profilePhoto!.isNotEmpty
                  ? AppConstants.resolveImageUrl(
                      _profileBloc.user!.profilePhoto,
                    )
                  : 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=256&auto=format&fit=crop';

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
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: NetworkImage(avatarUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: isLoading ? null : _changePhoto,
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
                              readOnly: isLoading,
                            ),
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
}
