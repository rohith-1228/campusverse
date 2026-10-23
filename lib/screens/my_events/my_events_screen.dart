import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/event.dart';
import '../../models/registration.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/event_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_orb.dart';
import '../../widgets/ticket_card.dart';
import '../event_details/event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTicketDialog(BuildContext context, Registration reg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: TicketCard(
            registration: reg,
            onCancel: () {
              Navigator.pop(ctx);
              _confirmCancellation(context, reg);
            },
          ),
        ),
      ),
    );
  }

  void _confirmCancellation(BuildContext context, Registration reg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Registration?'),
        content: Text(
          'Are you sure you want to cancel your registration for "${reg.eventTitle}"? This will release your seat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Ticket'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await context
                  .read<RegistrationProvider>()
                  .cancelRegistration(reg.registrationId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Registration cancelled successfully.'),
                  ),
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final regProvider = context.watch<RegistrationProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final eventProvider = context.watch<EventProvider>();

    final currentStudent = profileProvider.currentStudent;
    final activeRegistrations = currentStudent != null
        ? regProvider.getRegistrationsForStudent(currentStudent.rollNumber)
        : regProvider.activeRegistrations;
    final allEvents = eventProvider.allEvents;

    // Filter bookmarked events
    final savedEvents = allEvents
        .where((e) => bookmarkProvider.isBookmarked(e.id))
        .toList();

    // Filter completed past events
    final completedEvents = allEvents
        .where((e) => e.isCompleted || !e.isUpcoming)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Stack(
        children: [
          if (isDark)
            const Positioned(
              top: -60,
              right: -60,
              child: GradientOrb(
                size: 300,
                colors: [AppColors.primary, AppColors.electricBlue],
              ),
            ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Campus Events',
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
                        'Manage your admission passes & saved bookmarks',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Glass TabBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withAlpha((0.6 * 255).round())
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha((0.35 * 255).round()),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: [
                        Tab(text: 'Registered (${activeRegistrations.length})'),
                        Tab(text: 'Saved (${savedEvents.length})'),
                        Tab(text: 'Completed (${completedEvents.length})'),
                      ],
                    ),
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Registered
                      _buildRegisteredTab(
                          context, activeRegistrations, allEvents, isDark),

                      // Tab 2: Saved
                      _buildSavedTab(context, savedEvents, isDark),

                      // Tab 3: Completed
                      _buildCompletedTab(context, completedEvents, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredTab(
    BuildContext context,
    List<Registration> registrations,
    List<Event> allEvents,
    bool isDark,
  ) {
    if (registrations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 56,
                color: AppColors.textMutedDark,
              ),
              const SizedBox(height: 16),
              Text(
                'No Registered Events Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore upcoming campus hackathons and workshops to claim your verified admission pass.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: registrations.length,
      itemBuilder: (context, index) {
        final reg = registrations[index];
        final eventMatch = allEvents.where((e) => e.id == reg.eventId).firstOrNull;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () => _showTicketDialog(context, reg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            reg.status.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'ID: ${reg.registrationId}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  reg.eventTitle,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 13, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatFullDate(reg.eventDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_rounded, size: 13, color: AppColors.secondaryLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reg.eventVenue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showTicketDialog(context, reg),
                        icon: const Icon(Icons.qr_code_rounded, size: 16),
                        label: const Text('View Pass QR'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (eventMatch != null)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(event: eventMatch),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text('Details'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedTab(BuildContext context, List<Event> savedEvents, bool isDark) {
    if (savedEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bookmark_border_rounded,
                size: 56,
                color: AppColors.textMutedDark,
              ),
              const SizedBox(height: 16),
              Text(
                'No Bookmarked Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the bookmark icon on any event card to save it here for fast access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: savedEvents.length,
      itemBuilder: (context, index) {
        final event = savedEvents[index];
        return EventCard(
          event: event,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedTab(BuildContext context, List<Event> completedEvents, bool isDark) {
    if (completedEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 56,
                color: AppColors.textMutedDark,
              ),
              const SizedBox(height: 16),
              Text(
                'No Completed Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Events you participate in will appear here once the schedule concludes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: completedEvents.length,
      itemBuilder: (context, index) {
        final event = completedEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha((0.25 * 255).round()),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'COMPLETED',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatShortDate(event.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
