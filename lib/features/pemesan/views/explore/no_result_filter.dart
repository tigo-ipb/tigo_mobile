import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_theme.dart';

class NoResultFilter extends StatelessWidget {
  final bool isSearchMode;

  const NoResultFilter({super.key, required this.isSearchMode});

  @override
  Widget build(BuildContext context) {
    final String message = isSearchMode
        ? 'Maaf, hasil pencarian kamu tidak ditemui. Kamu bisa explore event lainnya!'
        : 'Maaf, tidak ada hasil yang cocok dengan filter kamu. Coba untuk reset filter!';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/amico_results.svg',
              height: 240,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(
                  14,
                  AppColors.neutral950,
                ).copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
