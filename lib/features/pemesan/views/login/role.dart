import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import 'sign_in.dart';

class RoleView extends StatelessWidget {
  const RoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Masuk Sebagai',
                textAlign: TextAlign.center,
                style: AppTextStyles.semiBold(32, AppColors.sky500),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih role yang sesuai dengan kamu',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(14, AppColors.neutral500),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'Pemesan',
                isOutlined: true,
                size: CustomButtonSize.large,
                width: double.infinity,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInView(role: 'customer'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Penyelenggara',
                isOutlined: true,
                size: CustomButtonSize.large,
                width: double.infinity,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInView(role: 'organizer'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
