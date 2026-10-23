import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/event.dart';
import '../../models/registration.dart';
import '../../widgets/ticket_card.dart';
import '../main_shell.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final Registration registration;
  final Event event;

  const RegistrationSuccessScreen({
    super.key,
    required this.registration,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2)),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Registration Confirmed'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2)),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Column(
            children: [
              // Success Badge Pulse
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [AppColors.success, Color(0xFF059669)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withAlpha((0.4 * 255).round()),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'You\'re In! 🎉',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your admission pass has been generated and saved to My Events.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // The Digital Ticket Pass
              TicketCard(registration: registration),
              const SizedBox(height: 24),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const MainShell(initialIndex: 2)),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.confirmation_number_rounded, size: 20),
                  label: const Text(
                    'View in My Events →',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admission Pass saved to local demo wallet!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Save Offline Pass'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
