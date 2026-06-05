import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../listings/application/listings_providers.dart';
import '../../listings/domain/listing.dart';
import '../../listings/domain/listings_repository.dart';
import '../application/search_controller.dart';

/// Presents the advanced-search filter sheet and writes the assembled query
/// back into [searchQueryProvider] on apply.
Future<void> showFiltersSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.9,
      child: _FiltersSheet(),
    ),
  );
}

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  late ListingQuery _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(searchQueryProvider);
  }

  void _toggleType(PropertyType t) {
    final set = Set.of(_draft.propertyTypes);
    set.contains(t) ? set.remove(t) : set.add(t);
    setState(() => _draft = _draft.copyWith(propertyTypes: set));
  }

  void _toggleLoc(LocationType t) {
    final set = Set.of(_draft.locationTypes);
    set.contains(t) ? set.remove(t) : set.add(t);
    setState(() => _draft = _draft.copyWith(locationTypes: set));
  }

  void _toggleAmenity(String a) {
    final set = Set.of(_draft.amenities);
    set.contains(a) ? set.remove(a) : set.add(a);
    setState(() => _draft = _draft.copyWith(amenities: set));
  }

  @override
  Widget build(BuildContext context) {
    final towns = ref.watch(townsProvider);
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
          child: Row(
            children: [
              const Text('Filters',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    setState(() => _draft = const ListingQuery()),
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _label('Region'),
              Wrap(
                spacing: 8,
                children: LbiRegion.values.map((r) {
                  return ChoiceChip(
                    label: Text(r.label),
                    selected: _draft.region == r,
                    onSelected: (_) => setState(() => _draft = _draft.copyWith(
                          region: _draft.region == r ? null : r,
                          clearRegion: _draft.region == r,
                        )),
                  );
                }).toList(),
              ),
              _label('Town'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: towns
                    .where((t) =>
                        _draft.region == null || t.region == _draft.region)
                    .map((t) {
                  final sel = _draft.town?.name == t.name;
                  return ChoiceChip(
                    label: Text(t.name),
                    selected: sel,
                    onSelected: (_) => setState(() => _draft = _draft.copyWith(
                          town: sel ? null : t,
                          clearTown: sel,
                        )),
                  );
                }).toList(),
              ),
              _label('Property type'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: PropertyType.values.map((t) {
                  return FilterChip(
                    label: Text(t.label),
                    selected: _draft.propertyTypes.contains(t),
                    onSelected: (_) => _toggleType(t),
                  );
                }).toList(),
              ),
              _label('Location type'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: LocationType.values.map((t) {
                  return FilterChip(
                    label: Text(t.label),
                    selected: _draft.locationTypes.contains(t),
                    onSelected: (_) => _toggleLoc(t),
                  );
                }).toList(),
              ),
              _label('Bedrooms (minimum)'),
              _StepperRow(
                value: _draft.minBedrooms ?? 0,
                onChanged: (v) => setState(() => _draft = _draft.copyWith(
                      minBedrooms: v == 0 ? null : v,
                      clearMinBedrooms: v == 0,
                    )),
              ),
              _label('Sleeps (minimum)'),
              _StepperRow(
                value: _draft.minSleeps ?? 0,
                step: 2,
                onChanged: (v) => setState(() => _draft = _draft.copyWith(
                      minSleeps: v == 0 ? null : v,
                      clearMinSleeps: v == 0,
                    )),
              ),
              _label('Max weekly budget'),
              Slider(
                value: (_draft.maxWeekly ?? 25000).toDouble(),
                min: 1000,
                max: 25000,
                divisions: 24,
                activeColor: AppTheme.ocean,
                label: _draft.maxWeekly == null
                    ? 'Any'
                    : Format.money(_draft.maxWeekly!),
                onChanged: (v) => setState(() => _draft = _draft.copyWith(
                      maxWeekly: v.round() >= 25000 ? null : v.round(),
                      clearMaxWeekly: v.round() >= 25000,
                    )),
              ),
              Text(
                _draft.maxWeekly == null
                    ? 'Up to any price'
                    : 'Up to ${Format.money(_draft.maxWeekly!)}/week',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              _label('Popular amenities'),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: const [
                  'Heated Pool',
                  'WiFi',
                  'Air Conditioning',
                  'Washer / Dryer',
                  'Rooftop Deck',
                  'EV Charger (Level 2)',
                ].map((a) {
                  return FilterChip(
                    label: Text(a),
                    selected: _draft.amenities.contains(a),
                    onSelected: (_) => _toggleAmenity(a),
                  );
                }).toList(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: FilledButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).update(_draft);
              Navigator.of(context).pop();
            },
            child: Text(_draft.activeFilterCount == 0
                ? 'Show results'
                : 'Show results · ${_draft.activeFilterCount} filters'),
          ),
        ),
      ],
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Text(t,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      );
}

class _StepperRow extends StatelessWidget {
  const _StepperRow(
      {required this.value, required this.onChanged, this.step = 1});
  final int value;
  final ValueChanged<int> onChanged;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed:
              value <= 0 ? null : () => onChanged((value - step).clamp(0, 99)),
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 70,
          child: Center(
            child: Text(value == 0 ? 'Any' : '$value+',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        IconButton.outlined(
          onPressed: () => onChanged(value + step),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
