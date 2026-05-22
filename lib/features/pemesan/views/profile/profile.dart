import 'package:flutter/material.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'account.dart';
import 'edit_profile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Dummy data - will be connected to Laravel API later
  final String _dummyName = 'Aryorm';
  final String _dummyAvatar =
      'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=256&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                          image: NetworkImage(_dummyAvatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _dummyName,
                      style: AppTextStyles.medium(20, AppColors.neutral950),
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
                        );
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
                        // TODO: Implement Share Profile Action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share Profile Clicked'),
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
                  border: Border.all(color: AppColors.neutral300, width: 1),
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
                      icon: AppIcons.language,
                      title: 'Bahasa',
                      onTap: () {
                        // TODO: Navigate to Language Settings
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
                        // TODO: Navigate to Password Settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password Settings Clicked'),
                          ),
                        );
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
                onPressed: () {
                  // TODO: Implement Logout Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging Out...')),
                  );
                },
                size: CustomButtonSize.large,
                isOutlined: true,
                isDestroy: true,
                width: double.infinity,
              ),
            ],
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
            // Blue rounded background icon container
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
            // Menu Title
            Text(title, style: AppTextStyles.medium(16, AppColors.neutral900)),
            const Spacer(),
            // Trailing Chevron Icon
            Icon(AppIcons.chevronRight, color: AppColors.neutral900, size: 20),
          ],
        ),
      ),
    );
  }
}
