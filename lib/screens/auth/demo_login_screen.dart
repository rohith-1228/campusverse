import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/student.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_orb.dart';
import '../main_shell.dart';
import '../organizer/organizer_dashboard_screen.dart';

class DemoLoginScreen extends StatefulWidget {
  final int initialTabIndex;

  const DemoLoginScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends State<DemoLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _roleTabController;

  // Student Register Form
  final _registerFormKey = GlobalKey<FormState>();
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regRollController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  String _selectedDepartment = AppConstants.departments[0];
  String _selectedYear = AppConstants.academicYears[2];
  String _selectedAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200';

  // Student Returning Login Form
  final _studentLoginFormKey = GlobalKey<FormState>();
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Organizer Login Form
  final _organizerFormKey = GlobalKey<FormState>();
  final _orgEmailController =
      TextEditingController(text: AppConstants.demoOrganizerEmail);
  final _orgPasswordController =
      TextEditingController(text: AppConstants.demoOrganizerPassword);

  int _studentSubTab = 0; // 0: Sample / Returning Login, 1: Create New Student Account
  bool _isLoading = false;

  final List<String> _avatarOptions = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
  ];

  @override
  void initState() {
    super.initState();
    _roleTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _roleTabController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regRollController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();

    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();

    _orgEmailController.dispose();
    _orgPasswordController.dispose();
    super.dispose();
  }

  void _applyPresetStudent(Student preset) {
    setState(() {
      _loginIdentifierController.text = preset.rollNumber;
      _loginPasswordController.text = preset.password ?? 'Password@123';
    });
  }

  Future<void> _submitStudentRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<ProfileProvider>().registerStudentAccount(
            name: _regNameController.text,
            email: _regEmailController.text,
            rollNumber: _regRollController.text,
            department: _selectedDepartment,
            yearOfStudy: _selectedYear,
            phone: _regPhoneController.text,
            password: _regPasswordController.text,
            avatarUrl: _selectedAvatar,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Welcome to CampusVerse 🎉'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitStudentLogin() async {
    if (!_studentLoginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<ProfileProvider>().loginStudent(
            identifier: _loginIdentifierController.text.trim(),
            password: _loginPasswordController.text,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOrganizerLogin() async {
    if (!_organizerFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<ProfileProvider>().loginOrganizer(
            email: _orgEmailController.text.trim(),
            password: _orgPasswordController.text,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OrganizerDashboardScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _quickOrganizerDemoLogin() async {
    setState(() => _isLoading = true);
    await context.read<ProfileProvider>().loginOrganizerDemo();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OrganizerDashboardScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Ambient Gradient Orbs
          const Positioned(
            top: -60,
            left: -60,
            child: GradientOrb(
              size: 320,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          const Positioned(
            bottom: -60,
            right: -60,
            child: GradientOrb(
              size: 320,
              colors: [AppColors.electricBlue, AppColors.neonPink],
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Logo
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withAlpha((0.4 * 255).round()),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.hub_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'CampusVerse Portal',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select your role to access campus events and services',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha((0.75 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Role Selector Tabs (Student vs Organizer)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.08 * 255).round()),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withAlpha((0.15 * 255).round()),
                          ),
                        ),
                        child: TabBar(
                          controller: _roleTabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          tabs: const [
                            Tab(icon: Icon(Icons.school_rounded, size: 18), text: 'Student Access'),
                            Tab(icon: Icon(Icons.admin_panel_settings_rounded, size: 18), text: 'Organizer Access'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tab View Content
                      AnimatedBuilder(
                        animation: _roleTabController,
                        builder: (context, _) {
                          return _roleTabController.index == 0
                              ? _buildStudentSection()
                              : _buildOrganizerSection();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-navigation: Return Login vs Create Account
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _studentSubTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _studentSubTab == 0
                        ? AppColors.primary.withAlpha((0.25 * 255).round())
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _studentSubTab == 0
                          ? AppColors.primaryLight
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Sign In / Sample Profiles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _studentSubTab == 0 ? Colors.white : Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _studentSubTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _studentSubTab == 1
                        ? AppColors.primary.withAlpha((0.25 * 255).round())
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _studentSubTab == 1
                          ? AppColors.primaryLight
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Create Student Account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _studentSubTab == 1 ? Colors.white : Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_studentSubTab == 0) ...[
          // Sample Preset Quick Fill Chips
          Text(
            'QUICK-FILL SAMPLE STUDENTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withAlpha((0.6 * 255).round()),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: Student.samplePresets.map((preset) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: CircleAvatar(
                      backgroundImage: NetworkImage(preset.avatarUrl),
                      radius: 10,
                    ),
                    label: Text('${preset.name} (${preset.rollNumber})'),
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                    backgroundColor: Colors.white.withAlpha((0.1 * 255).round()),
                    side: BorderSide(
                        color: Colors.white.withAlpha((0.2 * 255).round())),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onPressed: () => _applyPresetStudent(preset),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Student Login Form Card
          GlassCard(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _studentLoginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Student Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Log in with your college email or university roll number',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha((0.75 * 255).round()),
                    ),
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _loginIdentifierController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'College Email or Roll Number',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      hintText: 'e.g. CS-2023-042 or alex.chen@campusverse.edu',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email or roll number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _loginPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitStudentLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Sign In to CampusVerse →',
                              style: TextStyle(
                                  fontSize: 15.5, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          // CREATE NEW STUDENT ACCOUNT FORM (UNLIMITED DEMO STUDENTS)
          GlassCard(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'New Student Registration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create unlimited student profiles with full local persistence',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha((0.75 * 255).round()),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Avatar Picker
                  Text(
                    'Choose Avatar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha((0.8 * 255).round()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avatarOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final url = _avatarOptions[index];
                        final isSelected = _selectedAvatar == url;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = url),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(url),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _regNameController,
                    style: const TextStyle(color: Colors.white),
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
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: _regEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'College Email Address *',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'student@campusverse.edu',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(val.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Roll Number
                  TextFormField(
                    controller: _regRollController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'University Roll / Reg Number *',
                      prefixIcon: Icon(Icons.badge_outlined),
                      hintText: 'e.g. CS-2025-012',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Roll number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Department Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDepartment,
                    dropdownColor: AppColors.darkBgSecondary,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Department / Major *',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    items: AppConstants.departments.map((dept) {
                      return DropdownMenuItem(
                        value: dept,
                        child: Text(dept, style: const TextStyle(fontSize: 12.5)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDepartment = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Year Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedYear,
                    dropdownColor: AppColors.darkBgSecondary,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Year of Study *',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    items: AppConstants.academicYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year, style: const TextStyle(fontSize: 12.5)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: _regPhoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
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
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: _regPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password
                  TextFormField(
                    controller: _regConfirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password *',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                    ),
                    validator: (val) {
                      if (val != _regPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Register Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitStudentRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Register & Enter CampusVerse →',
                              style: TextStyle(
                                  fontSize: 15.5, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrganizerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Demo Credentials Badge
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondaryLight.withAlpha((0.4 * 255).round()),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined,
                      color: AppColors.secondaryLight, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Academic Evaluation Credentials',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Email: organizer@campusverse.edu\nPassword: Organizer@2026',
                style: TextStyle(
                  color: AppColors.secondaryLight,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Demonstration Role: Grants event creation, attendee rosters, and ticket check-in capabilities.',
                style: TextStyle(
                  color: Colors.white.withAlpha((0.8 * 255).round()),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Organizer Form Card
        GlassCard(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _organizerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Event Organizer Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage campus events, inspect ticket holders, and verify QR passes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha((0.75 * 255).round()),
                  ),
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: _orgEmailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Organizer College Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Organizer email is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _orgPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Organizer Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Sign In Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    onPressed: _isLoading ? null : _submitOrganizerLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Enter Organizer Dashboard →',
                            style: TextStyle(
                                fontSize: 15.5, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Quick 1-Click Demo Login Button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _quickOrganizerDemoLogin,
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('1-Click Organizer Quick Demo Login'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
