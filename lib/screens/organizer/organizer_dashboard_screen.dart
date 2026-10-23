import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/glass_card.dart';

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
                  value: selectedCategory,
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
                    organizer: 'Campus Organizer Demo',
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
    final regProvider = context.read<RegistrationProvider>();
    final attendees = regProvider.registrations
        .where((r) => r.eventId == event.id && r.isConfirmed)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendees: ${event.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('${attendees.length} verified registered students'),
              const Divider(height: 24),
              Expanded(
                child: attendees.isEmpty
                    ? const Center(
                        child: Text('No student registrations for this event yet.'),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: attendees.length,
                        itemBuilder: (context, index) {
                          final a = attendees[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(a.student.name.isNotEmpty
                                  ? a.student.name[0]
                                  : 'S'),
                            ),
                            title: Text(a.student.name,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                                '${a.student.rollNumber} • ${a.student.department}'),
                            trailing: Text(a.registrationId,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryLight)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProvider = context.watch<EventProvider>();
    final regProvider = context.watch<RegistrationProvider>();
    final events = eventProvider.allEvents;

    final totalCapacity = events.fold<int>(0, (sum, e) => sum + e.capacity);
    final totalRegistrations = regProvider.activeRegistrations.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Event',
            onPressed: () => _showCreateOrEditEventDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.secondaryLight.withAlpha((0.3 * 255).round())),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: AppColors.secondaryLight, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Organizer Demo Mode: Create, edit, and manage collegiate event entries and attendee registries.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Events',
                            style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                        const SizedBox(height: 4),
                        Text('${events.length}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Seats',
                            style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                        const SizedBox(height: 4),
                        Text('$totalCapacity',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Signups',
                            style: TextStyle(fontSize: 12, color: AppColors.textMutedDark)),
                        const SizedBox(height: 4),
                        Text('$totalRegistrations',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryLight)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Create Event Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateOrEditEventDialog(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add New Campus Event'),
              ),
            ),
            const SizedBox(height: 24),

            // Events Table / List
            Text(
              'Managed Campus Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = events[index];
                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          e.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
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
                            const SizedBox(height: 3),
                            Text(
                              '${e.category} • ${e.capacity} Seats',
                              style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.group_outlined, size: 20),
                        tooltip: 'View Attendees',
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
