import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../core/constants/app_theme.dart';

class OrganizerScanView extends StatefulWidget {
  final bool showScanError;
  final String scanErrorMessage;
  final VoidCallback onBack;
  final Function(String) onCodeSubmit;
  final VoidCallback onClearError;

  const OrganizerScanView({
    super.key,
    required this.showScanError,
    required this.scanErrorMessage,
    required this.onBack,
    required this.onCodeSubmit,
    required this.onClearError,
  });

  @override
  State<OrganizerScanView> createState() => _OrganizerScanViewState();
}

class _OrganizerScanViewState extends State<OrganizerScanView>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  final MobileScannerController _scannerController = MobileScannerController();
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(
      begin: 0.05,
      end: 0.95,
    ).animate(_laserController);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button "Kembali"
          GestureDetector(
            onTap: widget.onBack,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  TablerIcons.arrowNarrowLeft,
                  color: AppColors.neutral950,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kembali',
                  style: AppTextStyles.medium(16, AppColors.neutral950),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Header: Scan Tiket
          Text(
            'Scan Tiket',
            style: AppTextStyles.bold(28, AppColors.neutral950),
          ),
          const SizedBox(height: 8),

          // Subtitle instruction
          Text(
            'Scan tiket pengunjung untuk validasi tiket. Jika terjadi masalah terhadap tiket, kontak administrator.',
            style: AppTextStyles.regular(14, AppColors.neutral500),
          ),
          const SizedBox(height: 24),

          // QR Scanner Bracket & Preview Container
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.sky300, width: 1.5),
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Live Camera Preview using mobile_scanner
                  Positioned.fill(
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String code = barcodes.first.rawValue ?? '';
                          if (code.isNotEmpty) {
                            // Debounce scan events to prevent duplicate validation requests
                            final now = DateTime.now();
                            if (_lastScanTime == null ||
                                now.difference(_lastScanTime!) >
                                    const Duration(seconds: 3)) {
                              _lastScanTime = now;
                              widget.onCodeSubmit(code);
                            }
                          }
                        }
                      },
                      errorBuilder: (context, error) {
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  TablerIcons.cameraOff,
                                  color: AppColors.red400,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Gagal memuat kamera',
                                  style: AppTextStyles.medium(14, Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    error.errorCode == MobileScannerErrorCode.permissionDenied
                                        ? 'Izin kamera ditolak oleh pengguna.'
                                        : 'Perangkat kamera tidak ditemukan.',
                                    style: AppTextStyles.regular(12, AppColors.neutral400),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Four Scanner Corners Overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ScannerBracketPainter(color: AppColors.sky500),
                    ),
                  ),

                  // Animated Scanning Laser Line
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 300 * _laserAnimation.value,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.sky500,
                            borderRadius: BorderRadius.circular(1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.sky500.withValues(alpha: 0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Flashlight (Torch) Toggle Button
          Center(
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                final isTorchOn = state.torchState == TorchState.on;
                return GestureDetector(
                  onTap: () => _scannerController.toggleTorch(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 100,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isTorchOn ? AppColors.sky100 : Colors.white,
                      border: Border.all(color: AppColors.sky500, width: 1.5),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        if (isTorchOn)
                          BoxShadow(
                            color: AppColors.sky500.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isTorchOn ? TablerIcons.bolt : TablerIcons.boltOff,
                        color: AppColors.sky500,
                        size: 22,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Simulated Warning Card (Failure Condition)
          if (widget.showScanError) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red50,
                border: Border.all(color: AppColors.red100, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    TablerIcons.alertCircle,
                    color: AppColors.red500,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terjadi masalah!',
                          style: AppTextStyles.bold(14, AppColors.red500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.scanErrorMessage,
                          style: AppTextStyles.regular(12, AppColors.red500),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onClearError,
                    child: const Icon(
                      TablerIcons.x,
                      color: AppColors.red400,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

// Custom Painter for drawing brackets around scanning area
class _ScannerBracketPainter extends CustomPainter {
  final Color color;
  _ScannerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerSize = 30.0;
    const double offset = 40.0;

    // Top-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(offset, offset + cornerSize)
        ..lineTo(offset, offset)
        ..lineTo(offset + cornerSize, offset),
      paint,
    );

    // Top-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - offset - cornerSize, offset)
        ..lineTo(size.width - offset, offset)
        ..lineTo(size.width - offset, offset + cornerSize),
      paint,
    );

    // Bottom-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(offset, size.height - offset - cornerSize)
        ..lineTo(offset, size.height - offset)
        ..lineTo(offset + cornerSize, size.height - offset),
      paint,
    );

    // Bottom-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - offset - cornerSize, size.height - offset)
        ..lineTo(size.width - offset, size.height - offset)
        ..lineTo(size.width - offset, size.height - offset - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
