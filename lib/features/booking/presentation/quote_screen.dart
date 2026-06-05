import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../listings/application/listings_providers.dart';
import '../../listings/domain/listing.dart';
import '../application/bookings_controller.dart';
import '../domain/booking.dart';

/// "Request to Book" flow: pick dates + guests, toggle travel insurance, see a
/// live price breakdown, and submit. On submit a [Booking] is created and the
/// confirmation screen is shown.
class QuoteScreen extends ConsumerStatefulWidget {
  const QuoteScreen({super.key, required this.listingId});
  final String listingId;

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 2;
  bool _insurance = true;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(listingByIdProvider(widget.listingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Request to Book')),
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateView(
            onRetry: () =>
                ref.invalidate(listingByIdProvider(widget.listingId))),
        data: (listing) {
          if (listing == null) {
            return const EmptyState(
                icon: Icons.error_outline,
                title: 'Unavailable',
                message: 'This listing can no longer be booked.');
          }
          return _form(listing);
        },
      ),
    );
  }

  Widget _form(Listing listing) {
    final preview = _booking(listing, preview: true);
    final df = DateFormat('EEE, MMM d');
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ListingHeader(listing: listing),
              const SizedBox(height: 20),
              const Text('Your dates',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Check-in',
                      value: _checkIn == null ? null : df.format(_checkIn!),
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Check-out',
                      value: _checkOut == null ? null : df.format(_checkOut!),
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Guests',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('$_guests guest${_guests == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 15)),
                  const Spacer(),
                  IconButton.outlined(
                    onPressed: _guests <= 1
                        ? null
                        : () => setState(() => _guests--),
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: _guests >= listing.sleeps
                        ? null
                        : () => setState(() => _guests++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              Text('Max ${listing.sleeps} guests',
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 20),
              _InsuranceTile(
                value: _insurance,
                cost: preview.insuranceCost,
                onChanged: (v) => setState(() => _insurance = v),
              ),
              const SizedBox(height: 20),
              if (_checkIn != null && _checkOut != null) ...[
                const Text('Price details',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _PriceBreakdown(booking: preview),
              ] else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.sand.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.ocean),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            'Select your dates to see the full price breakdown.',
                            style: TextStyle(color: Colors.grey.shade700)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _SubmitBar(
          enabled: _checkIn != null && _checkOut != null,
          total: preview.total,
          onSubmit: () => _submit(listing),
        ),
      ],
    );
  }

  Booking _booking(Listing listing, {bool preview = false}) {
    final ci = _checkIn ?? DateTime(2026, 6, 21);
    final co = _checkOut ?? ci.add(const Duration(days: 7));
    return Booking(
      id: preview ? 'preview' : ref.read(bookingsProvider.notifier).nextId(),
      listingId: listing.id,
      listingTitle: listing.title.replaceAll('**', ''),
      town: listing.town.name,
      heroColor: listing.heroColor,
      checkIn: ci,
      checkOut: co,
      guests: _guests,
      weeklyRate: listing.weeklyFrom,
      travelInsurance: _insurance,
      status: BookingStatus.requested,
    );
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final initial = isCheckIn
        ? (_checkIn ?? DateTime(2026, 6, 21))
        : (_checkOut ?? (_checkIn ?? DateTime(2026, 6, 21))
            .add(const Duration(days: 7)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2026, 6),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = picked.add(const Duration(days: 7));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  void _submit(Listing listing) {
    final booking = ref.read(bookingsProvider.notifier).add(_booking(listing));
    context.pushReplacement('/booking/${booking.id}/confirmed');
  }
}

class _ListingHeader extends StatelessWidget {
  const _ListingHeader({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 64,
            height: 64,
            color: Color(listing.heroColor),
            child: const Icon(Icons.photo_camera_outlined,
                color: Colors.white54),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(listing.title.replaceAll('**', ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              Text(listing.town.path,
                  style: const TextStyle(
                      color: AppTheme.ocean, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value ?? 'Select',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: value == null
                        ? Colors.grey.shade400
                        : AppTheme.deepSea)),
          ],
        ),
      ),
    );
  }
}

class _InsuranceTile extends StatelessWidget {
  const _InsuranceTile(
      {required this.value, required this.cost, required this.onChanged});
  final bool value;
  final int cost;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.seafoam.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.seafoam.withValues(alpha: 0.3)),
      ),
      child: SwitchListTile(
        value: value,
        activeThumbColor: AppTheme.seafoam,
        onChanged: onChanged,
        title: const Text('Add Travel Insurance',
            style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
            "'Cancel for any reason' coverage · ${Format.money(cost)} (7%)"),
        secondary: const Icon(Icons.health_and_safety_outlined,
            color: AppTheme.seafoam),
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, int amount, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: bold ? 16 : 14,
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
              const Spacer(),
              Text(Format.money(amount),
                  style: TextStyle(
                      fontSize: bold ? 16 : 14,
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          row('${Format.money(booking.weeklyRate)} × ${booking.nights} nights',
              booking.rentalCost),
          row('Cleaning fee', booking.cleaningFee),
          if (booking.travelInsurance)
            row('Travel insurance', booking.insuranceCost),
          row('Taxes & fees', booking.taxes),
          const Divider(height: 24),
          row('Total', booking.total, bold: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.sand.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_outlined,
                    size: 18, color: AppTheme.ocean),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '50% deposit due now: ${Format.money(booking.depositDue)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar(
      {required this.enabled, required this.total, required this.onSubmit});
  final bool enabled;
  final int total;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (enabled)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(Format.money(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 18)),
                const Text('total', style: TextStyle(color: Colors.black54)),
              ],
            ),
          if (enabled) const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: enabled ? onSubmit : null,
              child: const Text('Request to Book'),
            ),
          ),
        ],
      ),
    );
  }
}
