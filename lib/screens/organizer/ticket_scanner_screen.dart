import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/registration.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../repositories/registration_repository.dart';
import '../../widgets/glass_card.dart';

class TicketScannerScreen extends StatefulWidget {
  final String? initialEventId;

  const TicketScannerScreen({super.key, this.initialEventId});

  @override
  State<TicketScannerScreen> createState() => _TicketScannerScreenState();
}

class _TicketScannerScreenState extends State<TicketScannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _manualIdController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  String? _selectedEventId;
  TicketVerificationResult? _lastResult;
  bool _isProcessingCheckIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedEventId = widget.initialEventId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualIdController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _verifyTicketInput(String input) {
    if (input.trim().isEmpty) return;

    final regProvider = context.read<RegistrationProvider>();
    final result = regProvider.verifyTicket(
      rawInput: input,
      targetEventId: _selectedEventId,
    );

    setState(() {
      _lastResult = result;
    });
  }

  Future<void> _confirmCheckIn(Registration registration) async {
    setState(() => _isProcessingCheckIn = true);
    try {
      final updated = await context
          .read<RegistrationProvider>()
          .checkInTicket(registration.registrationId);

      if (mounted) {
        setState(() {
          _lastResult = TicketVerificationResult(
            status: TicketVerificationStatus.alreadyCheckedIn,
            message:
                'Successfully checked in ${updated.student.name}! Pass marked as attended.',
            registration: updated,
            canCheckIn: false,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${updated.student.name} marked as CHECKED IN! 🎉',
            ),
            backgroundColor: AppColors.success,
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
      if (mounted) setState(() => _isProcessingCheckIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProvider = context.watch<EventProvider>();
    final regProvider = context.watch<RegistrationProvider>();
    final events = eventProvider.allEvents;
    final allRegistrations = regProvider.registrations;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Gate Ticket Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            tooltip: 'Toggle Flashlight',
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            tooltip: 'Switch Camera',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Filter Dropdown Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? AppColors.darkBgSecondary : Colors.white,
            child: Row(
              children: [
                const Icon(Icons.event_seat_rounded,
                    color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedEventId,
                      isExpanded: true,
                      hint: const Text('Check In For: Any Campus Event'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Any Event (Global Check-In Desk)'),
                        ),
                        ...events.map((e) => DropdownMenuItem<String?>(
                              value: e.id,
                              child: Text(
                                e.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedEventId = val;
                          if (_lastResult?.registration != null) {
                            _verifyTicketInput(
                                _lastResult!.registration!.registrationId);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar (Camera vs Manual)
          Container(
            color: isDark ? AppColors.darkBgSecondary : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryLight,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
              tabs: const [
                Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'QR Camera'),
                Tab(icon: Icon(Icons.keyboard_alt_outlined), text: 'Manual / Demo'),
              ],
            ),
          ),

          // Main View (Scanner or Manual Input)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Live QR Camera Scanner
                _buildCameraScannerView(isDark),

                // TAB 2: Manual Ticket Verification & Quick Samples
                _buildManualEntryView(isDark, allRegistrations),
              ],
            ),
          ),

          // Verification Result Panel
          if (_lastResult != null) _buildResultPanel(isDark),
        ],
      ),
    );
  }

  Widget _buildCameraErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_rounded, size: 54, color: AppColors.warning),
            const SizedBox(height: 12),
            const Text(
              'Camera Inactive / Unsupported in this Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the "Manual / Demo" tab to enter registration IDs or test with 1-click sample tickets.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.touch_app_rounded, size: 18),
              label: const Text('Switch to Manual Verification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraScannerView(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: _scannerController,
          errorBuilder: (context, error) => _buildCameraErrorView(),
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _verifyTicketInput(barcode.rawValue!);
                break;
              }
            }
          },
        ),

        // Visual Scanner Aim Box
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryLight, width: 3),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha((0.25 * 255).round()),
                blurRadius: 20,
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.75 * 255).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Align Student Pass QR Code inside frame',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryView(bool isDark, List<Registration> registrations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter Admission Ticket ID',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Supports direct ticket ID (e.g. CV-2026-1042) or raw QR payload.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualIdController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: const InputDecoration(
                          hintText: 'e.g. CV-2026-1042',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onSubmitted: _verifyTicketInput,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _verifyTicketInput(_manualIdController.text),
                      child: const Text('Verify'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Sample Ticket Chips for Academic Evaluators
          const Text(
            'QUICK-VERIFY ACTIVE TICKETS IN DATABASE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          if (registrations.isEmpty)
            const Text(
              'No registrations in database yet. Register a student for an event first to test gate check-in.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: registrations.map((r) {
                final isCheckedIn = r.isAttended;
                return ActionChip(
                  avatar: Icon(
                    isCheckedIn ? Icons.check_circle_rounded : Icons.confirmation_number_rounded,
                    size: 14,
                    color: isCheckedIn ? AppColors.success : AppColors.primaryLight,
                  ),
                  label: Text('${r.registrationId} (${r.student.name.split(' ').first})'),
                  backgroundColor: isCheckedIn
                      ? AppColors.success.withAlpha((0.15 * 255).round())
                      : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                  onPressed: () {
                    _manualIdController.text = r.registrationId;
                    _verifyTicketInput(r.registrationId);
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildResultPanel(bool isDark) {
    final res = _lastResult!;
    final reg = res.registration;

    Color badgeColor;
    IconData badgeIcon;
    String statusTitle;

    switch (res.status) {
      case TicketVerificationStatus.valid:
        badgeColor = AppColors.success;
        badgeIcon = Icons.check_circle_rounded;
        statusTitle = 'VALID ADMISSION TICKET';
        break;
      case TicketVerificationStatus.alreadyCheckedIn:
        badgeColor = AppColors.warning;
        badgeIcon = Icons.error_outline_rounded;
        statusTitle = 'ALREADY CHECKED IN';
        break;
      case TicketVerificationStatus.cancelled:
        badgeColor = AppColors.error;
        badgeIcon = Icons.cancel_rounded;
        statusTitle = 'CANCELLED TICKET';
        break;
      case TicketVerificationStatus.eventMismatch:
        badgeColor = AppColors.warning;
        badgeIcon = Icons.wrong_location_rounded;
        statusTitle = 'EVENT MISMATCH';
        break;
      case TicketVerificationStatus.notFound:
      case TicketVerificationStatus.invalidFormat:
        badgeColor = AppColors.error;
        badgeIcon = Icons.dangerous_rounded;
        statusTitle = 'UNRECOGNIZED TICKET';
        break;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.25 * 255).round()),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: badgeColor, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(badgeIcon, color: badgeColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statusTitle,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _lastResult = null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              res.message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            if (reg != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildResultDetail(
                      'STUDENT NAME',
                      reg.student.name,
                      Icons.person_rounded,
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildResultDetail(
                      'ROLL NUMBER',
                      reg.student.rollNumber,
                      Icons.badge_rounded,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildResultDetail(
                      'EVENT',
                      reg.eventTitle,
                      Icons.event_rounded,
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildResultDetail(
                      'TICKET ID',
                      reg.registrationId,
                      Icons.confirmation_number_rounded,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Confirm Check-in Button
              if (res.canCheckIn)
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    onPressed: _isProcessingCheckIn ? null : () => _confirmCheckIn(reg),
                    icon: _isProcessingCheckIn
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.how_to_reg_rounded, size: 20),
                    label: const Text(
                      'Confirm Gate Admission & Check In',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultDetail(String label, String value, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.primaryLight),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
