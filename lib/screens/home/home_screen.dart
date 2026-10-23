import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/event_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_orb.dart';
import '../../widgets/loading_view.dart';
import '../event_details/event_details_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final eventProvider = context.watch<EventProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    final student = profileProvider.currentStudent;
    final featuredEvents = eventProvider.featuredEvents;
    final filteredEvents = eventProvider.filteredEvents;
    final unreadNotifs = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          // Ambient Gradient Orbs
          if (isDark) ...[
            const Positioned(
              top: -80,
              right: -60,
              child: GradientOrb(
                size: 340,
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            const Positioned(
              top: 350,
              left: -80,
              child: GradientOrb(
                size: 300,
                colors: [AppColors.electricBlue, AppColors.neonCyan],
              ),
            ),
          ],

          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => eventProvider.refreshEvents(),
              color: AppColors.primaryLight,
              child: CustomScrollView(
                slivers: [
                  // App Bar Header Sliver
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Row(
                        children: [
                          // Student Avatar
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha((0.35 * 255).round()),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(student?.avatarUrl ??
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Personalized Greeting
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Welcome back, ${student?.name.split(' ').first ?? 'Student'} 👋',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  student?.department ?? 'CampusVerse Member',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Notification Bell with Unread Badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface.withAlpha((0.6 * 255).round())
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkGlassBorder
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.notifications_outlined,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const NotificationsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (unreadNotifs > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    child: Center(
                                      child: Text(
                                        '$unreadNotifs',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar Sliver
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        borderRadius: 18,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.primaryLight,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) =>
                                    eventProvider.setSearchQuery(value),
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  fontSize: 14.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search techfests, hackathons, workshops...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                    fontSize: 13.5,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                                onPressed: () {
                                  _searchController.clear();
                                  eventProvider.setSearchQuery('');
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Horizontal Category Filter Pills
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 8),
                      child: SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: AppConstants.categories.length,
                          itemBuilder: (context, index) {
                            final cat = AppConstants.categories[index];
                            final isSelected =
                                eventProvider.selectedCategory == cat;
                            return CategoryChip(
                              label: cat,
                              isSelected: isSelected,
                              onTap: () => eventProvider.selectCategory(cat),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Hero Featured Spotlight Section
                  if (eventProvider.selectedCategory == AppConstants.categoryAll &&
                      eventProvider.searchQuery.isEmpty &&
                      featuredEvents.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                        child: _buildHeroHighlightCard(
                          context,
                          featuredEvents.first,
                          isDark,
                        ),
                      ),
                    ),

                  // Featured Events Carousel Section
                  if (eventProvider.selectedCategory == AppConstants.categoryAll &&
                      eventProvider.searchQuery.isEmpty &&
                      featuredEvents.length > 1) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Highlights',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha((0.15 * 255).round()),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${featuredEvents.length} Featured',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: featuredEvents.length,
                          itemBuilder: (context, index) {
                            final event = featuredEvents[index];
                            return EventCard(
                              event: event,
                              isHorizontal: true,
                              onTap: () => _openEventDetails(event),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Upcoming Events List Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            eventProvider.selectedCategory == AppConstants.categoryAll
                                ? (eventProvider.searchQuery.isEmpty
                                    ? 'Upcoming Campus Events'
                                    : 'Search Results (${filteredEvents.length})')
                                : '${eventProvider.selectedCategory} (${filteredEvents.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          if (eventProvider.selectedCategory != AppConstants.categoryAll ||
                              eventProvider.searchQuery.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                eventProvider.clearFilters();
                              },
                              child: const Text('Reset', style: TextStyle(color: AppColors.primaryLight)),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Event Cards Stream
                  if (eventProvider.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: LoadingView(message: 'Updating campus events...'),
                      ),
                    )
                  else if (filteredEvents.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                size: 54,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No events found',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try clearing your search query or choosing another category.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  eventProvider.clearFilters();
                                },
                                child: const Text('View All Events'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = filteredEvents[index];
                            return EventCard(
                              event: event,
                              onTap: () => _openEventDetails(event),
                            );
                          },
                          childCount: filteredEvents.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHighlightCard(BuildContext context, Event event, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () => _openEventDetails(event),
      borderRadius: 24,
      child: Stack(
        children: [
          // Background Event Cover Image
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              event.imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Deep Dark Glass Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha((0.35 * 255).round()),
                    Colors.black.withAlpha((0.85 * 255).round()),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Spotlight Badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha((0.5 * 255).round()),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.star_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'SPOTLIGHT EVENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Content Info
          Positioned(
            bottom: 16,
            left: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 13, color: AppColors.electricBlue),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatFullDate(event.dateTime),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.location_on_rounded, size: 13, color: AppColors.secondaryLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha((0.85 * 255).round()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${event.availableSeats} Seats Left',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Explore Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
