import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/student.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_orb.dart';
import '../auth/demo_login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/developer_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, Student student) {
    final nameController = TextEditingController(text: student.name);
    final emailController = TextEditingController(text: student.email);
    final rollController = TextEditingController(text: student.rollNumber);
    final phoneController = TextEditingController(text: student.phone);
    String selectedDept = student.department;
    String selectedYear = student.yearOfStudy;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkBgSecondary : Colors.white,
          title: const Text('Edit Student Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rollController,
                  decoration: const InputDecoration(labelText: 'Roll Number'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedDept,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: AppConstants.departments.map((d) {
                    return DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedDept = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedYear,
                  decoration: const InputDecoration(labelText: 'Year of Study'),
                  items: AppConstants.academicYears.map((y) {
                    return DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedYear = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
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
              onPressed: () {
                final updated = student.copyWith(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  rollNumber: rollController.text.trim(),
                  phone: phoneController.text.trim(),
                  department: selectedDept,
                  yearOfStudy: selectedYear,
                );
                context.read<ProfileProvider>().updateProfile(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.hub_rounded, color: Colors.white, size: 28),
      ),
      children: const [
        Text(
          'CampusVerse is a modern, premium College Event Management platform built with Flutter & Material 3.\n\n'
          'Designed for academic evaluation, featuring Dark Glassmorphism UI, Provider state architecture, verified QR admission passes, role-based student and organizer workflows, and offline mock persistence.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final regProvider = context.watch<RegistrationProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final student = profileProvider.currentStudent ?? Student.defaultDemoStudent;
    final myRegistrations = regProvider.getRegistrationsForStudent(student.rollNumber);

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
                colors: [AppColors.secondary, AppColors.electricBlue],
              ),
            ),

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Student Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your academic identity & app preferences',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profile Card
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundImage: NetworkImage(student.avatarUrl),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    student.email,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha((0.15 * 255).round()),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Roll: ${student.rollNumber}',
                                      style: const TextStyle(
                                        color: AppColors.primaryLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoTile(
                                'DEPARTMENT',
                                student.department,
                                isDark,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoTile(
                                'YEAR',
                                student.yearOfStudy,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showEditProfileDialog(context, student),
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: const Text('Edit Profile Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // State Counters
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Column(
                            children: [
                              const Icon(Icons.confirmation_number_rounded,
                                  color: AppColors.primaryLight, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                '${myRegistrations.length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'My Registered Events',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Column(
                            children: [
                              const Icon(Icons.bookmark_rounded,
                                  color: AppColors.warning, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                '${bookmarkProvider.count}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Saved Events',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // App Settings Section
                  Text(
                    'Preferences & Experience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        // Dark Glass / Clean Light Theme Toggle
                        SwitchListTile(
                          value: themeProvider.isDarkMode,
                          onChanged: (val) => themeProvider.toggleTheme(),
                          secondary: Icon(
                            themeProvider.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: AppColors.primaryLight,
                          ),
                          title: const Text('Dark Glassmorphism Theme',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            themeProvider.isDarkMode
                                ? 'Active: Midnight Navy & Neon Accents'
                                : 'Active: Clean Light Material Theme',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ),
                        const Divider(height: 1),

                        ListTile(
                          leading: const Icon(Icons.notifications_outlined,
                              color: AppColors.secondaryLight),
                          title: const Text('Notifications Center',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('View campus event alerts & pass confirmations',
                              style: TextStyle(fontSize: 11.5)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),

                        ListTile(
                          leading: const Icon(Icons.info_outline_rounded,
                              color: AppColors.primaryLight),
                          title: const Text('About CampusVerse & Academic Mapping',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _showAboutDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Developer Diagnostics Link (Restricted Area)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeveloperSettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.terminal_rounded, size: 16, color: AppColors.electricBlue),
                      label: const Text(
                        'Developer & REST API Settings',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Logout Student Account Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFFEE2E2),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 1.2),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Log Out Student Account?'),
                          content: const Text(
                            'Are you sure you want to log out? You can switch to another student profile or register a new one.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await context.read<ProfileProvider>().logout();
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const DemoLoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Log Out Student Account'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
