import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/event.dart';
import '../../models/student.dart';
import '../../providers/notification_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/glass_card.dart';
import 'registration_success_screen.dart';

class EventRegistrationScreen extends StatefulWidget {
  final Event event;

  const EventRegistrationScreen({super.key, required this.event});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _rollController;
  late TextEditingController _phoneController;
  late TextEditingController _teamNameController;

  late String _selectedDepartment;
  late String _selectedYear;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final student = context.read<ProfileProvider>().currentStudent;

    _nameController = TextEditingController(text: student?.name ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');
    _rollController = TextEditingController(text: student?.rollNumber ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _teamNameController = TextEditingController();

    _selectedDepartment = student?.department ?? AppConstants.departments[0];
    if (!AppConstants.departments.contains(_selectedDepartment)) {
      _selectedDepartment = AppConstants.departments[0];
    }

    _selectedYear = student?.yearOfStudy ?? AppConstants.academicYears[2];
    if (!AppConstants.academicYears.contains(_selectedYear)) {
      _selectedYear = AppConstants.academicYears[2];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the event code of conduct and terms to proceed.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final student = Student(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      rollNumber: _rollController.text.trim(),
      department: _selectedDepartment,
      yearOfStudy: _selectedYear,
      phone: _phoneController.text.trim(),
      avatarUrl: context.read<ProfileProvider>().currentStudent?.avatarUrl ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    );

    final teamName = _teamNameController.text.trim().isNotEmpty
        ? _teamNameController.text.trim()
        : null;

    try {
      final reg = await context.read<RegistrationProvider>().registerStudent(
            event: widget.event,
            student: student,
            teamName: teamName,
          );

      // Trigger instant demo notification
      if (mounted) {
        context.read<NotificationProvider>().addNotification(
              title: 'Registration Confirmed! 🎉',
              message:
                  'You are registered for "${widget.event.title}". Admission pass #${reg.registrationId} is ready in My Events.',
              type: 'success',
            );

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => RegistrationSuccessScreen(
              registration: reg,
              event: widget.event,
            ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Event Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Summary Header Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.event.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                        child: const Icon(Icons.event_rounded, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.event.category} • ${widget.event.venue}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 18),

            // Registration Form
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Participant Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Information will be encoded onto your admission QR pass.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Student Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Student Name *',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        if (val.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // College Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'College Email *',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Roll Number
                    TextFormField(
                      controller: _rollController,
                      decoration: const InputDecoration(
                        labelText: 'University Roll / Reg Number *',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Roll number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Department Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDepartment,
                      dropdownColor: isDark ? AppColors.darkBgSecondary : Colors.white,
                      decoration: const InputDecoration(
                        labelText: 'Department / Major *',
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      items: AppConstants.departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept,
                          child: Text(
                            dept,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDepartment = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Year Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedYear,
                      dropdownColor: isDark ? AppColors.darkBgSecondary : Colors.white,
                      decoration: const InputDecoration(
                        labelText: 'Year of Study *',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      items: AppConstants.academicYears.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            year,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedYear = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        if (val.trim().length < 8) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Optional Team Name
                    TextFormField(
                      controller: _teamNameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Name (Optional)',
                        hintText: 'e.g. ByteBusters (for Hackathons/Sports)',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Terms and Conditions Acceptance SwitchListTile
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha((0.05 * 255).round())
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: SwitchListTile(
                          value: _agreedToTerms,
                          onChanged: (val) => setState(() => _agreedToTerms = val),
                          activeThumbColor: AppColors.primaryLight,
                          title: Text(
                            'I agree to the Event Guidelines & Code of Conduct *',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          subtitle: Text(
                            'I understand this generates an official collegiate pass.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Complete Registration & Get Pass',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
