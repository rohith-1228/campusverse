import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/event_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_orb.dart';
import '../event_details/event_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final eventProvider = context.read<EventProvider>();
    _searchController.text = eventProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEventDetails(Event event) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => EventDetailsScreen(event: event),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final eventProvider = context.read<EventProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkBgSecondary : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Sort Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Timeline Filter
                  const Text(
                    'Timeline',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'All Timelines',
                        isSelected: eventProvider.filterTimeline == 'all',
                        onTap: () {
                          eventProvider.setFilterTimeline('all');
                          setModalState(() {});
                        },
                      ),
                      _buildFilterChip(
                        label: 'Upcoming Only',
                        isSelected: eventProvider.filterTimeline == 'upcoming',
                        onTap: () {
                          eventProvider.setFilterTimeline('upcoming');
                          setModalState(() {});
                        },
                      ),
                      _buildFilterChip(
                        label: 'Past / Completed',
                        isSelected: eventProvider.filterTimeline == 'past',
                        onTap: () {
                          eventProvider.setFilterTimeline('past');
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort Option
                  const Text(
                    'Sort By',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Date (Earliest First)',
                        isSelected: eventProvider.sortBy == 'date_asc',
                        onTap: () {
                          eventProvider.setSortBy('date_asc');
                          setModalState(() {});
                        },
                      ),
                      _buildFilterChip(
                        label: 'Date (Latest First)',
                        isSelected: eventProvider.sortBy == 'date_desc',
                        onTap: () {
                          eventProvider.setSortBy('date_desc');
                          setModalState(() {});
                        },
                      ),
                      _buildFilterChip(
                        label: 'Most Popular',
                        isSelected: eventProvider.sortBy == 'popularity',
                        onTap: () {
                          eventProvider.setSortBy('popularity');
                          setModalState(() {});
                        },
                      ),
                      _buildFilterChip(
                        label: 'Largest Capacity',
                        isSelected: eventProvider.sortBy == 'capacity',
                        onTap: () {
                          eventProvider.setSortBy('capacity');
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            eventProvider.clearFilters();
                            _searchController.clear();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset All'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProvider = context.watch<EventProvider>();
    final filteredEvents = eventProvider.filteredEvents;

    final columns = Responsive.gridColumns(context, mobile: 1, tablet: 2, desktop: 3);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          if (isDark)
            const Positioned(
              top: -60,
              left: -60,
              child: GradientOrb(
                size: 320,
                colors: [AppColors.secondary, AppColors.primary],
              ),
            ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Screen Title & Filter Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Events',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Find workshops, hackathons & competitions',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),

                      // Filter Trigger Button
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface.withAlpha((0.6 * 255).round())
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkGlassBorder
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune_rounded, size: 20),
                          color: AppColors.primaryLight,
                          onPressed: () => _showFilterBottomSheet(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    borderRadius: 18,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => eventProvider.setSearchQuery(val),
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search by keyword, speaker, venue...',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              eventProvider.setSearchQuery('');
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Horizontal Category Selector
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: AppConstants.categories.length,
                      itemBuilder: (context, index) {
                        final cat = AppConstants.categories[index];
                        final isSelected = eventProvider.selectedCategory == cat;
                        return CategoryChip(
                          label: cat,
                          isSelected: isSelected,
                          onTap: () => eventProvider.selectCategory(cat),
                        );
                      },
                    ),
                  ),
                ),

                // Active Filter Summary Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Showing ${filteredEvents.length} events',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (eventProvider.filterTimeline != 'all' ||
                          eventProvider.sortBy != 'date_asc') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Filters Active',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Event Grid / List
                Expanded(
                  child: filteredEvents.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 56,
                                  color: AppColors.textMutedDark,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No matching events found',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search keywords, category, or timeline filters.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    eventProvider.clearFilters();
                                  },
                                  child: const Text('Clear All Filters'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: columns == 1 ? 1.05 : 0.85,
                          ),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
                            return EventCard(
                              event: event,
                              onTap: () => _openEventDetails(event),
                            );
                          },
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
