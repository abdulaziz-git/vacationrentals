import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../listings/domain/listing.dart';

/// A multi-month availability grid mirroring the VRLBI detail calendar with the
/// four day states (available / pending / not available / no rates).
class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({super.key, required this.days});
  final List<AvailabilityDay> days;

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  int _monthOffset = 0;

  Map<DateTime, DayStatus> get _byDate => {
    for (final d in widget.days)
      DateTime(d.date.year, d.date.month, d.date.day): d.status,
  };

  @override
  Widget build(BuildContext context) {
    final first = widget.days.isEmpty
        ? DateTime(2026, 6)
        : widget.days.first.date;
    final base = DateTime(first.year, first.month + _monthOffset);
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _monthOffset == 0
                  ? null
                  : () => setState(() => _monthOffset--),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _monthName(base),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _monthOffset >= 3
                  ? null
                  : () => setState(() => _monthOffset++),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        _Weekdays(),
        _MonthGrid(month: base, byDate: _byDate),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: const [
            _Legend(DayStatus.available, 'Available'),
            _Legend(DayStatus.pending, 'Pending'),
            _Legend(DayStatus.notAvailable, 'Booked'),
          ],
        ),
      ],
    );
  }

  String _monthName(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _Weekdays extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.byDate});
  final DateTime month;
  final Map<DateTime, DayStatus> byDate;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cells = <Widget>[];
    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final status = byDate[date];
      cells.add(_DayCell(day: day, status: status));
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, this.status});
  final int day;
  final DayStatus? status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final available = status == DayStatus.available;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: available
              ? Border.all(color: AppTheme.seafoam.withValues(alpha: 0.4))
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: status == DayStatus.notAvailable
                  ? Colors.grey.shade400
                  : AppTheme.deepSea,
            ),
          ),
        ),
      ),
    );
  }
}

Color _statusColor(DayStatus? s) {
  switch (s) {
    case DayStatus.available:
      return AppTheme.seafoam.withValues(alpha: 0.14);
    case DayStatus.pending:
      return const Color(0xFFFFE2B8);
    case DayStatus.notAvailable:
      return Colors.grey.shade100;
    case DayStatus.noRates:
    case null:
      return Colors.transparent;
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.status, this.label);
  final DayStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: status == DayStatus.notAvailable
                ? Colors.grey.shade200
                : _statusColor(status),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12.5)),
      ],
    );
  }
}
