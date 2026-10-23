import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/event_provider.dart';
import '../../widgets/glass_card.dart';

class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  State<DeveloperSettingsScreen> createState() => _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends State<DeveloperSettingsScreen> {
  late TextEditingController _urlController;
  final _formKey = GlobalKey<FormState>();

  bool _isTestingConnection = false;
  String? _testResultStatus; // 'success', 'error', null
  String? _testResultMessage;
  int? _testLatencyMs;

  @override
  void initState() {
    super.initState();
    final eventProvider = context.read<EventProvider>();
    _urlController = TextEditingController(text: eventProvider.apiUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection(String urlStr) async {
    final trimmed = urlStr.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https')) || uri.host.isEmpty) {
      setState(() {
        _testResultStatus = 'error';
        _testResultMessage = 'Invalid URL format. Must begin with http:// or https:// with a valid domain.';
        _testLatencyMs = null;
      });
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _testResultStatus = null;
      _testResultMessage = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final testTarget = uri.path.endsWith('/events')
          ? uri
          : uri.replace(path: '${uri.path.replaceAll(RegExp(r'/+$'), '')}/events');

      final client = http.Client();
      final response = await client.get(
        testTarget,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _isTestingConnection = false;
          _testResultStatus = 'success';
          _testLatencyMs = stopwatch.elapsedMilliseconds;
          _testResultMessage =
              'Connection verified! Status ${response.statusCode} OK (${stopwatch.elapsedMilliseconds}ms latency).';
        });
      } else {
        setState(() {
          _isTestingConnection = false;
          _testResultStatus = 'error';
          _testLatencyMs = stopwatch.elapsedMilliseconds;
          _testResultMessage =
              'Server responded with HTTP ${response.statusCode}: ${response.reasonPhrase ?? 'Error'}';
        });
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      setState(() {
        _isTestingConnection = false;
        _testResultStatus = 'error';
        _testLatencyMs = null;
        _testResultMessage =
            'SocketException: Host unreachable or port closed (${e.message}). Offline mock mode recommended.';
      });
    } on TimeoutException {
      stopwatch.stop();
      setState(() {
        _isTestingConnection = false;
        _testResultStatus = 'error';
        _testLatencyMs = null;
        _testResultMessage = 'Connection timed out after 5.0 seconds.';
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isTestingConnection = false;
        _testResultStatus = 'error';
        _testLatencyMs = null;
        _testResultMessage = 'Network error: ${e.toString()}';
      });
    }
  }

  void _saveUrl() {
    if (!_formKey.currentState!.validate()) return;
    final trimmed = _urlController.text.trim();
    context.read<EventProvider>().setCustomApiUrl(trimmed);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API Base URL saved successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _resetDefault() {
    setState(() {
      _urlController.text = AppConstants.defaultApiUrl;
      _testResultStatus = null;
      _testResultMessage = null;
    });
    context.read<EventProvider>().setCustomApiUrl(AppConstants.defaultApiUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset to default local API endpoint.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Developer & API Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLight.withAlpha((0.3 * 255).round()),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.developer_mode_rounded,
                      color: AppColors.primaryLight, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Restricted Configuration: Adjust event REST endpoints, mock vs live backends, and run live diagnostic ping tests.',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Mode Toggle Card
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SwitchListTile(
                value: eventProvider.useApiBackend,
                onChanged: (val) => eventProvider.setUseApiBackend(val),
                secondary: Icon(
                  Icons.cloud_sync_rounded,
                  color: eventProvider.useApiBackend
                      ? AppColors.success
                      : AppColors.warning,
                ),
                title: const Text(
                  'Live REST API Mode',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  eventProvider.useApiBackend
                      ? 'Actively fetching live campus records via HTTP client'
                      : 'Offline Mock Mode: Using embedded collegiate events repository',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Endpoint Configuration GlassCard
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remote API Base URL',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Configure base URL prefix for campus events and registrations.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _urlController,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'API Endpoint Base URL',
                        prefixIcon: Icon(Icons.link_rounded),
                        hintText: 'https://campusverse-api.local/api/v1',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Endpoint URL is required';
                        }
                        final uri = Uri.tryParse(val.trim());
                        if (uri == null ||
                            (!uri.isScheme('http') && !uri.isScheme('https')) ||
                            uri.host.isEmpty) {
                          return 'Enter valid http:// or https:// URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Test & Save Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isTestingConnection
                                ? null
                                : () => _testConnection(_urlController.text),
                            icon: _isTestingConnection
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.network_check_rounded, size: 18),
                            label: const Text('Test Connection'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveUrl,
                            icon: const Icon(Icons.save_rounded, size: 18),
                            label: const Text('Save URL'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _resetDefault,
                        icon: const Icon(Icons.restore_rounded, size: 16),
                        label: const Text('Reset to Default URL'),
                      ),
                    ),

                    // Diagnostic Test Output
                    if (_testResultMessage != null) ...[
                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _testResultStatus == 'success'
                              ? AppColors.success.withAlpha((0.15 * 255).round())
                              : AppColors.error.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _testResultStatus == 'success'
                                ? AppColors.success
                                : AppColors.error,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _testResultStatus == 'success'
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: _testResultStatus == 'success'
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _testResultMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  if (_testLatencyMs != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Round-trip latency: ${_testLatencyMs}ms',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _testResultStatus == 'success'
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Protocol & Security Note
            Text(
              'Security & Implementation Notes:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '• In offline mock mode, realistic collegiate events are served with instant zero-latency responses.\n'
              '• Live REST mode enables integration with microservices, with automatic fallback when endpoints are offline.\n'
              '• Passwords and API credentials are never logged or stored in plain text.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
