import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../core/constants/app_theme.dart';
import '../../services/organizer_service.dart';

class OrganizerScanView extends StatefulWidget {
  final bool showScanError;
  final String scanErrorMessage;
  final VoidCallback onBack;
  final Function(String) onCodeSubmit;
  final VoidCallback onClearError;
  final String? selectedEventId;
  final String? selectedEventName;
  final Function(String?, String?) onEventSelected;

  const OrganizerScanView({
    super.key,
    required this.showScanError,
    required this.scanErrorMessage,
    required this.onBack,
    required this.onCodeSubmit,
    required this.onClearError,
    required this.selectedEventId,
    required this.selectedEventName,
    required this.onEventSelected,
  });

  @override
  State<OrganizerScanView> createState() => _OrganizerScanViewState();
}

class _OrganizerScanViewState extends State<OrganizerScanView>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScannerActive = true;

  // Active Events State
  List<Map<String, dynamic>> _activeEvents = [];
  bool _isLoadingEvents = false;
  String? _eventsError;

  // Pending selection before confirm
  String? _pendingEventId;
  String? _pendingEventName;

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

    _loadActiveEvents();
  }

  Future<void> _loadActiveEvents() async {
    setState(() {
      _isLoadingEvents = true;
      _eventsError = null;
    });
    try {
      final events = await OrganizerService.fetchActiveEvents();
      if (mounted) {
        setState(() {
          _activeEvents = events;
          _isLoadingEvents = false;
        });

        // Auto-select if there is exactly 1 active event
        if (events.length == 1 && widget.selectedEventId == null) {
          final firstEvent = events.first;
          widget.onEventSelected(
            firstEvent['_id'] as String?,
            firstEvent['name'] as String?,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _eventsError = e.toString().replaceAll('Exception: ', '');
          _isLoadingEvents = false;
        });
      }
    }
  }

  Widget _buildEventErrorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.red50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red100),
      ),
      child: Column(
        children: [
          const Icon(
            TablerIcons.alertTriangle,
            color: AppColors.red500,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            _eventsError ?? 'Gagal memuat event aktif.',
            style: AppTextStyles.medium(14, AppColors.red500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadActiveEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoEventsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            TablerIcons.calendarOff,
            color: AppColors.neutral400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Event Aktif',
            style: AppTextStyles.bold(16, AppColors.neutral900),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda tidak memiliki event berstatus aktif yang sedang berjalan saat ini.',
            style: AppTextStyles.regular(14, AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Event Aktif',
            style: AppTextStyles.semiBold(14, AppColors.neutral900),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.neutral300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.neutral300),
              ),
              filled: true,
              fillColor: AppColors.neutral50,
            ),
            child: DropdownButton<String>(
              value: _pendingEventId,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              hint: Text(
                'Pilih salah satu event',
                style: AppTextStyles.regular(14, AppColors.neutral400),
              ),
              icon: const Icon(
                TablerIcons.chevronDown,
                color: AppColors.neutral500,
              ),
              borderRadius: BorderRadius.circular(12),
              items: _activeEvents.map((event) {
                return DropdownMenuItem<String>(
                  value: event['id'] as String?,
                  child: Text(
                    event['name'] as String? ?? '',
                    style: AppTextStyles.medium(14, AppColors.neutral900),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final selected = _activeEvents.firstWhere(
                    (e) => e['id'] == val,
                  );
                  setState(() {
                    _pendingEventId = val;
                    _pendingEventName = selected['name'] as String?;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _pendingEventId == null
                  ? null
                  : () => widget.onEventSelected(_pendingEventId, _pendingEventName),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sky500,
                disabledBackgroundColor: AppColors.neutral200,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Mulai Scan',
                style: AppTextStyles.semiBold(15, Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedEventId == null) {
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
            Text(
              'Pilih Event',
              style: AppTextStyles.bold(28, AppColors.neutral950),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih salah satu event aktif Anda di bawah ini untuk memulai proses scan tiket.',
              style: AppTextStyles.regular(14, AppColors.neutral500),
            ),
            const SizedBox(height: 32),
            if (_isLoadingEvents)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.sky500),
                  ),
                ),
              )
            else if (_eventsError != null)
              _buildEventErrorCard()
            else if (_activeEvents.isEmpty)
              _buildNoEventsCard()
            else
              _buildDropdownCard(),
          ],
        ),
      );
    }

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

          // Selected Event Pill Banner (Floating-like at the top)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.sky50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sky100),
            ),
            child: Row(
              children: [
                const Icon(
                  TablerIcons.calendarEvent,
                  color: AppColors.sky500,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.selectedEventName ?? 'Event terpilih',
                    style: AppTextStyles.bold(14, AppColors.sky700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onEventSelected(null, null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.sky200),
                    ),
                    child: Text(
                      'Ubah',
                      style: AppTextStyles.bold(12, AppColors.sky500),
                    ),
                  ),
                ),
              ],
            ),
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
                        if (!_isScannerActive) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String code = barcodes.first.rawValue ?? '';
                          if (code.isNotEmpty) {
                            // Stop scanner immediately after first detect
                            _scannerController.stop();
                            setState(() {
                              _isScannerActive = false;
                            });
                            widget.onCodeSubmit(code);
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    error.errorCode ==
                                            MobileScannerErrorCode
                                                .permissionDenied
                                        ? 'Izin kamera ditolak oleh pengguna.'
                                        : 'Perangkat kamera tidak ditemukan.',
                                    style: AppTextStyles.regular(
                                      12,
                                      AppColors.neutral400,
                                    ),
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

                  // Animated Scanning Laser Line (hanya saat aktif)
                  if (_isScannerActive)
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

                  // Overlay "Scan Lagi" saat scanner berhenti
                  if (!_isScannerActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              _scannerController.start();
                              setState(() {
                                _isScannerActive = true;
                              });
                              widget.onClearError();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sky500,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sky500.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    TablerIcons.scan,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Scan Lagi',
                                    style: AppTextStyles.semiBold(15, Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
