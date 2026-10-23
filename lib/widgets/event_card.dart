import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/event.dart';
import '../providers/bookmark_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/registration_provider.dart';
import 'glass_card.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final bool isHorizontal;
  final double? width;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isHorizontal = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final registrationProvider = context.watch<RegistrationProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final isBookmarked = bookmarkProvider.isBookmarked(event.id);
    final isRegistered = profileProvider.currentStudent != null &&
        registrationProvider.isRegistered(
            event.id, profileProvider.currentStudent!.rollNumber);

    if (isHorizontal) {
      return _buildHorizontalCard(context, isDark, isBookmarked, isRegistered);
    }
    return _buildVerticalCard(context, isDark, isBookmarked, isRegistered);
  }

  Widget _buildVerticalCard(
    BuildContext context,
    bool isDark,
    bool isBookmarked,
    bool isRegistered,
  ) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 18),
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Overlays
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Hero(
                    tag: 'event-img-${event.id}',
                    child: Image.network(
                      event.imageUrl,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 170,
                          color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Gradient Overlay for readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withAlpha((0.6 * 255).round()),
                          Colors.transparent,
                          Colors.black.withAlpha((0.4 * 255).round()),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Category Tag
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha((0.85 * 255).round()),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.3 * 255).round()),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // Registration Status or Bookmark Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      if (isRegistered) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha((0.95 * 255).round()),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Registered',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.45 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isBookmarked ? AppColors.warning : Colors.white,
                            size: 20,
                          ),
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            context.read<BookmarkProvider>().toggleBookmark(event.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Date Chip on Image Bottom Right
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.7 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha((0.2 * 255).round())),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.electricBlue),
                        const SizedBox(width: 5),
                        Text(
                          DateFormatter.formatMonthDay(event.dateTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Venue Row
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Seats Progress & Registration Indicator
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: event.seatsPercentage,
                            backgroundColor: isDark
                                ? Colors.white.withAlpha((0.1 * 255).round())
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              event.isFull ? AppColors.error : AppColors.primary,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        event.isFull ? 'Sold Out' : '${event.availableSeats} seats left',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: event.isFull
                              ? AppColors.error
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(
    BuildContext context,
    bool isDark,
    bool isBookmarked,
    bool isRegistered,
  ) {
    return Container(
      width: width ?? 280,
      margin: const EdgeInsets.only(right: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  child: Hero(
                    tag: 'event-img-h-${event.id}',
                    child: Image.network(
                      event.imageUrl,
                      height: 135,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 135,
                        color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                        child: const Center(child: Icon(Icons.event)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha((0.85 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.45 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? AppColors.warning : Colors.white,
                        size: 18,
                      ),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        context.read<BookmarkProvider>().toggleBookmark(event.id);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatMonthDay(event.dateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const Spacer(),
                      if (isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.success, width: 0.8),
                          ),
                          child: const Text(
                            'Going',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
