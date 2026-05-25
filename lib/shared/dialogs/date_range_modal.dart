import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';
import '../widgets/custom_button.dart';

class DateRangeModal extends StatefulWidget {
  final DateTimeRange? initialRange;

  const DateRangeModal({super.key, this.initialRange});

  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTimeRange? initialRange,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangeModal(initialRange: initialRange),
    );
  }

  @override
  State<DateRangeModal> createState() => _DateRangeModalState();
}

class _DateRangeModalState extends State<DateRangeModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _currentMonth1;

  @override
  void initState() {
    super.initState();
    if (widget.initialRange != null) {
      _startDate = widget.initialRange!.start;
      _endDate = widget.initialRange!.end;
      _currentMonth1 = DateTime(_startDate!.year, _startDate!.month);
    } else {
      final now = DateTime.now();
      _currentMonth1 = DateTime(now.year, now.month);
    }
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonth1 = DateTime(_currentMonth1.year, _currentMonth1.month - 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth1 = DateTime(_currentMonth1.year, _currentMonth1.month + 1);
    });
  }

  void _onDateTapped(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (date.isBefore(_startDate!)) {
        _startDate = date;
      } else if (date.isAtSameMomentAs(_startDate!)) {
        _startDate = null;
      } else {
        _endDate = date;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  String _getSelectedRangeText() {
    if (_startDate == null) return 'Pilih Tanggal';
    if (_endDate == null) return _formatDate(_startDate);
    return '${_formatDate(_startDate)} - ${_formatDate(_endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final nextMonth = DateTime(_currentMonth1.year, _currentMonth1.month + 1);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Center(
            child: Text(
              'Pilih Tanggal',
              style: AppTextStyles.semiBold(20, AppColors.neutral950),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.neutral300, height: 1),
          const SizedBox(height: 16),

          // Calendar Card (Exactly as in the image)
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sky50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sky500, width: 2),
                ),
                child: Column(
                  children: [
                    // Month 1 (e.g. February 2026)
                    MonthCalendarWidget(
                      month: _currentMonth1,
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateTapped: _onDateTapped,
                      onPreviousMonth: _onPreviousMonth,
                      onNextMonth: _onNextMonth,
                    ),
                    const SizedBox(height: 24),
                    // Month 2 (e.g. Maret 2026)
                    MonthCalendarWidget(
                      month: nextMonth,
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateTapped: _onDateTapped,
                      onPreviousMonth: _onPreviousMonth,
                      onNextMonth: _onNextMonth,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selection Summary & Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal dipilih',
                      style: AppTextStyles.regular(12, AppColors.neutral500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSelectedRangeText(),
                      style: AppTextStyles.medium(12, AppColors.neutral950),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CustomButton(
                text: 'Batal',
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
                backgroundColor: AppColors.sky500,
                textColor: AppColors.sky500,
                size: CustomButtonSize.large,
              ),
              const SizedBox(width: 8),
              CustomButton(
                text: 'Simpan',
                onPressed: (_startDate != null && _endDate != null)
                    ? () {
                        Navigator.pop(
                          context,
                          DateTimeRange(start: _startDate!, end: _endDate!),
                        );
                      }
                    : null, // Disabled if range is incomplete
                size: CustomButtonSize.large,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MonthCalendarWidget extends StatelessWidget {
  final DateTime month;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onDateTapped;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthCalendarWidget({
    super.key,
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.onDateTapped,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  String _getMonthName(int monthValue) {
    switch (monthValue) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  bool _isSameDay(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isBetween(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return d.isAfter(s) && d.isBefore(e);
  }

  List<DateTime> _generateMonthDates(DateTime m) {
    final firstDay = DateTime(m.year, m.month, 1);
    final startOffset = firstDay.weekday % 7; // Sunday is 0, Monday is 1, etc.
    final dates = <DateTime>[];

    // Previous month trailing days
    for (int i = startOffset; i > 0; i--) {
      dates.add(firstDay.subtract(Duration(days: i)));
    }

    // Current month days
    final daysInMonth = DateTime(m.year, m.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      dates.add(DateTime(m.year, m.month, i));
    }

    // Fixed 6 rows (42 cells) to maintain constant height and layout alignment
    const totalCells = 42;
    final remaining = totalCells - dates.length;
    for (int i = 1; i <= remaining; i++) {
      dates.add(DateTime(m.year, m.month + 1, i));
    }

    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateMonthDates(month);
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < dates.length; i += 7) {
      weeks.add(dates.sublist(i, i + 7));
    }

    final weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Month Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onPreviousMonth,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.sky300, width: 1.5),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  TablerIcons.chevronLeft,
                  color: AppColors.sky500,
                  size: 20,
                ),
              ),
            ),
            Text(
              '${_getMonthName(month.month)} ${month.year}',
              style: AppTextStyles.semiBold(16, AppColors.neutral950),
            ),
            GestureDetector(
              onTap: onNextMonth,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.sky300, width: 1.5),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  TablerIcons.chevronRight,
                  color: AppColors.sky500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekday Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: AppTextStyles.regular(12, AppColors.neutral500),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Calendar Dates
        Column(
          mainAxisSize: MainAxisSize.min,
          children: weeks.map((week) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: week.map((date) {
                  final isCurrentMonth = date.month == month.month;
                  final isStart = _isSameDay(date, startDate);
                  final isEnd = _isSameDay(date, endDate);
                  final isInRange =
                      startDate != null &&
                      endDate != null &&
                      _isBetween(date, startDate!, endDate!);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDateTapped(date),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 38,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Connection Background Layer for Selection Range
                            if (isInRange)
                              Container(
                                color: AppColors.sky100,
                                margin: const EdgeInsets.symmetric(vertical: 3),
                              )
                            else if (isStart && endDate != null)
                              Row(
                                children: [
                                  const Spacer(),
                                  Expanded(
                                    child: Container(
                                      color: AppColors.sky100,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (isEnd && startDate != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      color: AppColors.sky100,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 3,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),

                            // 2. Selection Marker (Blue circle/square)
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: (isStart || isEnd)
                                    ? AppColors.sky500
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${date.day}',
                                style: (isStart || isEnd)
                                    ? AppTextStyles.medium(12, Colors.white)
                                    : isInRange
                                    ? AppTextStyles.medium(
                                        12,
                                        AppColors.neutral950,
                                      )
                                    : isCurrentMonth
                                    ? AppTextStyles.medium(
                                        12,
                                        AppColors.neutral950,
                                      )
                                    : AppTextStyles.regular(
                                        12,
                                        AppColors.neutral400,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
