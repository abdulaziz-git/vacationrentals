import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../listings/domain/listing.dart';

/// Renders the rate periods (date range, nightly/weekly, min stay, changeover)
/// in the VRLBI "rate summary" style.
class RatesTable extends StatelessWidget {
  const RatesTable({super.key, required this.rates});
  final List<RatePeriod> rates;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    return Column(
      children: rates.map((r) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.sand.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(r.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  Text(
                    r.weekly != null
                        ? '${Format.money(r.weekly!)}/wk'
                        : '${Format.money(r.nightly!)}/night',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.ocean),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${fmt.format(r.start)} – ${fmt.format(r.end)}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _pill(Icons.nightlight_round, 'Min ${r.minNights} nights'),
                  if (r.changeoverDay != null)
                    _pill(Icons.event_repeat, r.changeoverDay!),
                  if (r.nightly != null && r.weekly != null)
                    _pill(Icons.bedtime, '${Format.money(r.nightly!)}/night'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _pill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.black54),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(fontSize: 12.5)),
          ],
        ),
      );
}
