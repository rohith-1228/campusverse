import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/registration.dart';
import 'qr_matrix_painter.dart';

class TicketCard extends StatelessWidget {
  final Registration registration;
  final VoidCallback? onCancel;

  const TicketCard({
    super.key,
    required this.registration,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha((0.15 * 255).round())
              : AppColors.primary.withAlpha((0.2 * 255).round()),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha((0.15 * 255).round()),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Branding & Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'CampusVerse Admission Pass',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: registration.isCancelled
                          ? AppColors.error
                          : (registration.isAttended
                              ? AppColors.success
                              : Colors.white.withAlpha((0.25 * 255).round())),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          registration.isCancelled
                              ? Icons.cancel_rounded
                              : (registration.isAttended
                                  ? Icons.check_circle_rounded
                                  : Icons.verified_rounded),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          registration.isCancelled
                              ? 'CANCELLED'
                              : (registration.isAttended ? 'CHECKED IN' : 'CONFIRMED'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Event Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registration.eventTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'DATE & TIME',
                          DateFormatter.formatFullDate(registration.eventDate),
                          Icons.calendar_month_rounded,
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'VENUE',
                          registration.eventVenue,
                          Icons.location_on_rounded,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'STUDENT NAME',
                          registration.student.name,
                          Icons.person_rounded,
                          isDark,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'ROLL NUMBER',
                          registration.student.rollNumber,
                          Icons.badge_rounded,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  if (registration.teamName != null &&
                      registration.teamName!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      'TEAM NAME',
                      registration.teamName!,
                      Icons.groups_rounded,
                      isDark,
                    ),
                  ],
                ],
              ),
            ),

            // Perforated Tear-Off Divider
            _buildPerforatedDivider(isDark),

            // QR & Barcode Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: QrMatrixWidget(
                      data: registration.qrCodeData,
                      size: 140,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'REGISTRATION ID',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    registration.registrationId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (registration.isAttended)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            registration.checkedInAt != null
                                ? 'Admitted • ${DateFormatter.formatShortDate(registration.checkedInAt!)}'
                                : 'Admitted at Event Desk',
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (registration.isCancelled)
                    Text(
                      'This admission pass is cancelled and not valid for entry.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    Text(
                      'Scan at venue registration desk for immediate verified entry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  if (onCancel != null && registration.isConfirmed && !registration.isAttended) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                      label: const Text(
                        'Cancel Registration',
                        style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildPerforatedDivider(bool isDark) {
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Row(
      children: [
        // Left Cutout Circle
        Transform.translate(
          offset: const Offset(-12, 0),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Dashed Line
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.constrainWidth();
              const dashWidth = 6.0;
              const dashSpace = 4.0;
              final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: 1.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha((0.2 * 255).round())
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        // Right Cutout Circle
        Transform.translate(
          offset: const Offset(12, 0),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
