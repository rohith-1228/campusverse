import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/glass_card.dart';
import '../auth/demo_login_screen.dart';
import 'ticket_scanner_screen.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  const OrganizerDashboardScreen({super.key});

  void _showCreateOrEditEventDialog(BuildContext context, [Event? existing]) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final venueController = TextEditingController(text: existing?.venue ?? 'Campus Seminar Hall');
    final capacityController = TextEditingController(text: '${existing?.capacity ?? 100}');
    final imageController = TextEditingController(
      text: existing?.imageUrl ??
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    );
    String selectedCategory = existing?.category ?? 'Technical';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkBgSecondary : Colors.white,
          title: Text(existing == null ? 'Create Campus Event' : 'Edit Event Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.categories
                      .where((c) => c != AppConstants.categoryAll)
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: venueController,
                  decoration: const InputDecoration(labelText: 'Venue / Hall *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Seat Capacity *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Event Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Cover Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                final cap = int.tryParse(capacityController.text.trim()) ?? 100;
                final now = DateTime.now();

                if (existing == null) {
                  final newEvent = Event(
                    id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text.trim(),
                    description: descController.text.trim().isNotEmpty
                        ? descController.text.trim()
                        : 'Custom collegiate event organized via Organizer Dashboard.',
                    category: selectedCategory,
                    venue: venueController.text.trim(),
                    organizer: AppConstants.demoOrganizerRoleTitle,
                    dateTime: now.add(const Duration(days: 7, hours: 10)),
                    endTime: now.add(const Duration(days: 7, hours: 14)),
                    capacity: cap,
                    registeredCount: 0,
                    imageUrl: imageController.text.trim().isNotEmpty
                        ? imageController.text.trim()
                        : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
                    registrationDeadline: now.add(const Duration(days: 6)),
                  );
                  await context.read<EventProvider>().addCustomEvent(newEvent);
                } else {
                  final updated = existing.copyWith(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    category: selectedCategory,
                    venue: venueController.text.trim(),
                    capacity: cap,
                    imageUrl: imageController.text.trim(),
                  );
                  await context.read<EventProvider>().updateEvent(updated);
                }

                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existing == null
                          ? 'Event created successfully!'
                          : 'Event updated!'),
                    ),
                  );
                }
              },
              child: Text(existing == null ? 'Create Event' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendeesModal(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AttendeesModalView(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final eventProvider = context.watch<EventProvider>();
    final regProvider = context.watch<RegistrationProvider>();

    // Role-based route guard
    if (!profileProvider.isOrganizer) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad_rounded, size: 64, color: AppColors.error),
                const SizedBox(height: 18),
                const Text(
                  'Organizer Privilege Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Student accounts cannot create, edit, or delete campus events or inspect attendee rosters. Please log in with an Organizer account to proceed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const DemoLoginScreen(initialTabIndex: 1)),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Go to Organizer Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final events = eventProvider.allEvents;
    final upcomingEvents = eventProvider.upcomingEvents;
    final allRegistrations = regProvider.registrations;
    final confirmedCount = allRegistrations.where((r) => r.isConfirmed).length;
    final checkedInCount = allRegistrations.where((r) => r.isAttended).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Ticket Scanner & Gate Entry',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TicketScannerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Event',
            onPressed: () => _showCreateOrEditEventDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out Organizer',
            onPressed: () async {
              await profileProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DemoLoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.secondaryLight.withAlpha((0.3 * 255).round()),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded,
                      color: AppColors.secondaryLight, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authenticated: ${AppConstants.demoOrganizerName}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${AppConstants.demoOrganizerRoleTitle} • Gate Scanner & Event Administration',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Statistics Grid (Active, Upcoming, Signups, Checked In)
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Events',
                            style: TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
                        const SizedBox(height: 4),
                        Text('${events.length}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upcoming',
                            style: TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
                        const SizedBox(height: 4),
                        Text('${upcomingEvents.length}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.electricBlue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Signups',
                            style: TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
                        const SizedBox(height: 4),
                        Text('${confirmedCount + checkedInCount}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryLight)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Checked In',
                            style: TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
                        const SizedBox(height: 4),
                        Text('$checkedInCount',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.success)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Primary Gate Scanner & Add Event Quick Action Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TicketScannerScreen()),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                      label: const Text('Open QR Gate Scanner'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCreateOrEditEventDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Create Event'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Events List Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Managed Campus Events (${events.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = events[index];
                final eventRegs = regProvider.getRegistrationsForEvent(e.id);
                final eventCheckedIn = eventRegs.where((r) => r.isAttended).length;

                return GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          e.imageUrl,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 54,
                            height: 54,
                            color: Colors.grey.withAlpha((0.3 * 255).round()),
                            child: const Icon(Icons.event_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${e.category} • ${eventRegs.length}/${e.capacity} Signups • $eventCheckedIn Admitted',
                              style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                        tooltip: 'Scan for this Event',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TicketScannerScreen(initialEventId: e.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.people_alt_outlined, size: 20),
                        tooltip: 'Attendees Roster',
                        onPressed: () => _showAttendeesModal(context, e),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Event',
                        onPressed: () => _showCreateOrEditEventDialog(context, e),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                        tooltip: 'Delete Event',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Event?'),
                              content: Text('Remove "${e.title}" from CampusVerse?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error),
                                  onPressed: () {
                                    eventProvider.deleteEvent(e.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendeesModalView extends StatefulWidget {
  final Event event;

  const _AttendeesModalView({required this.event});

  @override
  State<_AttendeesModalView> createState() => _AttendeesModalViewState();
}

class _AttendeesModalViewState extends State<_AttendeesModalView> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all'; // 'all', 'checked_in', 'pending'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final regProvider = context.watch<RegistrationProvider>();
    final allForEvent = regProvider.getRegistrationsForEvent(widget.event.id);

    final query = _searchController.text.trim().toLowerCase();
    final filtered = allForEvent.where((r) {
      if (_statusFilter == 'checked_in' && !r.isAttended) return false;
      if (_statusFilter == 'pending' && r.isAttended) return false;
      if (query.isNotEmpty) {
        return r.student.name.toLowerCase().contains(query) ||
            r.student.rollNumber.toLowerCase().contains(query) ||
            r.student.department.toLowerCase().contains(query) ||
            r.registrationId.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgSecondary : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha((0.4 * 255).round()),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Attendee Roster: ${widget.event.title}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              '${allForEvent.length} registered students • ${allForEvent.where((r) => r.isAttended).length} admitted',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by student name, roll number, or reg ID...',
                prefixIcon: Icon(Icons.search_rounded),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 10),

            // Filter Chips
            Row(
              children: [
                _buildFilterChip('All (${allForEvent.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Admitted (${allForEvent.where((r) => r.isAttended).length})',
                  'checked_in',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pending (${allForEvent.where((r) => !r.isAttended).length})',
                  'pending',
                ),
              ],
            ),
            const Divider(height: 20),

            // Attendees List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No attendee records match the search filter.'),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final a = filtered[index];
                        final isCheckedIn = a.isAttended;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(a.student.avatarUrl),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.student.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700, fontSize: 13.5),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${a.student.rollNumber} • ${a.student.department}',
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Ticket: ${a.registrationId}',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: AppColors.primaryLight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Check-in Toggle / Status Button
                                if (isCheckedIn)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            size: 13, color: AppColors.success),
                                        SizedBox(width: 4),
                                        Text(
                                          'Admitted',
                                          style: TextStyle(
                                            color: AppColors.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: () async {
                                      await regProvider.checkInTicket(a.registrationId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${a.student.name} admitted!'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.how_to_reg_rounded, size: 16),
                                    label: const Text('Check In', style: TextStyle(fontSize: 12)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11.5)),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
