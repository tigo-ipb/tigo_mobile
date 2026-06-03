import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/dialogs/logout.dart';
import '../../../../shared/widgets/home_shimmer.dart';
import '../../../pemesan/views/login/role.dart';
import '../../models/organizer_dashboard_model.dart';
import '../../services/organizer_service.dart';
import 'dashboard_view.dart';
import 'scan_success_dialog.dart';
import 'scan_view.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  int _currentIndex = 0;
  bool _showScanError = false;
  String _scanErrorMessage = 'Silahkan hubungi administrator';

  // API State
  bool _isLoading = true;
  String? _errorMessage;
  OrganizerDashboardModel? _dashboardData;

  // Selected Event State for Scanning
  String? _selectedEventId;
  String? _selectedEventName;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fetch Organizer dashboard data
  Future<void> _loadDashboardData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await OrganizerService.fetchDashboard();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        if (!silent) {
          _errorMessage = e.toString();
        }
        _isLoading = false;
      });
    }
  }

  // Handle scanned/entered ticket verification
  Future<void> _validateTicket(String code) async {
    if (code.trim().isEmpty) return;
    if (_selectedEventId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih event terlebih dahulu.'),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await OrganizerService.scanTicket(
        qrCodeString: code,
        eventId: _selectedEventId!,
      );
      final status = res['status'] as String? ?? 'SUCCESS';
      final reason = res['reason'] as String? ?? 'Scan Berhasil';

      if (status == 'SUCCESS') {
        setState(() {
          _showScanError = false;
        });
        if (mounted) {
          // Display the custom "Tiket diterima" success dialog
          ScanSuccessDialog.show(context);
        }
      } else {
        setState(() {
          _showScanError = true;
          _scanErrorMessage = reason;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: $reason'),
              backgroundColor: AppColors.red500,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // In case of HTTP/Network or Validation exception
      setState(() {
        _showScanError = true;
        _scanErrorMessage = e.toString().replaceAll('Exception: ', '');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_scanErrorMessage),
            backgroundColor: AppColors.red500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      // Always refresh the dashboard data silently to show the new entry (even failed scans show on dashboard)
      _loadDashboardData(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Sub-screen 1: Dashboard View
            _isLoading && _dashboardData == null
                ? const OrganizerDashboardShimmer()
                : _errorMessage != null && _dashboardData == null
                ? _buildErrorScreen()
                : RefreshIndicator(
                    onRefresh: () => _loadDashboardData(silent: true),
                    color: AppColors.sky500,
                    child: OrganizerDashboardView(
                      dashboardData: _dashboardData!,
                      isLoading: _isLoading,
                    ),
                  ),
            // Sub-screen 2: Scan View
            OrganizerScanView(
              showScanError: _showScanError,
              scanErrorMessage: _scanErrorMessage,
              selectedEventId: _selectedEventId,
              selectedEventName: _selectedEventName,
              onEventSelected: (id, name) {
                setState(() {
                  _selectedEventId = id;
                  _selectedEventName = name;
                });
              },
              onBack: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              onCodeSubmit: _validateTicket,
              onClearError: () {
                setState(() {
                  _showScanError = false;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              TablerIcons.alertCircle,
              color: AppColors.red500,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: AppTextStyles.bold(18, AppColors.neutral900),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Terjadi kesalahan tidak dikenal.',
              style: AppTextStyles.regular(14, AppColors.neutral500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadDashboardData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sky500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text('Coba Lagi', style: AppTextStyles.semiBold(14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Item: Dashboard
          Expanded(
            child: InkWell(
              onTap: () {
                if (_currentIndex == 0) {
                  _loadDashboardData();
                } else {
                  setState(() {
                    _currentIndex = 0;
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    TablerIcons.layoutDashboard,
                    color: _currentIndex == 0
                        ? AppColors.sky500
                        : AppColors.neutral400,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dashboard',
                    style: AppTextStyles.medium(
                      12,
                      _currentIndex == 0
                          ? AppColors.sky500
                          : AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Item: Scan (Floating/Distinct Blue Icon)
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.sky500,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sky500.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      TablerIcons.scan,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Item: Keluar (Logout Dialog trigger)
          Expanded(
            child: InkWell(
              onTap: () async {
                final confirm = await LogoutDialog.show(context);
                if (confirm == true && context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleView()),
                    (route) => false,
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    TablerIcons.logout,
                    color: AppColors.red500,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keluar',
                    style: AppTextStyles.medium(12, AppColors.red500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
