import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../models/event.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  String baseUrl;
  final http.Client _client;

  ApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? AppConstants.defaultApiUrl,
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Fetch all events from REST endpoint
  Future<List<Event>> fetchEvents() async {
    final uri = Uri.parse('$baseUrl/events');
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'] as List<dynamic>;
        } else if (decoded is Map && decoded['events'] is List) {
          list = decoded['events'] as List<dynamic>;
        } else {
          throw ApiException('Unexpected server response structure');
        }

        return list
            .map((item) => Event.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          'Failed to load events (${response.statusCode}): ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } on SocketException {
      throw ApiException(
        'Unable to connect to $baseUrl. Check network connection or switch to offline mock mode.',
      );
    } on TimeoutException {
      throw ApiException('Request to $baseUrl timed out after 8 seconds.');
    } on FormatException {
      throw ApiException('Invalid JSON response received from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Fetch a single event by ID
  Future<Event> fetchEventById(String id) async {
    final uri = Uri.parse('$baseUrl/events/$id');
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic> data = decoded is Map && decoded.containsKey('data')
            ? decoded['data'] as Map<String, dynamic>
            : decoded as Map<String, dynamic>;
        return Event.fromJson(data);
      } else {
        throw ApiException(
          'Failed to fetch event #$id (${response.statusCode})',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching event #$id: $e');
    }
  }

  /// Register for an event via REST API POST
  Future<Map<String, dynamic>> registerEvent({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$baseUrl/events/$eventId/register');
    try {
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Registration failed (${response.statusCode}): ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error submitting registration: $e');
    }
  }

  /// Verify ticket atomically via REST API
  Future<Map<String, dynamic>> verifyTicketRemote(String rawInput, {String? targetEventId}) async {
    final uri = Uri.parse('$baseUrl/tickets/verify');
    try {
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'rawInput': rawInput,
              if (targetEventId != null) 'targetEventId': targetEventId,
            }),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Remote ticket verification failed (${response.statusCode}): ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error verifying ticket remotely: $e');
    }
  }

  /// Check in ticket atomically via REST API
  Future<Map<String, dynamic>> checkInTicketRemote(String registrationId) async {
    final uri = Uri.parse('$baseUrl/tickets/check-in');
    try {
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'registrationId': registrationId}),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Remote gate check-in failed (${response.statusCode}): ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error submitting remote check-in: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
