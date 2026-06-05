import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/listing_card.dart';
import '../application/search_controller.dart';
import 'filters_sheet.dart';
import 'map_results_view.dart';

/// Search + results in one screen: a search field, a filters trigger, a
/// list/map segmented toggle, and the AsyncValue-driven results.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: ref.read(searchQueryProvider).text);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final view = ref.watch(resultsViewProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) => ref
                          .read(searchQueryProvider.notifier)
                          .setText(v.isEmpty ? null : v),
                      decoration: InputDecoration(
                        hintText: 'Search by town or name',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _text.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _text.clear();
                                  ref
                                      .read(searchQueryProvider.notifier)
                                      .setText(null);
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FilterButton(
                    count: query.activeFilterCount,
                    onTap: () => showFiltersSheet(context, ref),
                  ),
                ],
              ),
            ),
            _ResultsBar(
              view: view,
              onView: (v) =>
                  ref.read(resultsViewProvider.notifier).state = v,
              count: results.maybeWhen(
                  data: (d) => d.length, orElse: () => null),
            ),
            Expanded(
              child: results.when(
                loading: () => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: 4,
                  itemBuilder: (_, _) => const ListingCardSkeleton(),
                ),
                error: (e, _) => ErrorStateView(
                  onRetry: () => ref.invalidate(searchResultsProvider),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: 'No rentals match',
                      message:
                          'Try widening your dates or clearing some filters.',
                      action: FilledButton(
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).reset();
                          _text.clear();
                        },
                        style: FilledButton.styleFrom(
                            minimumSize: const Size(200, 48)),
                        child: const Text('Clear all filters'),
                      ),
                    );
                  }
                  if (view == ResultsView.map) {
                    return MapResultsView(items: items);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (context, i) =>
                        ListingCard(listing: items[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: count > 0 ? AppTheme.ocean : Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.tune,
                  color: count > 0 ? Colors.white : AppTheme.deepSea),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  color: AppTheme.sunset, shape: BoxShape.circle),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }
}

class _ResultsBar extends StatelessWidget {
  const _ResultsBar(
      {required this.view, required this.onView, required this.count});
  final ResultsView view;
  final ValueChanged<ResultsView> onView;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Text(
            count == null ? 'Searching…' : '$count rentals',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const Spacer(),
          SegmentedButton<ResultsView>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              backgroundColor: WidgetStateProperty.resolveWith((s) =>
                  s.contains(WidgetState.selected)
                      ? AppTheme.ocean
                      : Colors.white),
              foregroundColor: WidgetStateProperty.resolveWith((s) =>
                  s.contains(WidgetState.selected)
                      ? Colors.white
                      : AppTheme.deepSea),
            ),
            segments: const [
              ButtonSegment(
                  value: ResultsView.list,
                  icon: Icon(Icons.view_list, size: 18),
                  label: Text('List')),
              ButtonSegment(
                  value: ResultsView.map,
                  icon: Icon(Icons.map_outlined, size: 18),
                  label: Text('Map')),
            ],
            selected: {view},
            onSelectionChanged: (s) => onView(s.first),
          ),
        ],
      ),
    );
  }
}
