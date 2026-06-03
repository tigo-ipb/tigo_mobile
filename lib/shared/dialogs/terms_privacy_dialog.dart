import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../widgets/custom_button.dart';

class TermsPrivacyDialog extends StatelessWidget {
  const TermsPrivacyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const TermsPrivacyDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final double blurValue = animation.value * 6.0;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.neutral100, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ketentuan & Kebijakan',
                      style: AppTextStyles.semiBold(18, AppColors.neutral950),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      AppIcons.close,
                      color: AppColors.neutral500,
                      size: 20,
                    ),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dengan melanjutkan transaksi, Anda menyetujui hal-hal berikut:',
                      style: AppTextStyles.medium(
                        14,
                        AppColors.neutral600,
                      ).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // 1. Pembelian & Pengembalian Dana
                    _buildSection(
                      title: 'Pembelian & Pengembalian Dana',
                      description:
                          'Seluruh transaksi bersifat final. TIGO tidak melayani pengembalian dana (refund). Apabila acara dibatalkan, proses pengembalian dana akan diurus secara manual oleh Panitia Penyelenggara (biaya layanan platform tidak dapat dikembalikan).',
                    ),
                    const Divider(color: AppColors.neutral100, height: 32),

                    // 2. Check-In & Tiket
                    _buildSection(
                      title: 'Check-In & Tiket',
                      description:
                          'E-Ticket hanya sah jika dibeli melalui platform resmi TIGO. Saat check-in di lokasi, nama pada tiket wajib sesuai dengan Kartu Identitas asli (KTP/KTM/SIM). Tiket pada dasarnya tidak dapat dipindahtangankan.',
                    ),
                    const Divider(color: AppColors.neutral100, height: 32),

                    // 3. Privasi Data
                    _buildSection(
                      title: 'Privasi Data',
                      description:
                          'Data diri Anda (Email, Nomor WhatsApp) disimpan secara aman, tidak akan dijual, dan hanya digunakan untuk pengiriman E-Ticket, notifikasi, serta keperluan operasional panitia.',
                    ),
                    const Divider(color: AppColors.neutral100, height: 32),

                    // 4. Aturan & Keamanan
                    _buildSection(
                      title: 'Aturan & Keamanan',
                      description:
                          'Panitia berhak menolak akses masuk jika Anda melanggar aturan acara atau membawa barang terlarang. Tindakan manipulasi, kecurangan, atau peretasan sistem TIGO akan ditindak tegas.',
                    ),
                  ],
                ),
              ),
            ),

            // Footer Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.neutral100, width: 1),
                ),
              ),
              child: CustomButton(
                text: 'Saya Mengerti',
                onPressed: () => Navigator.pop(context),
                size: CustomButtonSize.large,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.semiBold(14, AppColors.neutral950)),
        const SizedBox(height: 8),
        Text(
          description,
          style: AppTextStyles.regular(
            13,
            AppColors.neutral600,
          ).copyWith(height: 1.5),
        ),
      ],
    );
  }
}
