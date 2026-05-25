import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/dialogs/logout.dart';
import '../../blocs/profile_bloc.dart';
import '../../services/auth_service.dart';
import 'account.dart';
import 'edit_profile.dart';
import 'password.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
    _profileBloc.fetchProfile();
  }

  @override
  void dispose() {
    _profileBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _profileBloc.fetchProfile(),
          color: AppColors.sky500,
          child: ListenableBuilder(
            listenable: _profileBloc,
            builder: (context, _) {
              if (_profileBloc.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.sky500,
                  ),
                );
              }

              if (_profileBloc.status == ProfileStatus.error) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _profileBloc.errorMessage ?? 'Gagal memuat profil.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.regular(
                            14,
                            AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _profileBloc.fetchProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sky500,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final user = _profileBloc.user;

              if (user == null) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    child: Text(
                      'Data profil kosong.',
                      style: AppTextStyles.regular(14, AppColors.neutral500),
                    ),
                  ),
                );
              }

              final avatarUrl = user.profilePhoto != null &&
                      user.profilePhoto!.isNotEmpty
                  ? AppConstants.resolveImageUrl(user.profilePhoto)
                  : 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=256&auto=format&fit=crop';

              final displayName = user.name != null && user.name!.isNotEmpty
                  ? user.name!
                  : (user.username ?? 'Tigo User');

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title "Profile"
                    Text(
                      'Profile',
                      style: AppTextStyles.medium(24, AppColors.neutral950),
                    ),
                    const SizedBox(height: 24),

                    // Profile Avatar & Name
                    Center(
                      child: Column(
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
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            displayName,
                            style:
                                AppTextStyles.medium(20, AppColors.neutral950),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Edit Profile & Share Profile Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Edit Profile',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileView(),
                                ),
                              ).then((_) => _profileBloc.fetchProfile());
                            },
                            size: CustomButtonSize.small,
                            width: double.infinity,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomButton(
                            text: 'Share Profile',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.white,
                                  title: Text(
                                    'Informasi',
                                    style: AppTextStyles.semiBold(
                                      18,
                                      AppColors.neutral950,
                                    ),
                                  ),
                                  content: Text(
                                    'Maaf, fitur ini sedang dalam tahap pengembangan',
                                    style: AppTextStyles.regular(
                                      14,
                                      AppColors.neutral600,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Oke',
                                        style: AppTextStyles.medium(
                                          14,
                                          AppColors.sky500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            size: CustomButtonSize.small,
                            isOutlined: true,
                            width: double.infinity,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Menu Options Card (Akun, Bahasa, Password)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: AppColors.neutral300, width: 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: AppIcons.profile,
                            title: 'Akun',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AccountView(),
                                ),
                              ).then((_) => _profileBloc.fetchProfile());
                            },
                          ),
                          const Divider(
                            color: AppColors.neutral300,
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _buildMenuItem(
                            icon: AppIcons.language,
                            title: 'Bahasa',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bahasa Settings Clicked'),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            color: AppColors.neutral300,
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          _buildMenuItem(
                            icon: AppIcons.lock,
                            title: 'Password',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PasswordView(),
                                ),
                              ).then((_) => _profileBloc.fetchProfile());
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Log Out Button
                    CustomButton(
                      text: 'Log Out',
                      icon: AppIcons.logout,
                      onPressed: () async {
                        final confirmLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => const LogoutDialog(),
                        );

                        if (confirmLogout == true) {
                          await AuthService.logout();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Berhasil keluar dari akun'),
                            ),
                          );
                        }
                      },
                      size: CustomButtonSize.large,
                      isOutlined: true,
                      isDestroy: true,
                      width: double.infinity,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.sky50,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.sky500, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.medium(16, AppColors.neutral900),
            ),
            const Spacer(),
            Icon(AppIcons.chevronRight, color: AppColors.neutral900, size: 20),
          ],
        ),
      ),
    );
  }
}
