import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/student.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_orb.dart';
import '../main_shell.dart';

class DemoLoginScreen extends StatefulWidget {
  const DemoLoginScreen({super.key});

  @override
  State<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends State<DemoLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _rollController;
  late TextEditingController _phoneController;

  String _selectedDepartment = AppConstants.departments[0];
  String _selectedYear = AppConstants.academicYears[2];
  String _selectedAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200';

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
    _nameController = TextEditingController(text: 'Alex Chen');
    _emailController = TextEditingController(text: 'alex.chen@campusverse.edu');
    _rollController = TextEditingController(text: 'CS-2023-042');
    _phoneController = TextEditingController(text: '+91 98765 43210');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _applyPreset({
    required String name,
    required String email,
    required String roll,
    required String dept,
    required String year,
    required String avatar,
  }) {
    setState(() {
      _nameController.text = name;
      _emailController.text = email;
      _rollController.text = roll;
      _selectedDepartment = dept;
      _selectedYear = year;
      _selectedAvatar = avatar;
    });
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      rollNumber: _rollController.text.trim(),
      department: _selectedDepartment,
      yearOfStudy: _selectedYear,
      phone: _phoneController.text.trim(),
      avatarUrl: _selectedAvatar,
    );

    await context.read<ProfileProvider>().login(student);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Background Gradient Orbs
          const Positioned(
            top: -60,
            left: -60,
            child: GradientOrb(
              size: 300,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Brand
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
                                    color: AppColors.primary.withAlpha((0.4 * 255).round()),
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
                            const SizedBox(height: 14),
                            const Text(
                              'Student Demo Login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Choose a student profile or enter custom details',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha((0.75 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Academic Demo Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryLight.withAlpha((0.3 * 255).round()),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.primaryLight, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Academic Prototype: Uses instant local student authentication for evaluation.',
                                style: TextStyle(
                                  color: Colors.white.withAlpha((0.9 * 255).round()),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Quick Preset Chips
                      Text(
                        'QUICK SELECT PRESET STUDENT',
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
                          children: [
                            _buildPresetChip(
                              label: 'Alex Chen (CSE)',
                              onTap: () => _applyPreset(
                                name: 'Alex Chen',
                                email: 'alex.chen@campusverse.edu',
                                roll: 'CS-2023-042',
                                dept: AppConstants.departments[0],
                                year: AppConstants.academicYears[2],
                                avatar: _avatarOptions[0],
                              ),
                            ),
                            _buildPresetChip(
                              label: 'Sophia Patel (ECE)',
                              onTap: () => _applyPreset(
                                name: 'Sophia Patel',
                                email: 'sophia.patel@campusverse.edu',
                                roll: 'EC-2024-018',
                                dept: AppConstants.departments[2],
                                year: AppConstants.academicYears[1],
                                avatar: _avatarOptions[2],
                              ),
                            ),
                            _buildPresetChip(
                              label: 'David Miller (IT)',
                              onTap: () => _applyPreset(
                                name: 'David Miller',
                                email: 'david.miller@campusverse.edu',
                                roll: 'IT-2022-091',
                                dept: AppConstants.departments[1],
                                year: AppConstants.academicYears[3],
                                avatar: _avatarOptions[3],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Main Login Glass Card
                      GlassCard(
                        padding: const EdgeInsets.all(22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar Selector
                              Text(
                                'Choose Profile Avatar',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withAlpha((0.8 * 255).round()),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 50,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _avatarOptions.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                                          radius: 20,
                                          backgroundImage: NetworkImage(url),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Full Name
                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Full Student Name',
                                  prefixIcon: Icon(Icons.person_outline_rounded,
                                      color: AppColors.primaryLight),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter student name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // College Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'College Email Address',
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: AppColors.primaryLight),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter email';
                                  }
                                  if (!val.contains('@') || !val.contains('.')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Roll Number
                              TextFormField(
                                controller: _rollController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'University Roll / Reg Number',
                                  prefixIcon: Icon(Icons.badge_outlined,
                                      color: AppColors.primaryLight),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter roll number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              // Department Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedDepartment,
                                dropdownColor: AppColors.darkBgSecondary,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Department / Major',
                                  prefixIcon: Icon(Icons.school_outlined,
                                      color: AppColors.primaryLight),
                                ),
                                items: AppConstants.departments.map((dept) {
                                  return DropdownMenuItem(
                                    value: dept,
                                    child: Text(
                                      dept,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedDepartment = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),

                              // Year Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedYear,
                                dropdownColor: AppColors.darkBgSecondary,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Year of Study',
                                  prefixIcon: Icon(Icons.calendar_month_outlined,
                                      color: AppColors.primaryLight),
                                ),
                                items: AppConstants.academicYears.map((year) {
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      year,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedYear = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 14),

                              // Phone Number
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Contact Phone Number',
                                  prefixIcon: Icon(Icons.phone_outlined,
                                      color: AppColors.primaryLight),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  if (val.trim().length < 8) {
                                    return 'Phone number too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              // Continue Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _submitLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Enter CampusVerse →',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({required String label, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white.withAlpha((0.1 * 255).round()),
        side: BorderSide(color: Colors.white.withAlpha((0.2 * 255).round())),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: onTap,
      ),
    );
  }
}
